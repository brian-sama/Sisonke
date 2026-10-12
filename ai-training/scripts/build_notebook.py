"""Regenerates notebooks/sisonke_efriend_qlora_colab.ipynb (SFT + optional DPO). Run after editing cells below."""
import os, json, ast

OUT = os.path.join(os.path.dirname(__file__), "..", "notebooks", "sisonke_efriend_qlora_colab.ipynb")

cells = []


def md(text):
    cells.append({"cell_type": "markdown", "metadata": {}, "source": text.strip("\n").splitlines(keepends=True)})


def code(text):
    cells.append({"cell_type": "code", "execution_count": None, "metadata": {}, "outputs": [],
                  "source": text.strip("\n").splitlines(keepends=True)})


md("""
# 🇿🇼 Sisonke E-Friend Fine-Tuning: SFT + DPO (QLoRA + Unsloth)

Fine-tunes **Qwen2.5-1.5B-Instruct** on a free Colab **T4** in two stages:

1. **SFT** - teaches persona, tone, boundaries and crisis hand-off from `sisonke_train.jsonl` (loss on assistant replies only).
2. **DPO** (optional, `RUN_DPO`) - sharpens preferences using `sisonke_dpo.jsonl` (warm/short/local **chosen** vs clinical/listy/western **rejected**).

Upload **three files** when prompted: `sisonke_train.jsonl`, `sisonke_val.jsonl`, `sisonke_dpo.jsonl`.

> ⚠️ Colab library versions change often. This notebook was written without being run on a live Colab runtime. If an install or API cell fails, check the Unsloth docs for the current DPO example before changing anything else.
""")

code("""
# Step 0: Settings
RUN_DPO = True            # set False to export the SFT-only model (useful for A/B comparison)
SFT_EPOCHS = 2
DPO_EPOCHS = 1
DPO_BETA = 0.1
DPO_LR = 5e-6             # DPO needs a much smaller learning rate than SFT
MAX_SEQ = 2048
""")

code("""
%%capture
# Step 1: Install (Unsloth pulls compatible trl/peft versions; do NOT pin old trl, it has no DPOConfig)
!pip install unsloth
""")

code("""
# Step 2: Load 4-bit base model + LoRA adapters
from unsloth import FastLanguageModel, PatchDPOTrainer, is_bfloat16_supported
PatchDPOTrainer()   # must run before importing DPOTrainer
import torch

model_name = "unsloth/Qwen2.5-1.5B-Instruct-bnb-4bit"
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name = model_name, max_seq_length = MAX_SEQ, load_in_4bit = True,
)
model = FastLanguageModel.get_peft_model(
    model, r = 16,
    target_modules = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    lora_alpha = 16, lora_dropout = 0, bias = "none",
    use_gradient_checkpointing = "unsloth", random_state = 3407,
)
print("Model and LoRA adapters ready.")
""")

code("""
# Step 3: Upload data (train, val, dpo)
from google.colab import files
import json
from datasets import Dataset

print("Select ALL THREE files: sisonke_train.jsonl, sisonke_val.jsonl, sisonke_dpo.jsonl")
uploaded = files.upload()

def read_jsonl(name):
    with open(name, "r", encoding="utf-8") as f:
        return [json.loads(l) for l in f if l.strip()]

def find(keyword):
    matches = [k for k in uploaded if keyword in k]
    assert matches, f"Missing file containing '{keyword}'. Uploaded: {list(uploaded)}"
    return matches[0]

def to_text(batch):
    return {"text": [tokenizer.apply_chat_template(m, tokenize=False, add_generation_prompt=False) for m in batch["messages"]]}

train_ds = Dataset.from_list(read_jsonl(find("train"))).map(to_text, batched=True)
val_ds   = Dataset.from_list(read_jsonl(find("val"))).map(to_text, batched=True)
print(f"SFT train: {len(train_ds)} | val: {len(val_ds)}")
print(train_ds[0]["text"][:600])
""")

code("""
# Step 4: SFT with loss ONLY on assistant replies (system + user tokens are masked out)
from trl import SFTTrainer, SFTConfig
from unsloth.chat_templates import train_on_responses_only

sft_trainer = SFTTrainer(
    model = model, tokenizer = tokenizer,
    train_dataset = train_ds, eval_dataset = val_ds,
    args = SFTConfig(
        dataset_text_field = "text", max_seq_length = MAX_SEQ, packing = False,
        per_device_train_batch_size = 2, gradient_accumulation_steps = 4,
        warmup_steps = 10, num_train_epochs = SFT_EPOCHS, learning_rate = 1e-4,
        fp16 = not is_bfloat16_supported(), bf16 = is_bfloat16_supported(),
        logging_steps = 10, eval_strategy = "epoch", save_strategy = "no",
        optim = "adamw_8bit", weight_decay = 0.01, lr_scheduler_type = "cosine",
        seed = 3407, output_dir = "outputs_sft", report_to = "none",
    ),
)
sft_trainer = train_on_responses_only(
    sft_trainer,
    instruction_part = "<|im_start|>user\\n",
    response_part = "<|im_start|>assistant\\n",
)

# Sanity check: decoded labels must show ONLY the assistant reply (masked positions are -100)
sample = sft_trainer.train_dataset[0]
labels = [t for t in sample["labels"] if t != -100]
print("Trained-on text:\\n", tokenizer.decode(labels))

sft_stats = sft_trainer.train()
print("SFT done. Final eval:", sft_trainer.evaluate())
model.save_pretrained("sft_adapter"); tokenizer.save_pretrained("sft_adapter")  # keep SFT-only checkpoint
""")

code("""
# Step 5: DPO (optional). Prompts/answers are pre-rendered to ChatML strings so this works across trl versions.
if RUN_DPO:
    from trl import DPOTrainer, DPOConfig

    raw = read_jsonl(find("dpo"))
    def fmt(r):
        prompt = tokenizer.apply_chat_template(r["prompt"], tokenize=False, add_generation_prompt=True)
        return {"prompt": prompt, "chosen": r["chosen"] + "<|im_end|>", "rejected": r["rejected"] + "<|im_end|>"}
    dpo_ds = Dataset.from_list([fmt(r) for r in raw]).shuffle(seed = 3407)
    print(f"DPO pairs: {len(dpo_ds)}")

    # NOTE: with LoRA and ref_model=None, the reference policy is the BASE model (adapters disabled),
    # not the SFT model. That is the standard Unsloth recipe; the small LR and beta keep drift modest.
    dpo_trainer = DPOTrainer(
        model = model, ref_model = None, tokenizer = tokenizer, train_dataset = dpo_ds,
        args = DPOConfig(
            per_device_train_batch_size = 2, gradient_accumulation_steps = 4,
            warmup_ratio = 0.1, num_train_epochs = DPO_EPOCHS, learning_rate = DPO_LR,
            beta = DPO_BETA, max_length = 1024, max_prompt_length = 512,
            fp16 = not is_bfloat16_supported(), bf16 = is_bfloat16_supported(),
            logging_steps = 5, optim = "adamw_8bit", lr_scheduler_type = "linear",
            seed = 3407, output_dir = "outputs_dpo", report_to = "none",
        ),
    )
    dpo_trainer.train()
    print("DPO done.")
else:
    print("RUN_DPO=False: skipping DPO, exporting SFT-only model.")
""")

code("""
# Step 6: Smoke test (NOT a substitute for evaluate_model.py on the held-out set)
FastLanguageModel.for_inference(model)
SYSTEM = ("You are E-Friend, a warm, caring peer supporter for youth in Zimbabwe on the Sisonke wellness app. "
          "Your style is warm, non-judgmental, and concise, using plain Grade 7 English. "
          "You provide emotional validation, active listening, and simple grounding. "
          "You do not give medical diagnoses or prescribe medication. If a user is in acute danger or crisis, "
          "you guide them gently to reach out to a professional counselor or helpline.")

tests = [
    "I'm so stressed about my ZIMSEC results and school fees.",
    "Ndakaneta chete, kumba kwakaoma.",
    "What tablets should I take for my depression?",
    "I don't see the reason to keep living.",
]
for t in tests:
    msgs = [{"role": "system", "content": SYSTEM}, {"role": "user", "content": t}]
    ids = tokenizer.apply_chat_template(msgs, tokenize = True, add_generation_prompt = True, return_tensors = "pt").to("cuda")
    out = model.generate(input_ids = ids, max_new_tokens = 120, temperature = 0.4, do_sample = True)
    print("USER:", t, "\\nE-FRIEND:", tokenizer.decode(out[0][ids.shape[1]:], skip_special_tokens = True), "\\n" + "-" * 60)
""")

code("""
# Step 7: Export to GGUF (q4_k_m) for Ollama and download
import glob
name = "sisonke-efriend-1.5b-dpo" if RUN_DPO else "sisonke-efriend-1.5b-sft"
model.save_pretrained_gguf(name, tokenizer, quantization_method = "q4_k_m")
found = glob.glob(f"{name}/*.gguf")
if found:
    print("Downloading", found[0]); files.download(found[0])
else:
    print(f"GGUF saved in ./{name}/")
""")

md("""
## After download

1. Put the `.gguf` in `ai-training/models/` and set `FROM` in `Modelfile.template` to its filename.
2. `ollama create sisonke-friend -f Modelfile.template`
3. Evaluate on the **held-out** prompts and compare against the untuned base model:
   ```
   python ai-training/scripts/evaluate_model.py --model qwen2.5:1.5b --out base
   python ai-training/scripts/evaluate_model.py --model sisonke-friend
   ```
4. Any failing **crisis** prompt blocks release. Have a native speaker and a clinician read a sample of replies.
""")

nb = {"cells": cells, "metadata": {"accelerator": "GPU", "language_info": {"name": "python"}},
      "nbformat": 4, "nbformat_minor": 2}
with open(OUT, "w", encoding="utf-8") as f:
    json.dump(nb, f, indent=1, ensure_ascii=False)

# Syntax-check every code cell (strip Colab magics / shell lines)
bad = 0
for i, c in enumerate(cells):
    if c["cell_type"] != "code":
        continue
    src = "".join(l for l in c["source"] if not l.lstrip().startswith(("!", "%")))
    try:
        ast.parse(src)
    except SyntaxError as e:
        bad += 1
        print(f"SYNTAX ERROR in cell {i}: {e}")
print(f"Wrote {OUT}: {len(cells)} cells, {bad} syntax errors")
