#!/bin/bash
# Serve this folder on localhost. Run with:  bash serve.command
set -u
cd "$(dirname "$0")" || exit 1

FILE="index.html"
if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found in $(pwd)" >&2
  exit 1
fi

# --- find a free port (no lsof dependency) ----------------------
PORT=8000
port_busy() {
  if command -v nc >/dev/null 2>&1; then
    nc -z 127.0.0.1 "$1" >/dev/null 2>&1
  else
    return 1
  fi
}
while port_busy "$PORT" && [ "$PORT" -lt 8020 ]; do
  PORT=$((PORT + 1))
done

URL="http://localhost:$PORT/$FILE"

open_browser() {
  ( sleep 1
    if command -v open >/dev/null 2>&1; then open "$URL"
    elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$URL"
    fi ) &
}

echo "Folder : $(pwd)"
echo

# --- pick whatever runtime this machine actually has ------------
if command -v python3 >/dev/null 2>&1; then
  echo "Serving with python3 at $URL"
  echo "Press Ctrl-C to stop."
  open_browser
  exec python3 -m http.server "$PORT"

elif command -v python >/dev/null 2>&1; then
  echo "Serving with python at $URL"
  echo "Press Ctrl-C to stop."
  open_browser
  exec python -m SimpleHTTPServer "$PORT"

elif command -v php >/dev/null 2>&1; then
  echo "Serving with php at $URL"
  echo "Press Ctrl-C to stop."
  open_browser
  exec php -S "localhost:$PORT"

elif command -v ruby >/dev/null 2>&1; then
  echo "Serving with ruby at $URL"
  echo "Press Ctrl-C to stop."
  open_browser
  exec ruby -run -e httpd . -p "$PORT"

elif command -v npx >/dev/null 2>&1; then
  echo "Serving with npx http-server at http://localhost:$PORT"
  echo "Press Ctrl-C to stop."
  open_browser
  exec npx --yes http-server . -p "$PORT" -o "/$FILE"

else
  # --- nothing to serve with: just open the file directly -------
  echo "No python3, python, php, ruby or npx found on this machine."
  echo "Opening the file directly instead — this page has no build step"
  echo "and works fine over file://"
  echo
  if command -v open >/dev/null 2>&1; then
    open "$FILE"
    echo "Opened: $(pwd)/$FILE"
  else
    echo "Open this in your browser:"
    echo "  file://$(pwd)/$FILE"
  fi
fi
