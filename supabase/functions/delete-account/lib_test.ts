// Run: node --test supabase/functions/delete-account/lib_test.ts
import { test } from "node:test";
import assert from "node:assert/strict";

import { type Deps, handleDeleteAccount } from "./lib.ts";

function fakeDeps(over: Partial<Deps> = {}) {
  const calls: string[] = [];
  const deps: Deps = {
    getUser: async (jwt) => (jwt === "good" ? { id: "user-1", email: "a@x.com" } : null),
    ownsVenues: async () => false,
    scheduleDeletion: async (c) => {
      calls.push(`schedule:${c.id}:${c.email}`);
      return "2026-11-19T10:00:00Z";
    },
    revokeSessions: async (jwt) => void calls.push(`revoke:${jwt}`),
    ...over,
  };
  return { deps, calls };
}

test("schedules the caller's own deletion, then revokes their sessions", async () => {
  const { deps, calls } = fakeDeps();
  const r = await handleDeleteAccount("POST", "Bearer good", deps);
  assert.deepEqual(r, { status: 200, body: { scheduled_for: "2026-11-19T10:00:00Z" } });
  assert.deepEqual(calls, ["schedule:user-1:a@x.com", "revoke:good"]);
});

test("rejects missing, malformed or invalid tokens without touching anything", async () => {
  for (const header of [null, "", "good", "Basic good", "Bearer bad", "Bearer "]) {
    const { deps, calls } = fakeDeps();
    const r = await handleDeleteAccount("POST", header, deps);
    assert.equal(r.status, 401, String(header));
    assert.deepEqual(calls, []);
  }
});

test("only POST is allowed", async () => {
  const { deps, calls } = fakeDeps();
  assert.equal((await handleDeleteAccount("GET", "Bearer good", deps)).status, 405);
  assert.equal((await handleDeleteAccount("DELETE", "Bearer good", deps)).status, 405);
  assert.deepEqual(calls, []);
});

test("refuses while the user still owns venues", async () => {
  const { deps, calls } = fakeDeps({ ownsVenues: async () => true });
  const r = await handleDeleteAccount("POST", "Bearer good", deps);
  assert.deepEqual(r, { status: 409, body: { error: "owns_venues" } });
  assert.deepEqual(calls, []);
});

test("reports a generic error (no internals) when scheduling fails, and keeps sessions", async () => {
  const { deps, calls } = fakeDeps({ scheduleDeletion: async () => { throw new Error("db password is hunter2"); } });
  const r = await handleDeleteAccount("POST", "Bearer good", deps);
  assert.deepEqual(r, { status: 500, body: { error: "delete_failed" } });
  assert.deepEqual(calls, []);
});
