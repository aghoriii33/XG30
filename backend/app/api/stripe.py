# pyrefly: ignore [missing-import]
from fastapi import APIRouter, HTTPException, Depends
# pyrefly: ignore [missing-import]
from pydantic import BaseModel
from app.config import settings
from app.api.auth import get_current_user
# pyrefly: ignore [missing-import]
import stripe

router = APIRouter(prefix="/stripe", tags=["stripe"])

if not settings.is_stripe_mock:
    stripe.api_key = settings.STRIPE_API_KEY

class CheckoutRequest(BaseModel):
    success_url: str
    cancel_url: str

@router.post("/create-checkout")
async def create_checkout(req: CheckoutRequest, user: dict = Depends(get_current_user)):
    if settings.is_stripe_mock:
        return {
            "session_id": "mock_session_12345",
            "url": f"{req.success_url}?session_id=mock_session_12345"
        }
    
    try:
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': 'usd',
                    'product_data': {
                        'name': 'JARVIS Pro Subscription',
                        'description': 'Access to GPT-5, Claude, Gemini Pro, and workspaces',
                    },
                    'unit_amount': 2000, # $20.00
                    'recurring': {
                        'interval': 'month',
                    },
                },
                'quantity': 1,
            }],
            mode='subscription',
            success_url=req.success_url + "?session_id={CHECKOUT_SESSION_ID}",
            cancel_url=req.cancel_url,
            client_reference_id=user.get("uid"),
            customer_email=user.get("email")
        )
        return {
            "session_id": session.id,
            "url": session.url
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/subscription-status")
async def get_subscription_status(user: dict = Depends(get_current_user)):
    # By default in mock mode, users are treated as Pro if they pass 'pro' in authorization token, or they get basic status
    is_pro = user.get("role") == "pro" or settings.is_stripe_mock
    return {
        "status": "active" if is_pro else "inactive",
        "plan": "pro" if is_pro else "free"
    }
