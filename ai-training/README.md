# 🇿🇼 Sisonke AI Model Training Pipeline

This directory contains the automated pipeline for training and fine-tuning the **Sisonke E-Friend** youth peer support model.

---

## 📁 Structure

```text
ai-training/
├── data/
│   ├── raw/                 # Downloaded public counseling datasets
│   └── processed/           # Filtered, sanitized ChatML JSONL training sets
├── scripts/
│   ├── download_datasets.py # Pulls datasets from Hugging Face
│   └── prepare_training_data.py # Filters clinical talk & injects Zim context
├── notebooks/
│   └── sisonke_efriend_qlora_colab.ipynb # Free Google Colab T4 GPU fine-tuning notebook
├── models/
│   └── Modelfile.template   # Ollama Modelfile configuration for the exported GGUF
└── README.md
```

---

## 🚀 Execution Steps

### 1. Download & Curate Data (Local Machine)
Run inside the virtual environment:
```powershell
ai-training\.venv\Scripts\python ai-training\scripts\download_datasets.py
ai-training\.venv\Scripts\python ai-training\scripts\prepare_training_data.py
```
This generates `ai-training/data/processed/sisonke_train.jsonl`.

### 2. Fine-Tune on Google Colab (Free T4 GPU - ~20 mins)
1. Go to [Google Colab](https://colab.research.google.com/) and click **Upload Notebook**.
2. Select `ai-training/notebooks/sisonke_efriend_qlora_colab.ipynb`.
3. Set runtime to **T4 GPU** (`Runtime > Change runtime type > T4 GPU`).
4. Run all cells. When prompted, upload `sisonke_train.jsonl`.
5. Colab will fine-tune the model with Unsloth and download the resulting `sisonke-efriend-1.5b-Q4_K_M.gguf` file to your PC.

### 3. Test Locally in Ollama
1. Move the downloaded `.gguf` file into `ai-training/models/`.
2. In `ai-training/models/`, run:
   ```bash
   ollama create sisonke-friend -f Modelfile.template
   ollama run sisonke-friend "I am stressed about my exam results."
   ```

### 4. Deploy to Production VPS
1. Install Ollama on your Linux VPS:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. Copy the `.gguf` and `Modelfile` to your VPS (`scp` or `rsync`):
   ```bash
   scp sisonke-efriend-1.5b-Q4_K_M.gguf Modelfile user@vps-ip:/opt/sisonke-models/
   ```
3. Create the model on the VPS:
   ```bash
   ollama create sisonke-friend -f Modelfile
   ```
4. Update your backend `.env`:
   ```env
   LOCAL_AI_ENABLED=true
   OLLAMA_BASE_URL=http://localhost:11434
   OLLAMA_CHAT_MODEL=sisonke-friend
   ```
