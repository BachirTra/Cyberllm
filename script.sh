#!/bin/bash

log() {
    echo "[INFO] $1"
}

# Vérification des dépendances
command -v curl >/dev/null 2>&1 || { log "curl is required but not installed. Aborting."; exit 1; }
command -v pip >/dev/null 2>&1 || { log "pip is required but not installed. Aborting."; exit 1; }

# Installation d'Ollama
log "Downloading and installing Ollama..."
(curl -fsSL https://ollama.com/install.sh | sh) || { log "Failed to install Ollama"; exit 1; }

# Démarrage d'Ollama en arrière-plan
log "Starting Ollama in background..."
ollama serve > ollama.log 2>&1 &

# Vérification du démarrage d'Ollama
log "Waiting for Ollama to be ready on port 11434..."
for i in {1..10}; do
    if nc -z 127.0.0.1 11434; then
        log "Ollama is running and ready."
        break
    fi
    sleep 1
done


# Téléchargement du modèle
log "Downloading model..."
ollama run hf.co/bartowski/Llama-3.1-WhiteRabbitNeo-2-70B-GGUF:latest || { log "Model download failed"; exit 1; }


# Installer Open-WebUI dans un environnement virtuel
log "Setting up virtual environment and installing Open-WebUI..."
python3 -m venv venv
source venv/bin/activate
pip install open-webui --ignore-installed blinker || { log "Failed to install Open-WebUI"; exit 1; }


# Création du modèle
log "Creating model..."
ollama create test1 -f Modelfile || { log "Failed to create model"; exit 1; }