# Local AI Development Setup

This project can use Ollama for local E-Friend development responses.

Installed light models for this Dell Latitude 5430:

```text
qwen2.5:1.5b  - default E-Friend dev model, about 986 MB
qwen2.5:0.5b  - tiny fallback model, about 397 MB
```

Recommended backend `.env` values:

```text
LOCAL_AI_ENABLED=true
OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_CHAT_MODEL=qwen2.5:1.5b
OLLAMA_TIMEOUT_MS=12000
```

Useful commands:

```powershell
& "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" list
& "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" serve
& "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe" run qwen2.5:1.5b
```

Safety rule: the backend risk detector runs before the local model response is used. High-risk messages skip local AI and escalate to a counselor case.
