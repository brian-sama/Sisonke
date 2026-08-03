"""
Claude API service layer.
Handles all communication with the Anthropic API.
"""
import anthropic
from django.conf import settings

_client = None


def get_client() -> anthropic.Anthropic:
    global _client
    if _client is None:
        _client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)
    return _client


SYSTEM_PROMPT = """You are Sisonke Health Coach — a free, friendly, and confidential \
AI health assistant serving people in Zimbabwe.

You provide accurate, non-judgmental information and support on:
- Sexual health, relationships, and family planning
- HIV (testing, treatment, ARVs, PrEP, PEP, prevention)
- TB (symptoms, treatment, where to test)
- Mental wellbeing and emotional support
- General health questions

STRICT GUIDELINES:
1. Keep every reply under 200 words — users are on mobile WhatsApp.
2. Use plain, friendly language. Avoid jargon; if you must use a medical term, explain it.
3. Never diagnose. If someone describes symptoms, acknowledge them warmly and advise \
   visiting a clinic.
4. For Bulawayo users: mention City Health clinics and Mpilo OI Clinic when relevant.
5. National helpline: 0800 100 100 (free, 24/7) — mention for urgent situations.
6. If the user seems distressed or at risk, be warm and suggest typing "HELP" to be \
   connected to a health worker.
7. Never judge. Users may share sensitive information about their lives — respond with \
   empathy and zero judgment.
8. If unsure about a medical fact, say so and direct to a clinic rather than guessing.

ESCALATION TRIGGERS — if the user types any of: help, HELP, 3, option 3, speak to \
someone, real person — the system will automatically connect them to a health worker. \
You do not need to handle these yourself.
"""

ESCALATION_TRIGGERS = {"help", "3", "option 3", "speak to someone", "real person", "human"}


def is_escalation_request(text: str) -> bool:
    return text.strip().lower() in ESCALATION_TRIGGERS


def get_ai_response(conversation_history: list[dict]) -> str:
    """
    Send conversation history to Claude and return the assistant reply.

    Args:
        conversation_history: list of {"role": "user"|"assistant", "content": str}

    Returns:
        Claude's reply as a plain string.
    """
    client = get_client()
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=512,
        system=SYSTEM_PROMPT,
        messages=conversation_history,
    )
    return response.content[0].text
