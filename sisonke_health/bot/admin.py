from django.contrib import admin
from .models import ConversationSession, EscalationRequest, MessageLog


@admin.register(ConversationSession)
class ConversationSessionAdmin(admin.ModelAdmin):
    list_display  = ("phone_number", "turn_count", "updated_at")
    search_fields = ("phone_number",)
    readonly_fields = ("history", "created_at", "updated_at")

    def turn_count(self, obj):
        return len(obj.history)
    turn_count.short_description = "Turns"


@admin.register(EscalationRequest)
class EscalationRequestAdmin(admin.ModelAdmin):
    list_display  = ("phone_number", "status", "created_at")
    list_filter   = ("status",)
    search_fields = ("phone_number",)
    list_editable = ("status",)


@admin.register(MessageLog)
class MessageLogAdmin(admin.ModelAdmin):
    list_display  = ("phone_number", "direction", "short_body", "created_at")
    list_filter   = ("direction",)
    search_fields = ("phone_number", "body")
    readonly_fields = ("phone_number", "direction", "body", "created_at")

    def short_body(self, obj):
        return obj.body[:80]
    short_body.short_description = "Message"
