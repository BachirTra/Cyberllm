# Créez ou éditez le fichier script.sh
echo '#!/bin/bash' > script.sh
echo '' >> script.sh
echo 'log() {' >> script.sh
echo '    echo "[INFO] $1"' >> script.sh
echo '}' >> script.sh
echo '' >> script.sh
echo 'log "Downloading and installing Ollama..."' >> script.sh
echo '(curl -fsSL https://ollama.com/install.sh | sh && ollama serve > ollama.log 2>&1) &' >> script.sh
echo 'wait' >> script.sh
echo 'log "Starting Ollama..."' >> script.sh
echo 'ollama' >> script.sh
echo 'ollama run hf.co/bartowski/Llama-3.1-WhiteRabbitNeo-2-70B-GGUF:latest' >> script.sh
echo 'git clone https://github.com/BachirTra/Cyberllm' >> script.sh
echo 'cd Cyberllm || { log "Failed to change directory to Cyberllm"; exit 1; }' >> script.sh
echo 'ollama create test1 -f Modelfile' >> script.sh
echo 'pip install open-webui --ignore-installed blinker' >> script.sh
echo 'chmod +x script.sh' >> script.sh
echo 'log "Setup completed successfully."' >> script.sh

# Rendre le script exécutable
chmod +x script.sh

# Exécuter le script
./script.sh
