FROM ollama/ollama:latest

RUN apt-get update && \
    apt-get install -y socat && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh

RUN chmod +x /start.sh

ENV PORT=10000
ENV OLLAMA_HOST=127.0.0.1:11434

EXPOSE 10000

ENTRYPOINT ["/bin/sh", "/start.sh"]