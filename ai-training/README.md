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

### 1. Build the datasets (Local Machine)
```powershell
ai-training\.venv\Scripts\python ai-training\scripts\generate_synthetic_data.py   # synthetic SFT/DPO + held-out eval prompts
ai-training\.venv\Scripts\python ai-training\scripts\build_dataset.py             # merges all sources + filters
```
Outputs in `ai-training/data/processed/`: `sisonke_train.jsonl`, `sisonke_val.jsonl`, `sisonke_dpo.jsonl`, `build_report.json`.
Held-out test prompts live in `ai-training/data/eval/` and are never trained on. Add your own reviewed conversations as ChatML `.jsonl` in `ai-training/data/custom/`.

> Synthetic data and Shona/Ndebele phrases must be reviewed by native speakers and a clinician before training.

### 2. Fine-Tune on Google Colab (Free T4 GPU)
1. Go to [Google Colab](https://colab.research.google.com/) and click **Upload Notebook**.
2. Select `ai-training/notebooks/sisonke_efriend_qlora_colab.ipynb` (regenerate with `scripts/build_notebook.py`).
3. Set runtime to **T4 GPU**.
4. Run all cells. Upload `sisonke_train.jsonl`, `sisonke_val.jsonl` and `sisonke_dpo.jsonl` when prompted.
5. Set `RUN_DPO = False` in Step 0 to export an SFT-only model for A/B comparison.
6. Colab exports a `.gguf` and downloads it.

### 2b. Evaluate on held-out prompts
```powershell
ai-training\.venv\Scripts\python ai-training\scripts\evaluate_model.py --model qwen2.5:1.5b --out base
ai-training\.venv\Scripts\python ai-training\scripts\evaluate_model.py --model sisonke-friend
```
Automatic checks only (length, no diagnosis, crisis hand-off, no invented numbers). Any failing crisis prompt blocks release.

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
