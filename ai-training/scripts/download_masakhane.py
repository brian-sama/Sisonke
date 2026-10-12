import os
import sys
import re
import urllib.request
from huggingface_hub import hf_hub_download

sys.stdout.reconfigure(encoding='utf-8')
RAW_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "raw")

for repo, fname, folder in [
    ("masakhane/masakhaner", "masakhaner.py", "masakhaner"),
    ("masakhane/afriqa", "afriqa.py", "afriqa")
]:
    out_dir = os.path.join(RAW_DIR, folder)
    os.makedirs(out_dir, exist_ok=True)
    fpath = hf_hub_download(repo_id=repo, filename=fname, repo_type="dataset", local_dir=out_dir)
    print(f"\n--- Reading {fname} ---")
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()
    urls = re.findall(r'https?://[^\s"\',]+', content)
    print("Found URLs in script:", set(urls))
    
    # Check for direct data sources
    for url in set(urls):
        if any(ext in url for ext in ['.tar.gz', '.zip', '.tsv', '.csv', '.json', 'raw.githubusercontent.com', 'sna']):
            try:
                base_name = os.path.basename(url)
                dest = os.path.join(out_dir, base_name)
                print(f"Downloading {url} -> {dest}...")
                urllib.request.urlretrieve(url, dest)
                print(f"[OK] Downloaded {base_name} ({os.path.getsize(dest)/1024:.1f} KB)")
            except Exception as e:
                print(f"Failed to fetch {url}: {e}")
