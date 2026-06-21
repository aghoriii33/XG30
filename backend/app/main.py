# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, chat, stripe
from app.config import settings
# pyrefly: ignore [missing-import]
import uvicorn
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("main")

app = FastAPI(
    title="JARVIS Premium AI Assistant API",
    description="Backend API serving LLM endpoints, auth verification, and Stripe payments.",
    version="1.0.0"
)

# Set up CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # For production, restrict this to the Flutter web/app origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router)
app.include_router(chat.router)
app.include_router(stripe.router)

@app.get("/")
async def root():
    return {
        "status": "online",
        "service": "JARVIS AI Assistant Backend",
        "openai_mode": "simulation" if settings.is_openai_mock else "production",
        "stripe_mode": "simulation" if settings.is_stripe_mock else "production",
        "firebase_mode": "simulation" if settings.is_firebase_mock else "production",
    }

if __name__ == "__main__":
    uvicorn.run("app.main:app", host=settings.HOST, port=settings.PORT, reload=True)
