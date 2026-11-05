// tmdb: TMDB search, details and server-side verification of movie events for the organizer
// app. The TMDB key is the TMDB_API_KEY secret and never reaches a client (S5). Clients cannot
// set events.is_verified themselves (guard_event_write); only the "verify" action here can (S3).
// Deploy with JWT verification ON (the default). See README.md.

import { createClient } from "npm:@supabase/supabase-js@2.45.4";
import { handleTmdb } from "./lib.ts";

const TMDB_API_KEY = Deno.env.get("TMDB_API_KEY") ?? "";
const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false },
});

const cors = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, apikey, content-type, x-client-info",
  "access-control-allow-methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });
  if (!TMDB_API_KEY) {
    console.error("TMDB_API_KEY is not set");
    return Response.json({ error: "not_configured" }, { status: 500, headers: cors });
  }

  const body = await req.json().catch(() => ({}));
  const { status, body: out } = await handleTmdb(req.method, req.headers.get("authorization"), body, {
    async getCaller(jwt) {
      const { data, error } = await admin.auth.getUser(jwt);
      if (error || !data.user) return null;
      const { data: p } = await admin.from("profiles").select("role, is_verified").eq("id", data.user.id)
        .maybeSingle();
      const isAdmin = p?.role === "admin";
      return { id: data.user.id, isAdmin, canUseTmdb: isAdmin || (p?.role === "partner" && p?.is_verified === true) };
    },
    async tmdbGet(path, params) {
      const url = new URL(`https://api.themoviedb.org/3${path}`);
      for (const [k, v] of Object.entries({ ...params, api_key: TMDB_API_KEY })) url.searchParams.set(k, v);
      const res = await fetch(url, { signal: AbortSignal.timeout(8000) });
      if (res.status === 404) return null;
      if (!res.ok) throw new Error(`tmdb ${res.status}`);
      return await res.json();
    },
    async getEvent(id) {
      const { data, error } = await admin.from("events").select("id, created_by, external_ids, metadata")
        .eq("id", id).maybeSingle();
      if (error) throw new Error(error.message);
      return data;
    },
    async updateEvent(id, fields) {
      const { error } = await admin.from("events").update(fields).eq("id", id);
      if (error) throw new Error(error.message);
    },
  });

  return Response.json(out, { status, headers: cors });
});
