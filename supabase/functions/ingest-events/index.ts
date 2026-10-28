// ingest-events: crawl enabled `ingestion_sources` → LLM structured
// extraction (Claude when ANTHROPIC_API_KEY is set, else Gemini) →
// venues/events/showtimes. Rows land with
// `events.is_verified = false` so admins can moderate them, and appear in
// `v_listings` (and the apps' realtime streams) immediately.
//
// Invoke: POST with header `x-ingest-secret: $INGEST_SECRET`.
// Body (optional): { "source_id": "<uuid>", "dry_run": true }
// See README.md for deploy + pg_cron scheduling.

import Anthropic from "npm:@anthropic-ai/sdk@0.133.0";
import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2.45.4";
import {
  buildPrompt,
  CLAUDE_OUTPUT_SCHEMA,
  GEMINI_RESPONSE_SCHEMA,
  extractJsonLdEvents,
  htmlToText,
  ingestKey,
  parseFeed,
  robotsAllows,
  type SourceKind,
  validateEvent,
  type ValidEvent,
  venueTypeFor,
} from "./lib.ts";

const USER_AGENT = "NextShowIngest/1.0 (+https://nextshow.berlin)";
const FETCH_TIMEOUT_MS = 15_000;
const MAX_CONTENT_CHARS = 30_000;
const MAX_EVENTS_PER_SOURCE = 50;
const LLM_TIMEOUT_MS = 120_000;
const JSON_LD_TEXT_EXCERPT_CHARS = 12_000;

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const CLAUDE_MODEL = Deno.env.get("CLAUDE_MODEL") ?? "claude-haiku-5-5";
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.5-flash-lite";
const INGEST_SECRET = Deno.env.get("INGEST_SECRET") ?? "";

// Claude is preferred when configured; Gemini stays as the fallback provider.
const useClaude = ANTHROPIC_API_KEY !== "";
const MODEL = useClaude ? CLAUDE_MODEL : GEMINI_MODEL;
const anthropic = useClaude ? new Anthropic({ apiKey: ANTHROPIC_API_KEY }) : null;
// Models that accept the server-side `fallbacks: "default"` refusal reroute.
const SERVER_FALLBACK_MODELS = new Set(["claude-fable-5-1", "claude-opus-5-5", "claude-opus-5", "claude-sonnet-5-5"]);

interface Source {
  id: string;
  name: string;
  url: string;
  kind: SourceKind;
  city: string;
}

interface SourceReport {
  source: string;
  status: string;
  extracted: number;
  inserted: number;
  skipped_duplicates: number;
  rejected: number;
  events?: ValidEvent[];
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  if (!INGEST_SECRET || req.headers.get("x-ingest-secret") !== INGEST_SECRET) {
    return json({ error: "unauthorized" }, 401);
  }
  if (!useClaude && !GEMINI_API_KEY) {
    return json({ error: "set ANTHROPIC_API_KEY or GEMINI_API_KEY" }, 500);
  }

  const body = await req.json().catch(() => ({})) as { source_id?: string; dry_run?: boolean };
  const dryRun = body.dry_run === true;

  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  let query = db.from("ingestion_sources").select("id, name, url, kind, city").eq("is_enabled", true);
  if (body.source_id) query = query.eq("id", body.source_id);
  const { data: sources, error } = await query;
  if (error) return json({ error: error.message }, 500);

  // Sources run in parallel: each LLM call can take a minute+, and the
  // function's wall-clock limit (~150s) would cut off a sequential run.
  const reports = await Promise.all(((sources ?? []) as Source[]).map(async (source) => {
    // One bad source must not stop the rest of the run.
    let report: SourceReport;
    const startedAt = Date.now();
    try {
      report = await processSource(db, source, dryRun);
    } catch (e) {
      report = emptyReport(source, `error: ${(e as Error).message}`);
    }
    // One readable line per source in Edge Functions → Logs.
    const { events: _events, ...summary } = report;
    console.log(`[${source.name}] ${dryRun ? "dry run " : ""}done in ${Date.now() - startedAt}ms`, JSON.stringify(summary));
    if (!dryRun) {
      await db.from("ingestion_sources")
        .update({ last_run_at: new Date().toISOString(), last_status: report.status.slice(0, 500) })
        .eq("id", source.id);
    }
    return report;
  }));

  return json({ dry_run: dryRun, model: MODEL, sources: reports });
});

async function processSource(db: SupabaseClient, source: Source, dryRun: boolean): Promise<SourceReport> {
  const url = new URL(source.url);
  if (!(await isAllowedByRobots(url))) return emptyReport(source, "skipped: disallowed by robots.txt");

  const res = await fetch(url, {
    headers: { "user-agent": USER_AGENT },
    signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
  });
  if (!res.ok) return emptyReport(source, `error: fetch ${res.status}`);
  const raw = await res.text();

  const content = source.kind === "rss" ? rssContent(raw) : htmlContent(raw);
  if (!content) return emptyReport(source, "ok: no content");

  const now = new Date();
  const prompt = buildPrompt({ sourceName: source.name, sourceUrl: source.url, city: source.city, now, content });
  console.log(`[${source.name}] fetched ${raw.length} chars, sending ${content.length} to ${MODEL}`);
  const extracted = useClaude ? await extractWithClaude(prompt) : await extractWithGemini(prompt);

  const valid = extracted
    .map((e) => validateEvent(e, now))
    .filter((e): e is ValidEvent => e !== null)
    .slice(0, MAX_EVENTS_PER_SOURCE);

  const report: SourceReport = {
    ...emptyReport(source, "ok"),
    extracted: extracted.length,
    rejected: extracted.length - valid.length,
  };
  if (dryRun) return { ...report, events: valid };

  for (const event of valid) {
    const outcome = await insertEvent(db, source, event);
    if (outcome === "inserted") report.inserted++;
    else report.skipped_duplicates++;
  }
  return report;
}

function rssContent(xml: string): string {
  return parseFeed(xml)
    .map((i) => `- ${i.title}\n  link: ${i.link ?? "n/a"}\n  published: ${i.published ?? "n/a"}\n  ${i.summary}`)
    .join("\n")
    .slice(0, MAX_CONTENT_CHARS);
}

/**
 * Prefers the page's JSON-LD events (compact, exact venues/coords/links) and
 * adds a short text excerpt, since JSON-LD often has dates without times.
 * Falls back to plain page text when there's no structured data.
 */
function htmlContent(html: string): string {
  const structured = extractJsonLdEvents(html);
  if (structured.length === 0) return htmlToText(html, MAX_CONTENT_CHARS);
  return `Structured events (schema.org JSON-LD):\n${JSON.stringify(structured).slice(0, MAX_CONTENT_CHARS)}\n\n` +
    `Page text excerpt (use for start times missing above):\n${htmlToText(html, JSON_LD_TEXT_EXCERPT_CHARS)}`;
}

async function extractWithClaude(prompt: string): Promise<unknown[]> {
  // Streamed so a large page + long output can't hit the HTTP timeout. The SDK
  // retries 429/5xx itself (maxRetries default 2). On models that support it,
  // `fallbacks: "default"` re-runs a safety-classifier decline on Anthropic's
  // recommended model; others (e.g. Haiku) just report the refusal.
  const stream = anthropic!.beta.messages.stream({
    model: CLAUDE_MODEL,
    max_tokens: 64000,
    ...(SERVER_FALLBACK_MODELS.has(CLAUDE_MODEL) && {
      betas: ["server-side-fallback-2026-07-01"],
      fallbacks: "default" as const,
    }),
    output_config: {
      effort: "medium",
      format: { type: "json_schema", schema: CLAUDE_OUTPUT_SCHEMA },
    },
    messages: [{ role: "user", content: prompt }],
  });
  const message = await stream.finalMessage();

  if (message.stop_reason === "refusal") {
    throw new Error(`claude refused (${message.stop_details?.category ?? "no category"})`);
  }
  if (message.stop_reason === "max_tokens") throw new Error("claude output hit max_tokens");

  const text = message.content.find((b) => b.type === "text");
  if (!text || text.type !== "text") return [];
  const parsed = JSON.parse(text.text) as { events?: unknown };
  return Array.isArray(parsed.events) ? parsed.events : [];
}

// Gemini returns 429/500/503 under load; these are transient, so back off
// and retry rather than failing the source for this run.
const GEMINI_RETRY_DELAYS_MS = [2_000, 6_000];

async function extractWithGemini(prompt: string): Promise<unknown[]> {
  let res: Response;
  for (let attempt = 0; ; attempt++) {
    res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
      {
        method: "POST",
        headers: { "content-type": "application/json", "x-goog-api-key": GEMINI_API_KEY },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0,
            responseMimeType: "application/json",
            responseSchema: GEMINI_RESPONSE_SCHEMA,
          },
        }),
        signal: AbortSignal.timeout(LLM_TIMEOUT_MS),
      },
    );
    const retryable = res.status === 429 || res.status === 500 || res.status === 503;
    if (!retryable || attempt >= GEMINI_RETRY_DELAYS_MS.length) break;
    console.warn(`gemini ${res.status}, retrying in ${GEMINI_RETRY_DELAYS_MS[attempt]}ms`);
    await res.body?.cancel();
    await new Promise((r) => setTimeout(r, GEMINI_RETRY_DELAYS_MS[attempt]));
  }
  if (!res.ok) throw new Error(`gemini ${res.status}: ${(await res.text()).slice(0, 200)}`);
  const data = await res.json();
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string") return [];
  const parsed = JSON.parse(text);
  return Array.isArray(parsed) ? parsed : [];
}

async function insertEvent(
  db: SupabaseClient,
  source: Source,
  event: ValidEvent,
): Promise<"inserted" | "duplicate"> {
  const key = await ingestKey(source.url, event.title, event.start_time);

  const { data: existing } = await db.from("events").select("id")
    .eq("external_ids->>ingest_key", key).maybeSingle();
  if (existing) return "duplicate";

  const venueId = await findOrCreateVenue(db, event);

  const { data: inserted, error: eventError } = await db.from("events").insert({
    category: event.category,
    title: event.title,
    description: event.description,
    image_url: event.image_url,
    external_ids: { ingest_key: key, source_url: source.url },
    metadata: {
      source: "ingest-events",
      source_name: source.name,
      breaking_headline: event.breaking_headline,
      original_category: event.original_category,
      city: event.city,
      neighborhood: event.neighborhood,
      is_free: event.is_free,
      organizer: event.organizer,
      organizer_avatar: event.organizer_avatar,
    },
    status: "published",
    is_verified: false,
  }).select("id").single();

  if (eventError) {
    // 23505: a concurrent run inserted the same ingest_key first.
    if (eventError.code === "23505") return "duplicate";
    throw new Error(`events insert: ${eventError.message}`);
  }

  const { error: showtimeError } = await db.from("showtimes").insert({
    venue_id: venueId,
    event_id: inserted.id,
    start_time: event.start_time,
    end_time: event.end_time,
    price: event.price_eur,
    attributes: { source: "ingest-events" },
    booking_url: event.registration_url ?? source.url,
    image_url: event.image_url,
  });
  if (showtimeError) {
    // Don't leave an event with no showtime behind (it would never list).
    await db.from("events").delete().eq("id", inserted.id);
    throw new Error(`showtimes insert: ${showtimeError.message}`);
  }
  return "inserted";
}

async function findOrCreateVenue(db: SupabaseClient, event: ValidEvent): Promise<string> {
  const pattern = event.venue_name.replace(/[\\%_]/g, (c) => `\\${c}`);
  // Coordinates from the source page win; Nominatim is only a fallback (it
  // tends to refuse requests from cloud IPs like Supabase's).
  const pageCoords = event.venue_lat !== null && event.venue_lng !== null
    ? { lat: event.venue_lat, lng: event.venue_lng }
    : null;

  const { data: found } = await db.from("venues").select("id, location").ilike("name", pattern).limit(1)
    .maybeSingle();
  if (found) {
    // Backfill a venue created before we had coordinates for it.
    if (found.location === null && pageCoords) {
      await db.from("venues").update({ location: ewkt(pageCoords) }).eq("id", found.id).is("location", null);
    }
    return found.id;
  }

  const point = pageCoords ?? await geocode(event.venue_address ?? `${event.venue_name}, ${event.city}`);
  const { data, error } = await db.from("venues").insert({
    name: event.venue_name,
    venue_type: venueTypeFor(event.category),
    address: event.venue_address,
    location: point ? ewkt(point) : null,
    partner_notes: "Auto-created by ingest-events; unverified.",
    is_active: true,
  }).select("id").single();
  if (error) throw new Error(`venues insert: ${error.message}`);
  return data.id;
}

/** PostGIS EWKT for `venues.location` (geography point, lng before lat). */
function ewkt(p: { lat: number; lng: number }): string {
  return `SRID=4326;POINT(${p.lng} ${p.lat})`;
}

// Nominatim usage policy: max 1 request/second, identifying User-Agent.
let lastGeocodeAt = 0;
async function geocode(query: string): Promise<{ lat: number; lng: number } | null> {
  const wait = lastGeocodeAt + 1100 - Date.now();
  if (wait > 0) await new Promise((r) => setTimeout(r, wait));
  lastGeocodeAt = Date.now();
  try {
    const url = `https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${encodeURIComponent(query)}`;
    const res = await fetch(url, {
      headers: { "user-agent": USER_AGENT },
      signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
    });
    if (!res.ok) return null;
    const [hit] = await res.json();
    return hit ? { lat: Number(hit.lat), lng: Number(hit.lon) } : null;
  } catch {
    return null;
  }
}

async function isAllowedByRobots(url: URL): Promise<boolean> {
  try {
    const res = await fetch(`${url.origin}/robots.txt`, {
      headers: { "user-agent": USER_AGENT },
      signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
    });
    if (!res.ok) return true; // no robots.txt → no restrictions
    return robotsAllows(await res.text(), url.pathname + url.search, USER_AGENT);
  } catch {
    return true;
  }
}

function emptyReport(source: Source, status: string): SourceReport {
  return { source: source.name, status, extracted: 0, inserted: 0, skipped_duplicates: 0, rejected: 0 };
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
