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

# Attendre quelques secondes pour s'assurer qu'Ollama est bien lancé
sleep 10



# Installer Open-WebUI dans un environnement virtuel
log "Setting up virtual environment and installing Open-WebUI..."
pip install open-webui --ignore-installed blinker || { log "Failed to install Open-WebUI"; exit 1; }


# Téléchargement du modèle
log "Downloading model..."
ollama run hf.co/bartowski/Llama-3.1-WhiteRabbitNeo-2-70B-GGUF:latest || { log "Model download failed"; exit 1; }

# Création du modèle
log "Creating model..."
ollama create test1 -f Modelfile || { log "Failed to create model"; exit 1; }

python -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requierements2.txt

apt update
apt upgrade
apt install snapd
apt install zaproxy

pip install --upgrade pip
python -m venv langchain_env
source langchain_env/bin/activate
langchain_env/bin/python -m ipykernel install --user --name=langchain_env
langchain_env/bin/pip install ipykernel

langchain_env/bin/pip install \
    langchain-core==0.2.39 \
    langchain-community==0.2.12 \
    langchain-text-splitters==0.2.4 \
    langchain==0.2.15 \
    langchain-groq \
    huggingface-hub \
    openai \
    requests \
    langdetect \
    fastapi \
    pydantic \
    sentence-transformers

jupyter notebook --port 8890
