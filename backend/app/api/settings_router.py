# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, HTTPException
# pyrefly: ignore [missing-import]
from pydantic import BaseModel
from typing import Optional
from app.api.auth import get_current_user
from app.db import save_user_keys, get_user_keys

router = APIRouter(prefix="/settings", tags=["settings"])

class UserKeysRequest(BaseModel):
    openai_key: Optional[str] = None
    gemini_key: Optional[str] = None

@router.post("/keys")
async def save_keys(req: UserKeysRequest, user: dict = Depends(get_current_user)):
    user_id = user.get("uid")
    save_user_keys(user_id, req.openai_key or "", req.gemini_key or "")
    return {"status": "success", "message": "API keys updated successfully"}

@router.get("/keys")
async def get_keys(user: dict = Depends(get_current_user)):
    user_id = user.get("uid")
    keys = get_user_keys(user_id)
    openai_key = keys.get("openai_key")
    gemini_key = keys.get("gemini_key")
    
    return {
        "openai_key_configured": bool(openai_key and openai_key != ""),
        "gemini_key_configured": bool(gemini_key and gemini_key != "")
    }
