import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain_ollama.llms import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate
from langchain.agents import initialize_agent, Tool

from langchain_community.tools import DuckDuckGoSearchResults

from langchain.prompts import PromptTemplate
from dotenv import load_dotenv
import time
from typing import List, Dict
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
import pytz
from datetime import datetime
import locale

# Charger les variables d'environnement
load_dotenv()
ollama_base_url = os.getenv("OLLAMA_BASE_URL")

# Initialisation de l'API FastAPI
app = FastAPI()

# Configurer CORS
origins = [
    "http://localhost:4200",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialisation du modèle Ollama
ollama_llm = OllamaLLM(
    base_url=ollama_base_url,
    model="test1:latest",  # Modèle spécifique
    temperature=0.3,
    max_tokens=5000
)

# Initialiser le modèle d'embeddings multilingue
embedding_model = SentenceTransformer('distiluse-base-multilingual-cased-v1')

# Variables globales pour stocker l'historique
history: Dict[str, List[Dict[str, str]]] = {}

# Nouveau template basé sur le modèle importé
system_prompt_template = ChatPromptTemplate.from_template("""
{{ if .System }}<|start_header_id|>system<|end_header_id|>

{{ .System }}<|eot_id|>{{ end }}{{ if .Prompt }}<|start_header_id|>user<|end_header_id|>

{{ .Prompt }}<|eot_id|>{{ end }}<|start_header_id|>assistant<|end_header_id|>

{{ .Response }}<|eot_id|>
""")

# Fonction pour récupérer la date et l'heure actuelles selon le fuseau horaire
def get_current_datetime(timezone: str) -> str:
    tz = pytz.timezone(timezone)
    current_time = datetime.now(tz)
    locale.setlocale(locale.LC_TIME, "fr_FR.UTF-8")
    return current_time.strftime('%Y-%m-%d %H:%M:%S')

# Initialisation des outils pour Langchain
tools = [
    Tool(
        name="Recherche Web",
        func=DuckDuckGoSearchResults().run,
        description="Utiliser la recherche Web pour obtenir des informations supplémentaires."
    )
]

# Configuration de l'agent Langchain
def create_agent():
    agent = initialize_agent(
        tools=tools,
        llm=ollama_llm,
        agent="zero-shot-react-description",  # Type d'agent Langchain
        verbose=True
    )
    return agent

# Modèle de requête pour l'API
class QueryRequest(BaseModel):
    prompt: str
    session_id: str
    temperature: float = 0.3
    max_tokens: int = 500
    timezone: str = 'UTC'

# Route POST pour analyser les vulnérabilités
@app.post("/analyze_vulnerabilities")
def analyze_vulnerabilities(request: QueryRequest):
    prompt = request.prompt
    session_id = request.session_id
    temperature = request.temperature
    max_tokens = request.max_tokens
    timezone = request.timezone

    if not prompt:
        raise HTTPException(status_code=400, detail="Prompt is required")

    if session_id not in history:
        history[session_id] = []

    system_prompt = system_prompt_template.format(input=prompt)

    current_datetime = get_current_datetime(timezone)

    start_time = time.process_time()

    try:
        # Créer et interroger l'agent avec le prompt
        agent = create_agent()
        response = agent.run(system_prompt)

        # Stockage des réponses
        history[session_id].append({
            "prompt": prompt,
            "response": response
        })

        response_time = time.process_time() - start_time

        return {
            "vulnerability_report": f"Here is the analysis (as of {current_datetime}, Timezone: {timezone}):\n{response}",
            "response_time": response_time,
            "history": history[session_id]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Route GET pour récupérer l'historique des sessions
@app.get("/history/{session_id}")
def get_history(session_id: str):
    if session_id not in history:
        raise HTTPException(status_code=404, detail="No history found for this session.")
    return {"history": history[session_id]}

# Lancement de l'application avec FastAPI
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
