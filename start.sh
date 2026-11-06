#!/bin/sh

set -e

echo "Starting Ollama..."

ollama serve &
OLLAMA_PID=$!

echo "Waiting for Ollama..."

until ollama list >/dev/null 2>&1; do
    sleep 2
done

echo "Pulling Qwen2.5:3b..."

ollama pull qwen2.5:3b

echo "Starting API proxy on port ${PORT}..."

socat TCP-LISTEN:${PORT},fork,reuseaddr \
TCP:127.0.0.1:11434 &

wait $OLLAMA_PID