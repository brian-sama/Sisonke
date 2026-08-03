"""
Meta WhatsApp Cloud API service layer.
Handles sending messages back to users via the Graph API.
"""
import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

GRAPH_API_URL = "https://graph.facebook.com/v22.0"


def send_text_message(phone: str, text: str) -> bool:
    """
    Send a plain text WhatsApp message to a phone number.

    Args:
        phone: recipient phone number with country code, e.g. "263771234567"
        text:  message body (keep under 4096 chars for WhatsApp)

    Returns:
        True if the API accepted the message, False otherwise.
    """
    url = f"{GRAPH_API_URL}/{settings.META_PHONE_NUMBER_ID}/messages"
    headers = {
        "Authorization": f"Bearer {settings.META_ACCESS_TOKEN}",
        "Content-Type": "application/json",
    }
    payload = {
        "messaging_product": "whatsapp",
        "to": phone,
        "type": "text",
        "text": {"body": text},
    }

    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=10)
        resp.raise_for_status()
        logger.info("Message sent to %s", phone)
        return True
    except requests.RequestException as e:
        logger.error("Failed to send message to %s: %s", phone, e)
        return False


def mark_as_read(message_id: str) -> None:
    """Mark an incoming message as read (shows blue ticks to the user)."""
    url = f"{GRAPH_API_URL}/{settings.META_PHONE_NUMBER_ID}/messages"
    headers = {
        "Authorization": f"Bearer {settings.META_ACCESS_TOKEN}",
        "Content-Type": "application/json",
    }
    payload = {
        "messaging_product": "whatsapp",
        "status": "read",
        "message_id": message_id,
    }
    try:
        requests.post(url, headers=headers, json=payload, timeout=5)
    except requests.RequestException:
        pass


def extract_message(data: dict) -> dict | None:
    """
    Parse the Meta webhook payload and return a simplified message dict.

    Returns:
        {"from": phone, "text": body, "message_id": id} or None if not a text message.
    """
    try:
        entry   = data["entry"][0]
        changes = entry["changes"][0]["value"]

        if "messages" not in changes:
            return None

        msg = changes["messages"][0]

        if msg.get("type") != "text":
            return None

        return {
            "from":       msg["from"],
            "text":       msg["text"]["body"].strip(),
            "message_id": msg["id"],
        }
    except (KeyError, IndexError):
        return None
