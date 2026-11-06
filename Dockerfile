FROM ollama/ollama:latest

EXPOSE 10000

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["ollama serve & sleep 5 && ollama pull qwen2.5:3b && wait"]