# pyrefly: ignore [missing-import]
from fastapi import APIRouter, HTTPException, Header, Depends
from typing import Optional
from app.config import settings
import logging

logger = logging.getLogger("auth")

router = APIRouter(prefix="/auth", tags=["auth"])

# Optional Firebase Init
firebase_app = None
if not settings.is_firebase_mock:
    try:
        # pyrefly: ignore [missing-import]
        import firebase_admin
        # pyrefly: ignore [missing-import]
        from firebase_admin import credentials, auth
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
        firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase successfully initialized.")
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin SDK: {e}. Switching to mock.")

async def get_current_user(authorization: Optional[str] = Header(None)) -> dict:
    if not authorization or not authorization.startswith("Bearer "):
        if settings.is_firebase_mock or not firebase_app:
            return {
                "uid": "mock-guest-uid-123",
                "email": "alex.smith@example.com",
                "name": "Alex Smith",
                "email_verified": True,
                "role": "pro"
            }
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
    
    token = authorization.split("Bearer ")[1]
    
    if settings.is_firebase_mock or not firebase_app:
        # Mock verification for testing
        if token == "mock-expired-token":
            raise HTTPException(status_code=401, detail="Token expired")
        return {
            "uid": f"mock-uid-{token[:8]}",
            "email": "michael.assistant@example.com",
            "name": "Michael",
            "email_verified": True,
            "role": "pro" if "pro" in token else "free"
        }
    
    try:
        # pyrefly: ignore [missing-import]
        from firebase_admin import auth
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")

@router.post("/verify")
async def verify_token(user: dict = Depends(get_current_user)):
    return {
        "status": "success",
        "user": {
            "uid": user.get("uid"),
            "email": user.get("email"),
            "name": user.get("name", "User"),
            "email_verified": user.get("email_verified", False)
        }
    }
