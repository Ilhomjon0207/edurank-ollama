FROM ollama/ollama:latest

# nginx sits in front of Ollama: Ollama bound to 127.0.0.1 answers 403 to any
# request whose Host is not local, and it has no authentication of its own.
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/default

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Render sets PORT; Ollama itself stays on the loopback address
ENV PORT=10000
ENV OLLAMA_HOST=127.0.0.1:11434
# Model to pull at start; it has to fit in the instance's memory
ENV OLLAMA_MODEL=qwen2.5:3b
# Keep the model loaded between requests
ENV OLLAMA_KEEP_ALIVE=30m

EXPOSE 10000

ENTRYPOINT ["/bin/sh", "/start.sh"]
