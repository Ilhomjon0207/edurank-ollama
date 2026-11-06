#!/bin/sh
# Starts Ollama on the loopback address and exposes it on $PORT through nginx.
#
# Environment (set them in the Render dashboard):
#   OLLAMA_API_KEY  required secret; callers send "Authorization: Bearer <key>".
#                   Without it the server would be open to anyone on the internet.
#   OLLAMA_MODEL    model to pull at start (default qwen2.5:3b, needs ~3 GB RAM)
#   PORT            set by Render

set -e

PORT="${PORT:-10000}"
MODEL="${OLLAMA_MODEL:-qwen2.5:3b}"

if [ -z "$OLLAMA_API_KEY" ]; then
    echo "WARNING: OLLAMA_API_KEY is not set; the API is open to anyone." >&2
    AUTH_CHECK=""
else
    AUTH_CHECK="if (\$http_authorization != \"Bearer ${OLLAMA_API_KEY}\") { return 401; }"
fi

cat > /etc/nginx/conf.d/ollama.conf <<EOF
server {
    listen ${PORT};
    client_max_body_size 10m;

    # For the platform's health check; tells nothing about the model
    location = /healthz {
        default_type text/plain;
        return 200 "ok";
    }

    location / {
        ${AUTH_CHECK}
        proxy_pass http://127.0.0.1:11434;
        # Ollama only accepts local Host headers when bound to 127.0.0.1
        proxy_set_header Host localhost;
        proxy_set_header Origin "";
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }
}
EOF

echo "Starting Ollama..."
ollama serve &
OLLAMA_PID=$!

until ollama list >/dev/null 2>&1; do
    sleep 2
done

# Listen before the (slow) model download, so the platform sees the port in time
echo "Starting nginx on port ${PORT}..."
nginx -g 'daemon off;' &

echo "Pulling ${MODEL}..."
ollama pull "${MODEL}"
echo "Ready: ${MODEL}"

wait $OLLAMA_PID
