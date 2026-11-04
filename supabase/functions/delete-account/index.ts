// delete-account: a signed-in user asks to delete their own account (required by the
// App Store and Google Play). The account is deactivated and permanently removed after
// 14 days unless the user signs in and restores it. The user id comes from the verified
// JWT, never from the request body. See README.md.

import { createClient } from "npm:@supabase/supabase-js@2.45.4";
import { handleDeleteAccount } from "./lib.ts";

const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});

// Only the web build of the app calls this from a browser; mobile ignores CORS.
const cors = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, apikey, content-type, x-client-info",
  "access-control-allow-methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });

  const { status, body } = await handleDeleteAccount(req.method, req.headers.get("authorization"), {
    async getUser(jwt) {
      const { data, error } = await admin.auth.getUser(jwt);
      if (error || !data.user?.email) return null;
      return { id: data.user.id, email: data.user.email };
    },
    async ownsVenues(userId) {
      const { count, error } = await admin.from("venues").select("id", { count: "exact", head: true })
        .eq("owner_id", userId);
      if (error) throw new Error(error.message);
      return (count ?? 0) > 0;
    },
    async scheduleDeletion({ id, email }) {
      // ignoreDuplicates: asking twice must not push the date back.
      const { error } = await admin.from("account_deletions")
        .upsert({ user_id: id, email }, { onConflict: "user_id", ignoreDuplicates: true });
      if (error) throw new Error(error.message);
      const { data, error: readError } = await admin.from("account_deletions").select("scheduled_for")
        .eq("user_id", id).single();
      if (readError) throw new Error(readError.message);
      return data.scheduled_for as string;
    },
    async revokeSessions(jwt) {
      const { error } = await admin.auth.admin.signOut(jwt, "global");
      if (error) throw new Error(error.message);
    },
  });

  return new Response(JSON.stringify(body), { status, headers: { ...cors, "content-type": "application/json" } });
});
