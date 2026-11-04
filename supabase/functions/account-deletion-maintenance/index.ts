// account-deletion-maintenance: run hourly by pg_cron (see migration 20261105000100).
// Emails the 24h reminder and permanently deletes accounts whose 14-day grace period is over.
// Auth: header `x-maintenance-secret` == MAINTENANCE_SECRET (deploy with --no-verify-jwt).
// Mail: SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM. See README.md.

import nodemailer from "npm:nodemailer@6.9.16";
import { createClient } from "npm:@supabase/supabase-js@2.45.4";
import { type Deps, reminderEmail, runMaintenance } from "./lib.ts";

const MAINTENANCE_SECRET = Deno.env.get("MAINTENANCE_SECRET") ?? "";
const SMTP_PORT = Number(Deno.env.get("SMTP_PORT") ?? "465");
const mailer = nodemailer.createTransport({
  host: Deno.env.get("SMTP_HOST"),
  port: SMTP_PORT,
  secure: SMTP_PORT === 465,
  auth: { user: Deno.env.get("SMTP_USER"), pass: Deno.env.get("SMTP_PASS") },
});
const FROM = Deno.env.get("SMTP_FROM") ?? Deno.env.get("SMTP_USER");

const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});

const deps: Deps = {
  async dueReminders(now, limit) {
    const { data, error } = await admin.from("account_deletions").select("user_id, email, scheduled_for")
      .is("reminder_sent_at", null)
      .gt("scheduled_for", now.toISOString())
      .lte("scheduled_for", new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString())
      .limit(limit);
    if (error) throw new Error(error.message);
    return data ?? [];
  },
  async sendReminder(row) {
    const mail = reminderEmail(row.scheduled_for);
    await mailer.sendMail({ from: FROM, to: row.email, subject: mail.subject, text: mail.text, html: mail.html });
  },
  async markReminderSent(userId) {
    const { error } = await admin.from("account_deletions")
      .update({ reminder_sent_at: new Date().toISOString() }).eq("user_id", userId);
    if (error) throw new Error(error.message);
  },
  async dueDeletions(now, limit) {
    const { data, error } = await admin.from("account_deletions").select("user_id, email, scheduled_for")
      .lte("scheduled_for", now.toISOString()).limit(limit);
    if (error) throw new Error(error.message);
    return data ?? [];
  },
  async ownsVenues(userId) {
    const { count, error } = await admin.from("venues").select("id", { count: "exact", head: true })
      .eq("owner_id", userId);
    if (error) throw new Error(error.message);
    return (count ?? 0) > 0;
  },
  async removeAvatars(userId) {
    const { data, error } = await admin.storage.from("avatars").list(userId);
    if (error) throw new Error(error.message);
    if (data.length > 0) {
      const { error: rmError } = await admin.storage.from("avatars").remove(data.map((f) => `${userId}/${f.name}`));
      if (rmError) throw new Error(rmError.message);
    }
  },
  async deleteUser(userId) {
    const { error } = await admin.auth.admin.deleteUser(userId);
    if (error) throw new Error(error.message);
  },
  async recordError(userId, message) {
    await admin.from("account_deletions").update({ last_error: message }).eq("user_id", userId);
  },
};

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  if (!MAINTENANCE_SECRET || req.headers.get("x-maintenance-secret") !== MAINTENANCE_SECRET) {
    return json({ error: "unauthorized" }, 401);
  }
  try {
    const report = await runMaintenance(new Date(), deps);
    console.log("account-deletion-maintenance", JSON.stringify(report));
    return json(report);
  } catch (e) {
    console.error("account-deletion-maintenance failed", (e as Error).message);
    return json({ error: "maintenance_failed" }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
