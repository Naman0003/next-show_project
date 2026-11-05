// TMDB proxy rules, free of Deno/Supabase imports so `node --test` can run them.
// The TMDB key lives only in the function's secrets (S5); verifying a movie event happens
// here, against TMDB, never on the client (S3).

export interface Caller {
  id: string;
  /** Verified partner or admin: the only roles that create movie events. */
  canUseTmdb: boolean;
  isAdmin: boolean;
}

export interface EventRow {
  id: string;
  created_by: string | null;
  external_ids: Record<string, unknown> | null;
  metadata: Record<string, unknown> | null;
}

export interface Deps {
  /** Validates the caller's JWT with Supabase Auth and loads their role; null if invalid. */
  getCaller(jwt: string): Promise<Caller | null>;
  /** GET https://api.themoviedb.org/3<path>; returns parsed JSON, or null on 404. Throws on other errors. */
  tmdbGet(path: string, params: Record<string, string>): Promise<unknown | null>;
  getEvent(id: string): Promise<EventRow | null>;
  /** Writes with the service role, so the guard_event_write trigger lets is_verified through. */
  updateEvent(id: string, fields: Record<string, unknown>): Promise<void>;
}

export interface Result {
  status: number;
  body: Record<string, unknown>;
}

export interface SearchResult {
  id: number;
  title: string;
  overview: string | null;
  poster_path: string | null;
  release_date: string | null;
  vote_average: number;
}

export interface MovieDetails {
  id: number;
  title: string;
  overview: string | null;
  poster_url: string | null;
  runtime: number | null;
  director: string | null;
  genres: string[];
  release_year: string | null;
}

const POSTER_BASE = "https://image.tmdb.org/t/p/w500";
const MAX_QUERY = 100;

const strOrNull = (v: unknown): string | null => (typeof v === "string" && v.trim() ? v : null);

export function mapSearch(json: unknown): SearchResult[] {
  const results = (json as { results?: unknown[] } | null)?.results;
  if (!Array.isArray(results)) return [];
  return results.flatMap((r) => {
    const o = r as Record<string, unknown>;
    if (typeof o.id !== "number") return [];
    return [{
      id: o.id,
      title: strOrNull(o.title) ?? "Untitled",
      overview: strOrNull(o.overview),
      poster_path: strOrNull(o.poster_path),
      release_date: strOrNull(o.release_date),
      vote_average: typeof o.vote_average === "number" ? o.vote_average : 0,
    }];
  });
}

export function mapDetails(json: unknown): MovieDetails | null {
  const o = json as Record<string, unknown> | null;
  if (!o || typeof o.id !== "number") return null;
  const poster = strOrNull(o.poster_path);
  const release = strOrNull(o.release_date);
  const crew = ((o.credits as { crew?: unknown[] } | undefined)?.crew ?? []) as Record<string, unknown>[];
  return {
    id: o.id,
    title: strOrNull(o.title) ?? "Untitled",
    overview: strOrNull(o.overview),
    poster_url: poster ? POSTER_BASE + poster : null,
    runtime: typeof o.runtime === "number" && o.runtime > 0 ? o.runtime : null,
    director: strOrNull(crew.find((c) => c.job === "Director")?.name),
    genres: ((o.genres ?? []) as Record<string, unknown>[]).map((g) => strOrNull(g.name)).filter((g): g is string => !!g),
    release_year: release && release.length >= 4 ? release.slice(0, 4) : null,
  };
}

/** Canonical TMDB values overwrite whatever the client sent, then the event counts as verified. */
export function verifiedFields(event: EventRow, d: MovieDetails): Record<string, unknown> {
  return {
    title: d.title,
    description: d.overview,
    image_url: d.poster_url,
    duration_minutes: d.runtime,
    metadata: {
      ...(event.metadata ?? {}),
      director: d.director,
      genres: d.genres,
      ...(d.release_year ? { release_year: d.release_year } : {}),
    },
    is_verified: true,
  };
}

export async function handleTmdb(
  method: string,
  authorization: string | null,
  body: unknown,
  deps: Deps,
): Promise<Result> {
  if (method !== "POST") return { status: 405, body: { error: "method_not_allowed" } };

  const jwt = /^Bearer (.+)$/i.exec(authorization ?? "")?.[1];
  const caller = jwt ? await deps.getCaller(jwt) : null;
  if (!caller) return { status: 401, body: { error: "unauthorized" } };
  if (!caller.canUseTmdb) return { status: 403, body: { error: "verified_partners_only" } };

  const b = (body ?? {}) as Record<string, unknown>;
  try {
    switch (b.action) {
      case "search": {
        const query = typeof b.query === "string" ? b.query.trim().slice(0, MAX_QUERY) : "";
        if (!query) return { status: 200, body: { results: [] } };
        const json = await deps.tmdbGet("/search/movie", { query, include_adult: "false", language: "en-US" });
        return { status: 200, body: { results: mapSearch(json) } };
      }
      case "details": {
        if (!Number.isInteger(b.id) || (b.id as number) <= 0) return { status: 400, body: { error: "bad_id" } };
        const details = mapDetails(await deps.tmdbGet(`/movie/${b.id}`, { append_to_response: "credits" }));
        return details ? { status: 200, body: { details } } : { status: 404, body: { error: "not_found" } };
      }
      case "verify": {
        if (typeof b.event_id !== "string" || !b.event_id) return { status: 400, body: { error: "bad_event_id" } };
        const event = await deps.getEvent(b.event_id);
        // Only the creator (or an admin) can verify; same answer for "missing" and "not yours".
        if (!event || (!caller.isAdmin && event.created_by !== caller.id)) {
          return { status: 404, body: { error: "not_found" } };
        }
        const tmdbId = Number(event.external_ids?.tmdb_id);
        if (!Number.isInteger(tmdbId) || tmdbId <= 0) return { status: 400, body: { error: "no_tmdb_id" } };
        const details = mapDetails(await deps.tmdbGet(`/movie/${tmdbId}`, { append_to_response: "credits" }));
        if (!details) return { status: 404, body: { error: "tmdb_not_found" } };
        const fields = verifiedFields(event, details);
        await deps.updateEvent(event.id, fields);
        return { status: 200, body: { verified: true, details } };
      }
      default:
        return { status: 400, body: { error: "bad_action" } };
    }
  } catch (e) {
    console.error("tmdb failed", b.action, (e as Error).message);
    return { status: 502, body: { error: "tmdb_failed" } };
  }
}
