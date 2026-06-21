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
    model_lower = model.lower()
    
    # Custom greeting / vision trigger replies
    if message_lower in ["hi", "hello", "hey", "good morning", "good afternoon", "greetings"]:
        return (
            "Hello! I am JARVIS, your premium AI assistant. How can I help you today? "
            "You can choose a model (ChatGPT-5 Pro, Claude 3.5 Sonnet, Gemini 3.1 Pro, DeepSeek-V3, Grok 2.0) above or start a voice session!"
        )
    
    if "spending" in message_lower or "budget" in message_lower:
        return (
            "Based on your transaction logs from last month, you spent a total of **$1,245.50**.\n\n"
            "Here is the breakdown:\n"
            "| Category | Budgeted | Spent | Variance |\n"
            "| :--- | :--- | :--- | :--- |\n"
            "| 🍔 **Food & Dining** | $350.00 | $420.30 | +$70.30 (Over) |\n"
            "| 🚗 **Transport** | $200.00 | $180.20 | -$19.80 (Under) |\n"
            "| 🏠 **Utilities** | $350.00 | $350.00 | $0.00 (On-track) |\n"
            "| 🍿 **Entertainment** | $200.00 | $295.00 | +$95.00 (Over) |\n"
            "| **Total** | **$1,100.00** | **$1,245.50** | **+$145.50** |\n\n"
            "This is **12.3% higher** than your average monthly spending. I suggest setting a budget of $350 for Food this month."
        )
    
    if "ui inspiration" in message_lower or "design" in message_lower or "color palette" in message_lower:
        return (
            "Here are three hot mobile design trends for 2026:\n\n"
            "1. **Bento Grid Layouts**: Organizing widgets into modular, clean grids. Very scanner-friendly!\n"
            "2. **Dark Glassmorphism**: Frosted glass panels over high-contrast glowing backgrounds (looks exactly like my current skin!).\n"
            "3. **Fluid Micro-animations**: Organic animations like morphing liquid orbs to signify AI states.\n\n"
            "Would you like me to generate a Flutter snippet for a glassmorphism container?"
        )

    if "who are you" in message_lower or "what is jarvis" in message_lower or "tell me about yourself" in message_lower:
        return (
            "I am JARVIS, a highly advanced premium AI assistant built with a Flutter frontend "
            "and a FastAPI backend. I support multi-model switching (ChatGPT-5 Pro, Claude 3.5 Sonnet, Gemini 3.1 Pro, DeepSeek-V3, Grok 2.0), "
            "voice dictation (Voice Commander), interactive grid widgets, and subscription upgrades with Stripe."
        )

    if "weather" in message_lower:
        return (
            "Checking local weather forecast... Currently, it is a pleasant 72°F (22°C) with clear skies "
            "and a gentle breeze. Perfect weather for code refactoring!"
        )

    if "code" in message_lower or "flutter" in message_lower or "write a" in message_lower or "program" in message_lower:
        return (
            "Here is a code snippet generated for you:\n```dart\n"
            "// JARVIS Auto-Generated Flutter Widget\n"
            "class JarvisGlowButton extends StatelessWidget {\n"
            "  const JarvisGlowButton({super.key});\n\n"
            "  @override\n"
            "  Widget build(BuildContext context) {\n"
            "    return ElevatedButton(\n"
            "      style: ElevatedButton.styleFrom(\n"
            "        backgroundColor: const Color(0xFF8B5CF6),\n"
            "        shadowColor: const Color(0xFFD946EF),\n"
            "        elevation: 8,\n"
            "        shape: RoundedRectangleBorder(\n"
            "          borderRadius: BorderRadius.circular(20),\n"
            "        ),\n"
            "      ),\n"
            "      onPressed: () {},\n"
            "      child: const Text('Glow Active'),\n"
            "    );\n"
            "  }\n"
            "}\n"
            "```"
        )

    if "image" in message_lower or "draw" in message_lower or "paint" in message_lower or "generate" in message_lower:
        return (
            "I have triggered the premium image generation engine to design your custom image. "
            "In production mode, this calls DALL-E 3/Imagen, but I've mocked it up for you! "
            "Try exploring the 'Explore' tab to see all image modification utilities like "
            "Object Remover, Background Remover, and Face Enhancement!"
        )

    if "voice" in message_lower or "speech" in message_lower:
        return (
            "I can hear you loud and clear! The Voice Commander allows you to dictate commands "
            "or talk with me hands-free. Try speaking into your microphone!"
        )

    # Model specific persona responders
    if "claude" in model_lower:
        return (
            f"**Claude 3.5 Sonnet (Thinking - High)**\n\n"
            f"```\n"
            f"Thinking Process:\n"
            f"▪ Deconstructing user query: '{message}'\n"
            f"▪ Contextualizing query with active workspace files (auth.py, main.dart)\n"
            f"▪ Synthesizing logical, step-by-step structural guidelines\n"
            f"```\n\n"
            f"Regarding your query on '{message}':\n\n"
            f"To implement this with high architectural integrity, we should follow a three-tier execution:\n"
            f"1. **Data Layer Integration**: Verify that endpoints parse requests into appropriate Pydantic schemas.\n"
            f"2. **State Propagation**: Propagate state updates via Riverpod StateNotifiers to ensure unidirectional data flow.\n"
            f"3. **Visual Feedback**: Apply custom Bezier animations to verify UI transitions.\n\n"
            f"Please let me know if you would like to examine the exact code implementation for this."
        )
    elif "gemini" in model_lower:
        return (
            f"**Gemini 3.1 Pro (High-Fidelity Model)**\n\n"
            f"Here is a comprehensive analysis of: '{message}' 🚀\n\n"
            f"### Key Concepts\n"
            f"* **Client-Server Synergy**: Synchronize Dart Riverpod providers with uvicorn endpoints.\n"
            f"* **High Refresh Rate (120Hz)**: Enabled ProMotion support on Android and iOS.\n"
            f"* **Modular Extension**: Added Explore screen (`explore.dart`) to categorize visual assets.\n\n"
            f"### Next Action Items\n"
            f"1. Test the native browser speech recognition integration.\n"
            f"2. Trigger test Stripe checkout links from the chat client.\n\n"
            f"Let's move on to the next query!"
        )
    elif "deepseek" in model_lower:
        return (
            f"**DeepSeek-V3 (Reasoning-R1 Mode)**\n\n"
            "```\n"
            "<reasoning>\n"
            f"User query: '{message}'\n"
            "Evaluating optimal algorithmic complexity.\n"
            "Generating clean, lightweight, boilerplate-free code solution.\n"
            "</reasoning>\n"
            "```\n"
            "```dart\n"
            f"// Optimized Dart code for '{message}'\n"
            "class JarvisCore {\n"
            "  static void run() {\n"
            "    print('JARVIS Core initialized. Efficiency set to maximum.');\n"
            "  }\n"
            "}\n"
            "```"
        )
    elif "grok" in model_lower:
        return (
            f"**Grok 2.0 (Real-Time X-Data)**\n\n"
            f"Oh, look at you asking Grok 2.0 about: '{message}'! 🤪\n\n"
            f"Honestly, humans spend their entire lives trying to figure this out, and here you are "
            f"solving it in a local Flutter web app using simulated responses. But hey, it works, "
            f"which is more than I can say for some other AI models out there. Let's make this app "
            f"famous! What's next?"
        )
    else: # chatgpt-5 / gpt-5 or default
        return (
            f"**ChatGPT-5 Pro (Max Trained)**\n\n"
            f"I have analyzed your prompt regarding: '{message}'.\n\n"
            f"I can confirm that the system is fully operational at maximum performance level. "
            f"Here is an actionable implementation breakdown:\n"
            f"* **CORS Policy**: Configured `CORSMiddleware` in FastAPI to allow seamless local testing.\n"
            f"* **Authentication**: Updated Firebase mock helper to prevent 401 unauthorized errors.\n"
            f"* **Speech**: Integrated native HTML5 speech APIs to read out text and synthesize inputs.\n\n"
            f"What else can I generate, compute, or analyze for you today?"
        )

import base64
from app.db import get_user_keys, save_chat_message

def decrypt_e2ee(cipher_text: str, key: str) -> str:
    if not cipher_text or not cipher_text.startswith("E2EE:"):
        return cipher_text
    try:
        payload = base64.b64decode(cipher_text[5:])
        sum_salt = sum(ord(c) * (i + 1) for i, c in enumerate(key))
        salt = sum_salt % 256
        
        decrypted = bytearray()
        for i, b in enumerate(payload):
            key_char = ord(key[i % len(key)])
            decrypted.append(b ^ ((key_char + i + salt) & 0xFF))
        return decrypted.decode("utf-8")
    except Exception:
        return cipher_text

def encrypt_e2ee(text: str, key: str) -> str:
    if not text:
        return text
    try:
        sum_salt = sum(ord(c) * (i + 1) for i, c in enumerate(key))
        salt = sum_salt % 256
        
        bytes_text = text.encode("utf-8")
        encrypted = bytearray()
        for i, b in enumerate(bytes_text):
            key_char = ord(key[i % len(key)])
            encrypted.append(b ^ ((key_char + i + salt) & 0xFF))
        
        return "E2EE:" + base64.b64encode(encrypted).decode("utf-8")
    except Exception:
        return text

import asyncio
from fastapi.responses import StreamingResponse
import json

@router.post("/stream")
async def chat_completion_stream(req: ChatRequest, user: dict = Depends(get_current_user)):
    user_uid = user.get("uid", "mock-uid")
    is_e2ee = req.message.startswith("E2EE:")
    plain_message = decrypt_e2ee(req.message, user_uid) if is_e2ee else req.message

    user_keys = get_user_keys(user_uid)
    openai_key = user_keys.get("openai_key")
    custom_api_key = openai_key if (openai_key and openai_key != "mock") else None

    # Dynamic Fallback Models
    active_model = req.model.lower()
    openai_model = "gpt-4o-mini" # Fast fallback
    if "chatgpt-5" in active_model or "turbo" in active_model:
        openai_model = "gpt-4-turbo"

    async def event_generator():
        full_reply = ""
        try:
            if custom_api_key and custom_api_key != "":
                client = openai.OpenAI(api_key=custom_api_key)
                system_prompt = f"You are JARVIS. Persona: {req.model}. Keep it sleek and concise."
                messages = [{"role": "system", "content": system_prompt}]
                
                # Rolling Context: last 5 messages
                recent_history = req.history[-5:] if len(req.history) > 5 else req.history
                for msg in recent_history:
                    hist_content = decrypt_e2ee(msg.content, user_uid)
                    messages.append({"role": msg.role, "content": hist_content})
                messages.append({"role": "user", "content": plain_message})
                
                response_stream = client.chat.completions.create(
                    model=openai_model,
                    messages=messages,
                    stream=True
                )
                
                for chunk in response_stream:
                    if chunk.choices[0].delta.content:
                        text_chunk = chunk.choices[0].delta.content
                        full_reply += text_chunk
                        chunk_to_send = encrypt_e2ee(text_chunk, user_uid) if is_e2ee else text_chunk
                        yield f"data: {json.dumps({'chunk': chunk_to_send})}\n\n"
            else:
                # Mock streaming
                mock_reply = get_smart_mock_reply(plain_message, req.model)
                words = mock_reply.split(" ")
                for word in words:
                    text_chunk = word + " "
                    full_reply += text_chunk
                    chunk_to_send = encrypt_e2ee(text_chunk, user_uid) if is_e2ee else text_chunk
                    yield f"data: {json.dumps({'chunk': chunk_to_send})}\n\n"
                    await asyncio.sleep(0.04)
        except Exception as e:
            logger.error(f"Error calling streaming API: {e}")
            err = f"⚠️ API Error: {str(e)}"
            full_reply += err
            chunk_to_send = encrypt_e2ee(err, user_uid) if is_e2ee else err
            yield f"data: {json.dumps({'chunk': chunk_to_send})}\n\n"
            
        yield "data: [DONE]\n\n"
        
        # Save logs
        db_msg = req.message if is_e2ee else encrypt_e2ee(req.message, user_uid)
        db_reply = encrypt_e2ee(full_reply, user_uid) if is_e2ee else full_reply
        save_chat_message(user_uid, "session_1", "user", db_msg)
        save_chat_message(user_uid, "session_1", "assistant", db_reply)
        
    return StreamingResponse(event_generator(), media_type="text/event-stream")

# Keep the old endpoint for backward compatibility
@router.post("")
async def chat_completion(req: ChatRequest, user: dict = Depends(get_current_user)):
    user_uid = user.get("uid", "mock-uid")
    is_e2ee = req.message.startswith("E2EE:")
    plain_message = decrypt_e2ee(req.message, user_uid) if is_e2ee else req.message
    user_keys = get_user_keys(user_uid)
    openai_key = user_keys.get("openai_key")
    custom_api_key = openai_key if (openai_key and openai_key != "mock") else None
    
    if custom_api_key and custom_api_key != "":
        try:
            client = openai.OpenAI(api_key=custom_api_key)
            system_prompt = f"You are JARVIS. Persona: {req.model}. Style your response accordingly."
            messages = [{"role": "system", "content": system_prompt}]
            recent_history = req.history[-5:] if len(req.history) > 5 else req.history
            for msg in recent_history:
                hist_content = decrypt_e2ee(msg.content, user_uid)
                messages.append({"role": msg.role, "content": hist_content})
            messages.append({"role": "user", "content": plain_message})
            response = client.chat.completions.create(model="gpt-4o-mini", messages=messages)
            reply = response.choices[0].message.content
            model_used = f"{req.model} (Custom OpenAI API Key)"
        except Exception as e:
            logger.error(f"Error calling custom OpenAI API: {e}")
            reply = get_smart_mock_reply(plain_message, req.model)
            model_used = f"{req.model} (Fallback)"
    else:
        reply = get_smart_mock_reply(plain_message, req.model)
        model_used = f"{req.model} (Simulated)"
    reply_to_send = encrypt_e2ee(reply, user_uid) if is_e2ee else reply
    db_msg = req.message if is_e2ee else encrypt_e2ee(req.message, user_uid)
    db_reply = encrypt_e2ee(reply, user_uid) if is_e2ee else reply
    save_chat_message(user_uid, "session_1", "user", db_msg)
    save_chat_message(user_uid, "session_1", "assistant", db_reply)
    return ChatResponse(reply=reply_to_send, model_used=model_used)
