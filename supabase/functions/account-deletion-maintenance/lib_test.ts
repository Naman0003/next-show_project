// Run: node --test supabase/functions/account-deletion-maintenance/lib_test.ts
import { test } from "node:test";
import assert from "node:assert/strict";

import { type Deps, type PendingDeletion, reminderEmail, runMaintenance } from "./lib.ts";

const NOW = new Date("2026-11-18T10:00:00Z");
const row = (id: string): PendingDeletion => ({ user_id: id, email: `${id}@x.com`, scheduled_for: "2026-11-19T09:00:00Z" });

function fakeDeps(over: Partial<Deps> = {}) {
  const calls: string[] = [];
  const deps: Deps = {
    dueReminders: async () => [],
    sendReminder: async (r) => void calls.push(`mail:${r.email}`),
    markReminderSent: async (id) => void calls.push(`marked:${id}`),
    dueDeletions: async () => [],
    ownsVenues: async () => false,
    removeAvatars: async (id) => void calls.push(`avatars:${id}`),
    deleteUser: async (id) => void calls.push(`delete:${id}`),
    recordError: async (id, m) => void calls.push(`error:${id}:${m}`),
    ...over,
  };
  return { deps, calls };
}

test("sends the reminder, then marks it sent", async () => {
  const { deps, calls } = fakeDeps({ dueReminders: async () => [row("a")] });
  assert.deepEqual(await runMaintenance(NOW, deps), { reminded: 1, deleted: 0, failed: 0 });
  assert.deepEqual(calls, ["mail:a@x.com", "marked:a"]);
});

test("a failed mail is not marked sent (retried next hour) and does not stop other users", async () => {
  const { deps, calls } = fakeDeps({
    dueReminders: async () => [row("a"), row("b")],
    sendReminder: async (r) => {
      if (r.user_id === "a") throw new Error("smtp down");
      calls.push(`mail:${r.email}`);
    },
  });
  assert.deepEqual(await runMaintenance(NOW, deps), { reminded: 1, deleted: 0, failed: 1 });
  assert.deepEqual(calls, ["mail:b@x.com", "marked:b"]);
});

test("deletes due accounts: avatars first, then the auth user", async () => {
  const { deps, calls } = fakeDeps({ dueDeletions: async () => [row("a"), row("b")] });
  assert.deepEqual(await runMaintenance(NOW, deps), { reminded: 0, deleted: 2, failed: 0 });
  assert.deepEqual(calls, ["avatars:a", "delete:a", "avatars:b", "delete:b"]);
});

test("a user who now owns venues is left pending with a recorded reason", async () => {
  const { deps, calls } = fakeDeps({ dueDeletions: async () => [row("a")], ownsVenues: async () => true });
  assert.deepEqual(await runMaintenance(NOW, deps), { reminded: 0, deleted: 0, failed: 1 });
  assert.deepEqual(calls, ["error:a:owns_venues"]);
});

test("one failing deletion is recorded and does not block the rest", async () => {
  const { deps, calls } = fakeDeps({
    dueDeletions: async () => [row("a"), row("b")],
    deleteUser: async (id) => {
      if (id === "a") throw new Error("boom");
      calls.push(`delete:${id}`);
    },
  });
  assert.deepEqual(await runMaintenance(NOW, deps), { reminded: 0, deleted: 1, failed: 1 });
  assert.deepEqual(calls, ["avatars:a", "error:a:boom", "avatars:b", "delete:b"]);
});

test("nothing due, nothing done", async () => {
  const { deps, calls } = fakeDeps();
  assert.deepEqual(await runMaintenance(NOW, deps), { reminded: 0, deleted: 0, failed: 0 });
  assert.deepEqual(calls, []);
});

test("reminder email states the UTC deletion date and how to restore", () => {
  const m = reminderEmail("2026-11-19T09:00:00Z");
  assert.match(m.subject, /deleted tomorrow/);
  assert.match(m.text, /19 November 2026, 09:00 UTC/);
  assert.match(m.text, /sign in/);
  assert.match(m.html, /<p>/);
});
