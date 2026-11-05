#!/usr/bin/env bash
# Vercel build for the user app as a Flutter web site.
set -euo pipefail

# shortcut: tracks Flutter stable, pin a tag if a stable release breaks the build
[ -d _flutter ] || git clone --depth 1 -b stable https://github.com/flutter/flutter.git _flutter
export PATH="$PWD/_flutter/bin:$PATH"

: "${SUPABASE_URL:?set SUPABASE_URL in Vercel env vars}"
: "${SUPABASE_ANON_KEY:?set SUPABASE_ANON_KEY in Vercel env vars}"

# api_keys.dart is gitignored, so generate it. Everything here ships in public
# main.dart.js: only the Supabase URL and publishable anon key belong in it.
# The user app never reads tmdb/gemini, so they stay empty on purpose.
cat > ../../shared/lib/api_keys.dart <<EOF
class ApiKeys {
  static const String tmdb = "";
  static const String gemini = "";
  static const String supabaseUrl = "$SUPABASE_URL";
  static const String supabaseAnonKey = "$SUPABASE_ANON_KEY";
}
EOF

flutter config --no-analytics
flutter pub get
flutter build web --release
