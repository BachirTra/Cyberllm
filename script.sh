#!/bin/bash

log() {
    echo "[INFO] $1"
}

# Vérification des dépendances
command -v git >/dev/null 2>&1 || { log "git is required but not installed. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { log "curl is required but not installed. Aborting."; exit 1; }
command -v pip >/dev/null 2>&1 || { log "pip is required but not installed. Aborting."; exit 1; }

# Installation d'Ollama
log "Downloading and installing Ollama..."
(curl -fsSL https://ollama.com/install.sh | sh && ollama serve > ollama.log 2>&1) || { log "Failed to install Ollama"; exit 1; }

# Démarrage d'Ollama
log "Starting Ollama..."
ollama &

# Vérification du démarrage d'Ollama
log "Waiting for Ollama to start..."
for i in {1..10}; do
    if pgrep -x "ollama" > /dev/null; then
        log "Ollama started successfully."
        break
    fi
    sleep 1
done

# Téléchargement du modèle
log "Downloading model..."
ollama run hf.co/bartowski/Llama-3.1-WhiteRabbitNeo-2-70B-GGUF:latest || { log "Model download failed"; exit 1; }

# Clonage du dépôt Cyberllm
log "Cloning repository..."
git clone https://github.com/BachirTra/Cyberllm || { log "Failed to clone repository Cyberllm"; exit 1; }
cd Cyberllm || { log "Failed to change directory to Cyberllm"; exit 1; }

# Création du modèle
log "Creating model..."
ollama create test1 -f Modelfile || { log "Failed to create model"; exit 1; }

# Installer Open-WebUI dans un environnement virtuel
log "Setting up virtual environment and installing Open-WebUI..."
python3 -m venv venv
source venv/bin/activate
pip install open-webui --ignore-installed blinker || { log "Failed to install Open-WebUI"; exit 1; }

# Vérifier les permissions du script
chmod +x script.sh
log "Setup completed successfully."