# Sisonke Health Coach — WhatsApp Bot

A Django-based AI health chatbot powered by Claude (Anthropic), connected to WhatsApp via the Meta Cloud API.

---

## Quick start

### 1. Install dependencies

```bash
cd sisonke_health
pip install -r requirements.txt
```

### 2. Configure environment

Edit `.env` and fill in your keys:

```
ANTHROPIC_API_KEY=sk-ant-...          # from console.anthropic.com
META_ACCESS_TOKEN=EAAS...             # from Meta developer portal (Step 1)
META_PHONE_NUMBER_ID=1040293172504700 # already filled from your setup
META_VERIFY_TOKEN=sisonke_health_verify_2024  # any string you choose
```

### 3. Set up the database

```bash
python manage.py migrate
python manage.py createsuperuser   # for the admin dashboard
```

### 4. Run the server

```bash
python manage.py runserver
```

### 5. Expose to the internet (for Meta webhook)

```bash
ngrok http 8000
```

Copy the ngrok HTTPS URL (e.g. `https://abc123.ngrok.io`) and set your webhook in the Meta developer portal:

- Webhook URL: `https://abc123.ngrok.io/webhook/`
- Verify token: `sisonke_health_verify_2024`
- Subscribe to: `messages`

---

## Project structure

```
sisonke_health/
├── .env                          # your secrets (never commit this)
├── requirements.txt
├── manage.py
├── sisonke_health/
│   ├── settings.py
│   └── urls.py
└── bot/
    ├── models.py                 # ConversationSession, EscalationRequest, MessageLog
    ├── views.py                  # webhook handler
    ├── admin.py                  # admin dashboard
    ├── urls.py
    └── services/
        ├── claude_service.py     # Anthropic API calls
        └── whatsapp_service.py   # Meta Graph API calls
```

---

## Admin dashboard

Visit `http://localhost:8000/admin/` to:
- View all conversation sessions and history
- Manage escalation requests (mark as resolved)
- Browse the full message audit log

---

## Escalation triggers

Users who type any of the following are flagged for human follow-up:

`help` · `HELP` · `3` · `option 3` · `speak to someone` · `real person` · `human`

An `EscalationRequest` record is created and the user receives the helpline number.

---

## Going to production

1. Generate a **permanent access token** in Meta Step 2
2. Register your real Zimbabwean phone number
3. Complete Meta **business verification**
4. Change `DEBUG=False` in `.env`
5. Set a strong `SECRET_KEY`
6. Deploy with `gunicorn sisonke_health.wsgi`
