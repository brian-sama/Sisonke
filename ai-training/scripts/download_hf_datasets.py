import os
import sys
import json
from datasets import load_dataset, get_dataset_config_names

sys.stdout.reconfigure(encoding='utf-8')
RAW_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "raw")
os.makedirs(RAW_DIR, exist_ok=True)

# Datasets requested by the user:
# 1. masakhane/masakhaner
# 2. masakhane/afriqa
# 3. bdotloh/empathetic-dialogues-contexts
# 4. ShenLab/MentalChat16K
# 5. Felladrin/pretrain-mental-health-counseling-conversations

def download_masakhaner():
    out_file = os.path.join(RAW_DIR, "masakhaner_shona_ndebele.json")
    if os.path.exists(out_file):
        print(f"[-] {out_file} already exists. Skipping.")
        return
    print("[+] Processing masakhane/masakhaner...")
    try:
        configs = get_dataset_config_names("masakhane/masakhaner")
        print(f"    Available configs: {configs}")
        # Shona ('sna') and any Ndebele if available
        records = []
        target_langs = [c for c in configs if c in ['sna', 'nde', 'sn']] or ['sna']
        for lang in target_langs:
            print(f"    Loading config: {lang}")
            ds = load_dataset("masakhane/masakhaner", lang, split="train")
            for row in ds:
                records.append({"lang": lang, "tokens": row.get("tokens", []), "ner_tags": row.get("ner_tags", [])})
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(records, f, ensure_ascii=False, indent=2)
        print(f"[OK] Saved {len(records)} records to {out_file}")
    except Exception as e:
        print(f"[WARN] masakhaner: {e}")

def download_afriqa():
    out_file = os.path.join(RAW_DIR, "afriqa_conversations.json")
    if os.path.exists(out_file):
        print(f"[-] {out_file} already exists. Skipping.")
        return
    print("[+] Processing masakhane/afriqa...")
    try:
        configs = get_dataset_config_names("masakhane/afriqa")
        print(f"    Available configs: {configs}")
        # Look for Shona (sna) or Southern Africa languages
        target_configs = [c for c in configs if any(k in c.lower() for k in ['sna', 'nde', 'eng', 'all'])] or configs[:3]
        records = []
        for cfg in target_configs:
            print(f"    Loading config: {cfg}")
            try:
                ds = load_dataset("masakhane/afriqa", cfg, split="train")
                for row in ds:
                    records.append(dict(row))
            except Exception as e:
                print(f"    Could not load {cfg}: {e}")
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(records, f, ensure_ascii=False, indent=2)
        print(f"[OK] Saved {len(records)} records to {out_file}")
    except Exception as e:
        print(f"[WARN] afriqa: {e}")

def download_empathetic_dialogues():
    out_file = os.path.join(RAW_DIR, "empathetic_dialogues_contexts.json")
    if os.path.exists(out_file):
        print(f"[-] {out_file} already exists. Skipping.")
        return
    print("[+] Processing bdotloh/empathetic-dialogues-contexts...")
    try:
        ds = load_dataset("bdotloh/empathetic-dialogues-contexts", split="train")
        records = [dict(row) for row in ds]
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(records, f, ensure_ascii=False, indent=2)
        print(f"[OK] Saved {len(records)} records to {out_file}")
    except Exception as e:
        print(f"[WARN] empathetic-dialogues-contexts: {e}")

def download_mentalchat16k():
    out_file = os.path.join(RAW_DIR, "mentalchat16k.json")
    if os.path.exists(out_file):
        print(f"[-] {out_file} already exists. Skipping.")
        return
    print("[+] Processing ShenLab/MentalChat16K...")
    try:
        ds = load_dataset("ShenLab/MentalChat16K", split="train")
        records = [dict(row) for row in ds]
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(records, f, ensure_ascii=False, indent=2)
        print(f"[OK] Saved {len(records)} records to {out_file}")
    except Exception as e:
        print(f"[WARN] MentalChat16K: {e}")

def download_felladrin_conversations():
    out_file = os.path.join(RAW_DIR, "felladrin_mental_health_conversations.json")
    if os.path.exists(out_file):
        print(f"[-] {out_file} already exists. Skipping.")
        return
    print("[+] Processing Felladrin/pretrain-mental-health-counseling-conversations...")
    try:
        ds = load_dataset("Felladrin/pretrain-mental-health-counseling-conversations", split="train")
        records = [dict(row) for row in ds]
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(records, f, ensure_ascii=False, indent=2)
        print(f"[OK] Saved {len(records)} records to {out_file}")
    except Exception as e:
        print(f"[WARN] Felladrin: {e}")

if __name__ == "__main__":
    download_empathetic_dialogues()
    download_mentalchat16k()
    download_felladrin_conversations()
    download_masakhaner()
    download_afriqa()
    print("\n[DONE] All downloads processed.")
