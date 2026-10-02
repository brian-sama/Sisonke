"""
Dataset Download Script for Sisonke E-Friend Model Training
Pulls 100% open, token-free mental health & youth counseling datasets from Hugging Face.
"""
import os
import json
from datasets import load_dataset

RAW_DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "raw")
os.makedirs(RAW_DATA_DIR, exist_ok=True)

DATASETS_TO_PULL = [
    {
        "id": "herisan/mental_health_counseling_conversations",
        "name": "counseling_conversations.json",
        "split": "train",
    },
    {
        "id": "Sulav/mental_health_counseling_conversations_sharegpt",
        "name": "sharegpt_conversations.json",
        "split": "train",
    }
]

def main():
    print("=== Downloading Datasets from Hugging Face ===")
    for item in DATASETS_TO_PULL:
        dest_path = os.path.join(RAW_DATA_DIR, item["name"])
        if os.path.exists(dest_path):
            print(f"[-] {item['name']} already exists. Skipping download.")
            continue
            
        print(f"[+] Downloading {item['id']}...")
        try:
            ds = load_dataset(item["id"], split=item["split"])
            records = [dict(row) for row in ds]
            with open(dest_path, "w", encoding="utf-8") as f:
                json.dump(records, f, indent=2, ensure_ascii=False)
            print(f"[OK] Successfully saved {len(records)} records to {dest_path}")
        except Exception as e:
            print(f"[ERROR] Failed to download {item['id']}: {e}")

if __name__ == "__main__":
    main()
