"""
Webhook views for the WhatsApp bot.

GET  /webhook/  — Meta verification handshake (one-time setup)
POST /webhook/  — incoming messages from WhatsApp users
GET  /          — simple status page
"""
import json
import logging

from django.conf import settings
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

from .models import ConversationSession, EscalationRequest, MessageLog
from .services.claude_service import get_ai_response, is_escalation_request
from .services.whatsapp_service import extract_message, mark_as_read, send_text_message

logger = logging.getLogger(__name__)

WELCOME_MESSAGE = (
    "Hi! Welcome to *Sisonke Health Coach* — your free, private health assistant.\n\n"
    "I can help you with:\n"
    "• Sexual health & relationships\n"
    "• HIV & TB information\n"
    "• Mental wellbeing\n"
    "• General health questions\n\n"
    "Just ask me anything — there are no bad questions.\n\n"
    "_Type *HELP* at any time to speak to a real health worker._"
)

ESCALATION_MESSAGE = (
    "A health worker will contact you as soon as possible — usually within a few hours.\n\n"
    "Your conversation is completely private.\n\n"
    "If you need help right now, call the free helpline:\n"
    "*0800 100 100* (24/7, free)\n\n"
    "You can keep chatting with me in the meantime."
)

FALLBACK_MESSAGE = (
    "Sorry, I'm having trouble right now. Please try again in a moment.\n"
    "For urgent help, call *0800 100 100* (free, 24/7)."
)

GREETING_KEYWORDS = {"hi", "hello", "hey", "start", "hie", "sawubona", "mhoro"}


def _is_greeting(text: str) -> bool:
    return text.strip().lower() in GREETING_KEYWORDS


# ── Status page ──────────────────────────────────────────────────────────────

def index(request):
    return HttpResponse(
        "<h2>Sisonke Health Coach — running</h2>"
        "<p>Webhook endpoint: <code>/webhook/</code></p>",
        content_type="text/html",
    )


# ── Webhook ──────────────────────────────────────────────────────────────────

@csrf_exempt
@require_http_methods(["GET", "POST"])
def webhook(request):
    if request.method == "GET":
        return _verify_webhook(request)
    return _handle_incoming(request)


def _verify_webhook(request):
    """
    Meta calls this once when you save the webhook URL in the developer portal.
    It sends hub.verify_token — we echo back hub.challenge if it matches.
    """
    mode      = request.GET.get("hub.mode")
    token     = request.GET.get("hub.verify_token")
    challenge = request.GET.get("hub.challenge")

    if mode == "subscribe" and token == settings.META_VERIFY_TOKEN:
        logger.info("Webhook verified successfully")
        return HttpResponse(challenge, status=200)

    logger.warning("Webhook verification failed — token mismatch")
    return HttpResponse("Forbidden", status=403)


def _handle_incoming(request):
    """Process an inbound message from Meta."""
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid json"}, status=400)

    msg = extract_message(data)
    if msg is None:
        return JsonResponse({"status": "ignored"})

    phone      = msg["from"]
    text       = msg["text"]
    message_id = msg["message_id"]

    # Show blue ticks immediately
    mark_as_read(message_id)

    # Audit log
    MessageLog.objects.create(phone_number=phone, direction="in", body=text)

    # ── Greeting → send welcome and reset session ────────────────────────────
    if _is_greeting(text):
        session = ConversationSession.get_or_create_session(phone)
        session.clear()
        _send(phone, WELCOME_MESSAGE)
        return JsonResponse({"status": "greeted"})

    # ── Escalation → hand off to human health worker ────────────────────────
    if is_escalation_request(text):
        EscalationRequest.objects.create(phone_number=phone)
        _send(phone, ESCALATION_MESSAGE)
        logger.info("Escalation created for %s", phone)
        return JsonResponse({"status": "escalated"})

    # ── Normal conversation → pass to Claude ────────────────────────────────
    session = ConversationSession.get_or_create_session(phone)
    session.add_message("user", text)

    try:
        reply = get_ai_response(session.history)
    except Exception as e:
        logger.error("Claude API error for %s: %s", phone, e)
        reply = FALLBACK_MESSAGE

    session.add_message("assistant", reply)
    _send(phone, reply)

    return JsonResponse({"status": "ok"})


def _send(phone: str, text: str):
    """Send a message and log it."""
    ok = send_text_message(phone, text)
    if ok:
        MessageLog.objects.create(phone_number=phone, direction="out", body=text)
