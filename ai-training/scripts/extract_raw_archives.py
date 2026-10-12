import os
import sys
import zipfile

sys.stdout.reconfigure(encoding='utf-8')
RAW_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "raw")
EXTRACT_BASE = os.path.join(RAW_DIR, "extracted")
os.makedirs(EXTRACT_BASE, exist_ok=True)

ARCHIVES = {
    "archive.zip": "friend_vs_professional_modes",
    "archive(1).zip": "counselchat_data",
    "archive(2).zip": "mental_health_intents",
    "archive(3).zip": "emotion_understanding",
    "archive(4).zip": "empathetic_dialogues",
}

for arch_name, folder_name in ARCHIVES.items():
    arch_path = os.path.join(RAW_DIR, arch_name)
    target_dir = os.path.join(EXTRACT_BASE, folder_name)
    if os.path.exists(arch_path):
        os.makedirs(target_dir, exist_ok=True)
        print(f"[+] Unpacking {arch_name} -> extracted/{folder_name}...")
        try:
            with zipfile.ZipFile(arch_path, 'r') as z:
                z.extractall(target_dir)
            print(f"[OK] Unpacked {arch_name} successfully.")
        except Exception as e:
            print(f"[ERROR] Failed to unpack {arch_name}: {e}")
    else:
        print(f"[-] {arch_name} not found.")

print("\n[DONE] Finished extracting archives.")
