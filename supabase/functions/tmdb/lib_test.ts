// Run: node --test supabase/functions/tmdb/lib_test.ts
import { test } from "node:test";
import assert from "node:assert/strict";

import { type Caller, type Deps, type EventRow, handleTmdb, mapDetails, mapSearch } from "./lib.ts";

const MOVIE = {
  id: 27205,
  title: "Inception",
  overview: "A thief who steals secrets.",
  poster_path: "/abc.jpg",
  release_date: "2010-07-15",
  runtime: 148,
  genres: [{ name: "Action" }, { name: "Sci-Fi" }],
  credits: { crew: [{ job: "Writer", name: "X" }, { job: "Director", name: "Christopher Nolan" }] },
};

function fakeDeps(over: Partial<Deps> & { caller?: Caller | null; event?: EventRow | null } = {}) {
  const calls: string[] = [];
  const updates: Record<string, unknown>[] = [];
  const deps: Deps = {
    getCaller: async (jwt) => (jwt === "good" ? (over.caller === undefined ? { id: "p1", canUseTmdb: true, isAdmin: false } : over.caller) : null),
    tmdbGet: async (path, params) => {
      calls.push(`${path}?${new URLSearchParams(params)}`);
      if (path === "/search/movie") return { results: [MOVIE, { title: "no id" }] };
      if (path === "/movie/27205") return MOVIE;
      return null;
    },
    getEvent: async () => (over.event === undefined
      ? { id: "e1", created_by: "p1", external_ids: { tmdb_id: "27205" }, metadata: { external_ref_url: "https://x" } }
      : over.event),
    updateEvent: async (_id, fields) => void updates.push(fields),
    ...over,
  };
  return { deps, calls, updates };
}

test("rejects bad tokens, and callers who aren't verified partners or admins", async () => {
  const { deps } = fakeDeps();
  assert.equal((await handleTmdb("POST", null, { action: "search", query: "x" }, deps)).status, 401);
  assert.equal((await handleTmdb("POST", "Bearer bad", { action: "search", query: "x" }, deps)).status, 401);
  const plain = fakeDeps({ caller: { id: "u1", canUseTmdb: false, isAdmin: false } });
  assert.equal((await handleTmdb("POST", "Bearer good", { action: "search", query: "x" }, plain.deps)).status, 403);
  assert.equal((await handleTmdb("GET", "Bearer good", {}, deps)).status, 405);
});

test("search returns TMDB-shaped results and skips malformed ones", async () => {
  const { deps, calls } = fakeDeps();
  const r = await handleTmdb("POST", "Bearer good", { action: "search", query: "  Inception " }, deps);
  assert.equal(r.status, 200);
  assert.deepEqual((r.body.results as { id: number }[]).map((x) => x.id), [27205]);
  assert.match(calls[0], /query=Inception/);
  assert.deepEqual(mapSearch(null), []);
});

test("details maps poster, director, genres and year", () => {
  assert.deepEqual(mapDetails(MOVIE), {
    id: 27205, title: "Inception", overview: "A thief who steals secrets.",
    poster_url: "https://image.tmdb.org/t/p/w500/abc.jpg", runtime: 148,
    director: "Christopher Nolan", genres: ["Action", "Sci-Fi"], release_year: "2010",
  });
});

test("verify overwrites the event with TMDB's values and marks it verified", async () => {
  const { deps, updates } = fakeDeps();
  const r = await handleTmdb("POST", "Bearer good", { action: "verify", event_id: "e1" }, deps);
  assert.equal(r.status, 200);
  assert.equal(updates.length, 1);
  assert.equal(updates[0].title, "Inception");
  assert.equal(updates[0].is_verified, true);
  assert.deepEqual(updates[0].metadata, {
    external_ref_url: "https://x", director: "Christopher Nolan", genres: ["Action", "Sci-Fi"], release_year: "2010",
  });
});

test("verify refuses other partners' events, events without a tmdb_id, and unknown movies", async () => {
  const other = fakeDeps({ event: { id: "e1", created_by: "p2", external_ids: { tmdb_id: "27205" }, metadata: null } });
  assert.equal((await handleTmdb("POST", "Bearer good", { action: "verify", event_id: "e1" }, other.deps)).status, 404);
  assert.equal(other.updates.length, 0);

  const noId = fakeDeps({ event: { id: "e1", created_by: "p1", external_ids: {}, metadata: null } });
  assert.equal((await handleTmdb("POST", "Bearer good", { action: "verify", event_id: "e1" }, noId.deps)).status, 400);

  const unknown = fakeDeps({ event: { id: "e1", created_by: "p1", external_ids: { tmdb_id: "999" }, metadata: null } });
  assert.equal((await handleTmdb("POST", "Bearer good", { action: "verify", event_id: "e1" }, unknown.deps)).status, 404);
  assert.equal(unknown.updates.length, 0);

  const adminCaller = fakeDeps({ caller: { id: "a1", canUseTmdb: true, isAdmin: true },
    event: { id: "e1", created_by: "p2", external_ids: { tmdb_id: "27205" }, metadata: null } });
  assert.equal((await handleTmdb("POST", "Bearer good", { action: "verify", event_id: "e1" }, adminCaller.deps)).status, 200);
});

test("TMDB outages become a generic 502", async () => {
  const { deps } = fakeDeps({ tmdbGet: async () => { throw new Error("tmdb 500"); } });
  const r = await handleTmdb("POST", "Bearer good", { action: "details", id: 1 }, deps);
  assert.deepEqual(r, { status: 502, body: { error: "tmdb_failed" } });
});
