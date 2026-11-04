// Hourly maintenance for accounts in their 14-day deletion grace period.
// Free of Deno/Supabase imports so `node --test` can run it.

export const REMINDER_LEAD_MS = 24 * 60 * 60 * 1000;
export const BATCH_SIZE = 50;

export interface PendingDeletion {
  user_id: string;
  email: string;
  scheduled_for: string; // ISO
}

export interface Deps {
  /** Pending, not yet reminded, scheduled within the next 24h (and not yet due). */
  dueReminders(now: Date, limit: number): Promise<PendingDeletion[]>;
  sendReminder(row: PendingDeletion): Promise<void>;
  markReminderSent(userId: string): Promise<void>;
  /** Pending with scheduled_for <= now. */
  dueDeletions(now: Date, limit: number): Promise<PendingDeletion[]>;
  ownsVenues(userId: string): Promise<boolean>;
  removeAvatars(userId: string): Promise<void>;
  /** Deletes the auth user; profiles, tickets and the account_deletions row cascade. */
  deleteUser(userId: string): Promise<void>;
  recordError(userId: string, message: string): Promise<void>;
}

export interface Report {
  reminded: number;
  deleted: number;
  failed: number;
}

export async function runMaintenance(now: Date, deps: Deps): Promise<Report> {
  const report: Report = { reminded: 0, deleted: 0, failed: 0 };

  // Reminders first. A failed mail is retried on the next hourly run until the deletion date.
  for (const row of await deps.dueReminders(now, BATCH_SIZE)) {
    try {
      await deps.sendReminder(row);
      await deps.markReminderSent(row.user_id);
      report.reminded++;
    } catch (e) {
      report.failed++;
      console.error("reminder failed", row.user_id, (e as Error).message);
    }
  }

  for (const row of await deps.dueDeletions(now, BATCH_SIZE)) {
    try {
      // A user who became a venue owner during the grace period cannot be deleted (RESTRICT); leave them pending.
      if (await deps.ownsVenues(row.user_id)) {
        await deps.recordError(row.user_id, "owns_venues");
        report.failed++;
        continue;
      }
      await deps.removeAvatars(row.user_id);
      await deps.deleteUser(row.user_id);
      report.deleted++;
    } catch (e) {
      report.failed++;
      console.error("deletion failed", row.user_id, (e as Error).message);
      await deps.recordError(row.user_id, (e as Error).message.slice(0, 500)).catch(() => {});
    }
  }
  return report;
}

/** Plain-text and HTML body of the 24h reminder. */
export function reminderEmail(scheduledFor: string): { subject: string; text: string; html: string } {
  // Built by hand: toLocaleString output differs between Node and Deno.
  const d = new Date(scheduledFor);
  const pad = (n: number) => String(n).padStart(2, "0");
  const month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][d.getUTCMonth()];
  const when = `${d.getUTCDate()} ${month} ${d.getUTCFullYear()}, ${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())} UTC`;
  const subject = "Your Next Show account will be deleted tomorrow";
  const text = `Hi,

You asked us to delete your Next Show account. It will be permanently deleted on ${when}, along with your tickets and saved data.

Changed your mind? Open the Next Show app and sign in with this email address before then. We will ask whether you want to restore your account.

After that time the deletion cannot be undone.

If you did not ask for this, sign in now to restore your account.

The Next Show team`;
  const html = text
    .split("\n\n")
    .map((p) => `<p>${p.replace(/&/g, "&amp;").replace(/</g, "&lt;")}</p>`)
    .join("\n");
  return { subject, text, html };
}
