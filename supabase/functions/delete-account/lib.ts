// Account deletion request rules, free of Deno/Supabase imports so `node --test` can run them.
// Nothing is deleted here: the account is deactivated and purged after a 14-day grace period
// by account-deletion-maintenance. The user can restore it by signing in again.

export interface Caller {
  id: string;
  email: string;
}

export interface Deps {
  /** Validates the caller's JWT with Supabase Auth; null if invalid. */
  getUser(jwt: string): Promise<Caller | null>;
  /** True when the user still owns venues (profiles -> venues is ON DELETE RESTRICT). */
  ownsVenues(userId: string): Promise<boolean>;
  /** Records the pending deletion and returns scheduled_for (ISO). Idempotent: a repeat request keeps the original date. */
  scheduleDeletion(caller: Caller): Promise<string>;
  /** Invalidates every session of the user (all devices). */
  revokeSessions(jwt: string): Promise<void>;
}

export interface Result {
  status: number;
  body: Record<string, unknown>;
}

export async function handleDeleteAccount(
  method: string,
  authorization: string | null,
  deps: Deps,
): Promise<Result> {
  if (method !== "POST") return { status: 405, body: { error: "method_not_allowed" } };

  const jwt = /^Bearer (.+)$/i.exec(authorization ?? "")?.[1];
  const caller = jwt ? await deps.getUser(jwt) : null;
  if (!jwt || !caller) return { status: 401, body: { error: "unauthorized" } };

  // Only ever acts on the caller's own account: the id comes from the verified token, never from the body.
  if (await deps.ownsVenues(caller.id)) return { status: 409, body: { error: "owns_venues" } };

  try {
    const scheduledFor = await deps.scheduleDeletion(caller);
    await deps.revokeSessions(jwt);
    return { status: 200, body: { scheduled_for: scheduledFor } };
  } catch (e) {
    console.error("delete-account failed", caller.id, (e as Error).message);
    return { status: 500, body: { error: "delete_failed" } };
  }
}
