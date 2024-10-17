#!/bin/bash

log() {
    echo "[INFO] $1"
}

log "Downloading and installing Ollama..."
(curl -fsSL https://ollama.com/install.sh | sh && ollama serve > ollama.log 2>&1) &
wait
ollama run hf.co/bartowski/Llama-3.1-WhiteRabbitNeo-2-70B-GGUF:latest
git clone https://github.com/BachirTra/Cyberllm
cd Cyberllm || { log "Failed to change directory to Cyberllm"; exit 1; }
ollama create test1 -f Modelfile
pip install open-webui --ignore-installed blinker
log "Setup completed successfully."
