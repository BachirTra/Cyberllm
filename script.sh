#!/bin/bash

log() {
    echo "[INFO] $1"
}

log "Downloading and installing Ollama..."
(curl -fsSL https://ollama.com/install.sh | sh && ollama serve > ollama.log 2>&1) &
wait

# Lancer Ollama
log "Starting Ollama..."
ollama &  # Exécuter Ollama en arrière-plan

# Attendre quelques secondes pour s'assurer qu'Ollama est bien lancé
sleep 5

# Télécharger le modèle
ollama run hf.co/bartowski/Llama-3.1-WhiteRabbitNeo-2-70B-GGUF:latest

# Cloner le dépôt Cyberllm
git clone https://github.com/BachirTra/Cyberllm
cd Cyberllm || { log "Failed to change directory to Cyberllm"; exit 1; }

# Créer le modèle
ollama create test1 -f Modelfile

# Installer Open-WebUI
pip install open-webui --ignore-installed blinker

# Vérifier les permissions du script
chmod +x script.sh
log "Setup completed successfully."
