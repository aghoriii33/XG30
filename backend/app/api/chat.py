# pyrefly: ignore [missing-import]
from fastapi import APIRouter, HTTPException, Depends
# pyrefly: ignore [missing-import]
from pydantic import BaseModel
from typing import List, Optional
from app.config import settings
from app.api.auth import get_current_user
# pyrefly: ignore [missing-import]
import openai
import logging

logger = logging.getLogger("chat")

router = APIRouter(prefix="/chat", tags=["chat"])

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    message: str
    model: str = "gpt-5" # gpt-5, claude, gemini, deepseek, grok
    history: List[ChatMessage] = []

class ChatResponse(BaseModel):
    reply: str
    model_used: str

def get_smart_mock_reply(message: str, model: str) -> str:
    message_lower = message.lower()
    
    # Custom greeting / vision trigger replies
    if "spending" in message_lower:
        return (
            "Based on your transaction logs from last month, you spent a total of **$1,245.50**.\n\n"
            "Here is the breakdown:\n"
            "* 🍔 **Food & Dining**: $420.30\n"
            "* 🚗 **Transport**: $180.20\n"
            "* 🏠 **Utilities**: $350.00\n"
            "* 🍿 **Entertainment**: $295.00\n\n"
            "This is **12% higher** than your average spending. I suggest setting a budget of $350 for Food this month."
        )
    
    if "ui inspiration" in message_lower or "design" in message_lower:
        return (
            "Here are three hot mobile design trends for 2026:\n\n"
            "1. **Bento Grid Layouts**: Organizing widgets into modular, clean grids. Very scanner-friendly!\n"
            "2. **Dark Glassmorphism**: Frosted glass panels over high-contrast glowing backgrounds (looks exactly like my current skin!).\n"
            "3. **Fluid Micro-animations**: Organic animations like morphing liquid orbs to signify AI states.\n\n"
            "Would you like me to generate a Flutter snippet for a glassmorphism container?"
        )

    if model == "grok":
        return (
            f"Oh, you want my Grok-style wisdom on: '{message}'? Let's be honest. "
            "Humans spent billions of years evolving to ask a super-intelligence this question. "
            "Well, here is the answer: it's all about efficiency, styling, and not writing bugs. "
            "Also, buy some premium fuel. Go team JARVIS!"
        )
    elif model == "claude":
        return (
            f"I have analyzed your request regarding: '{message}'.\n\n"
            "To address this comprehensively, we must divide the problem into three dimensions:\n"
            "1. **Architectural Foundations**: Ensure state management (Riverpod) and routing (GoRouter) remain modular.\n"
            "2. **Visual Fidelity**: Use customized shaders and CustomPaint for animations.\n"
            "3. **API Integrity**: Check validation rules and schema structures on the backend.\n\n"
            "Please let me know if you would like me to detail any of these points further."
        )
    elif model == "gemini":
        return (
            f"Greetings! Let's explore: '{message}'. 🚀\n\n"
            "Here is a summary of what you need to know:\n"
            "* **Concept**: Seamlessly bridging Flutter components with a FastAPI service.\n"
            "* **Key Takeaway**: Riverpod makes state flow extremely predictable and robust.\n"
            "* **Next Step**: Start testing the onboarding slider and check the Firebase mock token verify.\n\n"
            "I'm ready for the next query!"
        )
    elif model == "deepseek":
        return (
            f"```dart\n"
            f"// Code generation request: '{message}'\n"
            f"// Implementing premium widget\n"
            f"class JarvisPremiumWidget extends StatelessWidget {{\n"
            f"  const JarvisPremiumWidget({{super.key}});\n"
            f"  @override\n"
            f"  Widget build(BuildContext context) {{\n"
            f"    return Container(\n"
            f"      decoration: BoxDecoration(\n"
            f"        gradient: LinearGradient(\n"
            f"          colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],\n"
            f"        ),\n"
            f"        borderRadius: BorderRadius.circular(16),\n"
            f"      ),\n"
            f"      child: Center(child: Text('DeepSeek Optimization Active')),\n"
            f"    );\n"
            f"  }}\n"
            f"}}\n"
            f"```"
        )
    else: # gpt-5 or fallback
        return (
            f"JARVIS active. Regarding '{message}': I can confirm that the system is fully operational. "
            f"We are running in Simulation Mode, giving you maximum responsiveness. Let me know how I can "
            f"help you code, analyze documents, or schedule tasks today!"
        )

@router.post("")
async def chat_completion(req: ChatRequest, user: dict = Depends(get_current_user)):
    if settings.is_openai_mock:
        reply = get_smart_mock_reply(req.message, req.model)
        return ChatResponse(reply=reply, model_used=f"{req.model} (Simulated)")
    
    try:
        # Determine actual model mapping
        # GPT-5 and others mapping to standard OpenAI models since GPT-5 doesn't exist yet
        api_model = "gpt-4-turbo"
        if req.model == "gpt-5":
            api_model = "gpt-4-turbo"
        elif req.model == "claude":
            # If using custom LLMs or OpenAI compatible router
            api_model = "gpt-4-turbo"
            
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)
        
        # Prepare system prompt
        system_prompt = (
            "You are JARVIS, a highly advanced, premium AI assistant. "
            f"You are responding using the '{req.model}' persona. Style your response accordingly. "
            "Make responses sleek, formatted in markdown, and concise."
        )
        
        messages = [{"role": "system", "content": system_prompt}]
        for msg in req.history:
            messages.append({"role": msg.role, "content": msg.content})
        messages.append({"role": "user", "content": req.message})
        
        response = client.chat.completions.create(
            model=api_model,
            messages=messages
        )
        
        return ChatResponse(
            reply=response.choices[0].message.content,
            model_used=f"{req.model} ({api_model})"
        )
    except Exception as e:
        logger.error(f"Error calling OpenAI API: {e}. Falling back to Smart Simulator.")
        reply = get_smart_mock_reply(req.message, req.model)
        return ChatResponse(reply=reply + "\n\n*(Note: API call failed; running on smart simulation fallback)*", model_used=f"{req.model} (Simulated)")
