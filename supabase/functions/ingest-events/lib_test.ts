// Run: node --test supabase/functions/ingest-events/lib_test.ts
import { test } from "node:test";
import assert from "node:assert/strict";

import { buildPrompt, displayableImageUrl, dropKnownEvents, extractJsonLdEvents, htmlToText, ingestKey, isNearDuplicate, parseCoords, parseFeed, robotsAllows, safeEqual, validateEvent, venueTypeFor } from "./lib.ts";

const NOW = new Date("2026-10-27T12:00:00Z");

const validRaw = {
  title: "Open Air Jazz",
  breaking_headline: "Free jazz in Mauerpark tonight",
  description: "Live jazz.",
  category: "music",
  original_category: "Konzert",
  start_time: "2026-10-28T19:30:00+01:00",
  end_time: "2026-10-28T22:00:00+01:00",
  venue_name: "Mauerpark",
  venue_address: "Bernauer Str. 63, 13355 Berlin",
  neighborhood: "Prenzlauer Berg",
  city: "Berlin",
  is_free: true,
  price_eur: 15,
  registration_url: "https://example.org/jazz",
  image_url: "javascript:alert(1)",
  organizer: "Mauerpark Beats",
  organizer_avatar: null,
};

test("parseFeed reads RSS items with CDATA and entities", () => {
  const xml = `<rss><channel>
    <item><title><![CDATA[Jazz &amp; Soul]]></title><link>https://a.de/1</link>
      <description>&lt;p&gt;Live im Park&lt;/p&gt;</description><pubDate>Mon, 26 Oct 2026</pubDate></item>
    <item><title></title></item>
  </channel></rss>`;
  const items = parseFeed(xml);
  assert.equal(items.length, 1);
  assert.equal(items[0].title, "Jazz & Soul");
  assert.equal(items[0].link, "https://a.de/1");
  assert.equal(items[0].summary, "Live im Park");
});

test("parseFeed reads Atom entries with href links", () => {
  const xml = `<feed><entry><title>Lesung</title><link href="https://b.de/2"/><summary>Text</summary></entry></feed>`;
  const [item] = parseFeed(xml);
  assert.equal(item.link, "https://b.de/2");
  assert.equal(item.summary, "Text");
});

test("htmlToText drops scripts/styles and truncates", () => {
  const html = `<head><title>x</title></head><script>evil()</script><style>p{}</style><p>Hallo&nbsp;Welt</p><div>Zweite</div>`;
  assert.equal(htmlToText(html), "Hallo Welt\nZweite");
  assert.equal(htmlToText(html, 5), "Hallo");
});

test("robotsAllows honours matching groups and longest match", () => {
  const robots = `User-agent: *\nDisallow: /private\nAllow: /private/events\n\nUser-agent: OtherBot\nDisallow: /`;
  const ua = "NextShowIngest/1.0";
  assert.equal(robotsAllows(robots, "/events", ua), true);
  assert.equal(robotsAllows(robots, "/private/x", ua), false);
  assert.equal(robotsAllows(robots, "/private/events/1", ua), true);
  assert.equal(robotsAllows(`User-agent: nextshowingest\nDisallow: /`, "/a", ua), false);
});

test("validateEvent normalises a good event and strips unsafe URLs", () => {
  const e = validateEvent(validRaw, NOW);
  assert.ok(e);
  assert.equal(e.start_time, "2026-10-28T18:30:00.000Z");
  assert.equal(e.price_eur, 0, "free events are priced 0 even if the LLM says otherwise");
  assert.equal(e.image_url, null);
  assert.equal(e.registration_url, "https://example.org/jazz");
});

test("validateEvent rejects past, far-future, date-only, and off-enum events", () => {
  assert.equal(validateEvent({ ...validRaw, start_time: "2026-10-01T19:00:00+02:00" }, NOW), null);
  assert.equal(validateEvent({ ...validRaw, start_time: "2028-01-01T19:00:00+01:00" }, NOW), null);
  assert.equal(validateEvent({ ...validRaw, start_time: "2026-10-28" }, NOW), null);
  assert.equal(validateEvent({ ...validRaw, category: "food" }, NOW), null);
  assert.equal(validateEvent({ ...validRaw, title: "  " }, NOW), null);
  assert.equal(validateEvent("nope", NOW), null);
});

test("validateEvent drops an end_time before start_time", () => {
  const e = validateEvent({ ...validRaw, end_time: "2026-10-28T18:00:00+01:00" }, NOW);
  assert.equal(e?.end_time, null);
});

test("ingestKey is stable across title punctuation/case and differs by start", async () => {
  const a = await ingestKey("https://s.de", "Open Air: JAZZ!", "2026-10-28T18:30:00.000Z");
  const b = await ingestKey("https://s.de", "open air jazz", "2026-10-28T18:30:00.000Z");
  const c = await ingestKey("https://s.de", "open air jazz", "2026-10-29T18:30:00.000Z");
  assert.equal(a, b);
  assert.notEqual(a, c);
  assert.match(a, /^[0-9a-f]{64}$/);
});

test("venueTypeFor maps categories onto allowed venue types", () => {
  assert.equal(venueTypeFor("movie"), "cinema");
  assert.equal(venueTypeFor("theatre"), "theatre");
  assert.equal(venueTypeFor("music"), "club");
  assert.equal(venueTypeFor("comedy"), "club");
});

test("extractJsonLdEvents finds events in arrays, @graph and ItemLists and compacts them", () => {
  const html = `
    <script type="application/ld+json">{"@type":"Organization","name":"x"}</script>
    <script type="application/ld+json">[{"@type":"MusicEvent","name":"Jazz","startDate":"2026-11-05",
      "location":{"@type":"Place","name":"Park","address":{"@type":"PostalAddress","streetAddress":"Str. 1","addressLocality":"Berlin"},
      "geo":{"latitude":"52.5","longitude":"13.4"}},"offers":{"price":"0"},"image":["https://i/1.jpg","https://i/2.jpg"]}]</script>
    <script type="application/ld+json">{"@graph":[{"@type":"ItemList","itemListElement":[{"item":{"@type":"Event","name":"Lesung"}}]}]}</script>
    <script type="application/ld+json">{not json</script>`;
  const events = extractJsonLdEvents(html);
  assert.equal(events.length, 2);
  assert.deepEqual(
    { name: events[0].name, venue: events[0].venue, address: events[0].address, lat: events[0].lat, image: events[0].image, price: events[0].price },
    { name: "Jazz", venue: "Park", address: "Str. 1, Berlin", lat: "52.5", image: "https://i/1.jpg", price: "0" },
  );
  assert.equal(events[1].name, "Lesung");
  assert.deepEqual(extractJsonLdEvents("<p>no data</p>"), []);
});

test("parseCoords accepts numbers or numeric strings and rejects junk", () => {
  assert.deepEqual(parseCoords(52.47, 13.45), { lat: 52.47, lng: 13.45 });
  assert.deepEqual(parseCoords("52.474571", "13.457464"), { lat: 52.474571, lng: 13.457464 });
  assert.equal(parseCoords(0, 0), null);
  assert.equal(parseCoords(95, 13), null);
  assert.equal(parseCoords(52.4, null), null);
  assert.equal(parseCoords("abc", "13"), null);
});

test("validateEvent keeps valid venue coordinates and drops partial ones", () => {
  assert.deepEqual(
    (({ venue_lat, venue_lng }) => ({ venue_lat, venue_lng }))(validateEvent({ ...validRaw, venue_lat: 52.5, venue_lng: 13.4 }, NOW)!),
    { venue_lat: 52.5, venue_lng: 13.4 },
  );
  assert.equal(validateEvent({ ...validRaw, venue_lat: 52.5 }, NOW)?.venue_lat, null);
});

test("displayableImageUrl swaps AllEvents AVIF for WebP and leaves others alone", () => {
  assert.equal(displayableImageUrl("https://cdn-ip.allevents.in/s/rs:fill:500:250/abc.avif"), "https://cdn-ip.allevents.in/s/rs:fill:500:250/abc.webp");
  assert.equal(displayableImageUrl("https://other.cdn/x.avif"), "https://other.cdn/x.avif");
  assert.equal(displayableImageUrl("https://cdn-ip.allevents.in/a.jpg"), "https://cdn-ip.allevents.in/a.jpg");
  assert.equal(displayableImageUrl(null), null);
});

test("isNearDuplicate: same title at a slightly different time is the same event", () => {
  // Production case: "SLAYANCE" was read as 20:00 on one run and 20:30 on the next.
  const first = { title: "SLAYANCE", start_time: "2026-11-05T19:00:00Z" };
  assert.equal(isNearDuplicate({ title: "Slayance!", start_time: "2026-11-05T19:30:00Z" }, first), true);
  assert.equal(isNearDuplicate({ title: "SLAYANCE", start_time: "2026-11-05T19:45:00Z" }, first), true);
  // A second show later the same night, or a different show, is not.
  assert.equal(isNearDuplicate({ title: "SLAYANCE", start_time: "2026-11-05T21:00:00Z" }, first), false);
  assert.equal(isNearDuplicate({ title: "Comedy Night", start_time: "2026-11-05T19:00:00Z" }, first), false);
});

test("prompt asks for the event's own page as fallback link, never the listing page", () => {
  const p = buildPrompt({ sourceName: "S", sourceUrl: "https://s.de/list", city: "Berlin", now: NOW, content: "x" });
  assert.match(p, /event's own page/);
  assert.match(p, /Never the listing page/);
});

test("validateEvent keeps only https links", () => {
  const e = validateEvent({ ...validRaw, registration_url: "http://example.org/jazz", image_url: "http://img.example/a.jpg" }, NOW)!;
  assert.equal(e.registration_url, null);
  assert.equal(e.image_url, null);
});

test("safeEqual matches only identical secrets", () => {
  assert.equal(safeEqual("abc123", "abc123"), true);
  assert.equal(safeEqual("abc123", "abc124"), false);
  assert.equal(safeEqual("abc", "abc123"), false);
  assert.equal(safeEqual("", "abc"), false);
});

test("dropKnownEvents skips stored events and keeps new or untimed ones", () => {
  const known = [{ title: "SLAYANCE", start_time: "2026-11-05T19:00:00Z" }];
  const kept = dropKnownEvents([
    { name: "Slayance", startDate: "2026-11-05T20:30:00+01:00" }, // stored, AI read 30 min off
    { name: "SLAYANCE", startDate: "2026-11-12T20:00:00+01:00" }, // next week: new
    { name: "Comedy Night", startDate: "2026-11-05T20:00:00+01:00" }, // other show: new
    { name: "SLAYANCE", startDate: "2026-11-05" }, // no time: keep, dedupe decides later
  ], known);
  assert.deepEqual(kept.map((e) => e.startDate), ["2026-11-12T20:00:00+01:00", "2026-11-05T20:00:00+01:00", "2026-11-05"]);
});
