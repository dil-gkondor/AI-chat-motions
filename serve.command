#!/bin/bash
# Double-click this file to serve the prototype at http://localhost:8000
cd "$(dirname "$0")" || exit 1
PORT=8000
while lsof -i :$PORT >/dev/null 2>&1; do PORT=$((PORT+1)); done
echo "Serving $(pwd) at http://localhost:$PORT"
(sleep 1 && open "http://localhost:$PORT/index.html") &
python3 -m http.server "$PORT"
