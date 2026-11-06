#!/bin/sh

set -e

ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama..."

until ollama list >/dev/null 2>&1; do
    sleep 2
done

echo "Pulling Qwen model..."

ollama pull qwen2.5:3b

echo "Starting API proxy..."

socat TCP-LISTEN:${PORT},fork,reuseaddr TCP:127.0.0.1:11434 &
PROXY_PID=$!

wait $OLLAMA_PID