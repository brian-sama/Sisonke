from django.db import models


class ConversationSession(models.Model):
    """Stores per-user conversation history for Claude context."""

    phone_number = models.CharField(max_length=20, unique=True, db_index=True)
    history      = models.JSONField(default=list)
    created_at   = models.DateTimeField(auto_now_add=True)
    updated_at   = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-updated_at"]

    def __str__(self):
        return f"Session({self.phone_number}, {len(self.history)} turns)"

    def add_message(self, role: str, content: str):
        """Append a message and trim to MAX_HISTORY_TURNS."""
        from django.conf import settings
        max_turns = getattr(settings, "MAX_HISTORY_TURNS", 20)
        self.history.append({"role": role, "content": content})
        if len(self.history) > max_turns:
            self.history = self.history[-max_turns:]
        self.save(update_fields=["history", "updated_at"])

    def clear(self):
        self.history = []
        self.save(update_fields=["history", "updated_at"])

    @classmethod
    def get_or_create_session(cls, phone: str):
        session, _ = cls.objects.get_or_create(phone_number=phone)
        return session


class EscalationRequest(models.Model):
    """Tracks users who requested to speak to a human health worker."""

    STATUS_CHOICES = [
        ("pending",  "Pending"),
        ("assigned", "Assigned"),
        ("resolved", "Resolved"),
    ]

    phone_number = models.CharField(max_length=20, db_index=True)
    status       = models.CharField(max_length=20, choices=STATUS_CHOICES, default="pending")
    note         = models.TextField(blank=True)
    created_at   = models.DateTimeField(auto_now_add=True)
    updated_at   = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Escalation({self.phone_number}, {self.status})"


class MessageLog(models.Model):
    """Audit log of every inbound/outbound message."""

    DIRECTION_CHOICES = [("in", "Inbound"), ("out", "Outbound")]

    phone_number = models.CharField(max_length=20, db_index=True)
    direction    = models.CharField(max_length=3, choices=DIRECTION_CHOICES)
    body         = models.TextField()
    created_at   = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"[{self.direction.upper()}] {self.phone_number}: {self.body[:60]}"
