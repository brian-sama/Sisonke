import os, sys, json, glob
sys.stdout.reconfigure(encoding='utf-8')
R = os.path.join(os.path.dirname(__file__), "..", "data", "raw")

def peek(path, n=2):
    print(f"\n## {os.path.relpath(path, R)}  ({os.path.getsize(path)} bytes)")
    txt = open(path, encoding='utf-8-sig', errors='replace').read()
    try:
        d = json.loads(txt)
    except Exception:
        lines = [l for l in txt.splitlines() if l.strip()]
        print("JSONL-ish lines:", len(lines))
        for l in lines[:n]:
            print(l[:500])
        return
    if isinstance(d, dict):
        print("dict keys:", list(d.keys())[:10])
        print(str(d)[:600])
    else:
        print("records:", len(d))
        for r in d[:n]:
            print(json.dumps(r, ensure_ascii=False)[:500])

peek(os.path.join(R, "extracted", "counselchat_data", "combined_dataset.json"))
peek(os.path.join(R, "extracted", "mental_health_intents", "intents.json"))
for name in ["empathetic_dialogues_contexts.json", "mentalchat16k.json",
             "felladrin_mental_health_conversations.json", "counseling_conversations.json",
             "sharegpt_conversations.json"]:
    peek(os.path.join(R, name))

d = glob.glob(os.path.join(R, "extracted", "emotion_understanding", "**", "dialogs", "*.jsonl"), recursive=True)
print("\n## emotion dialogs:", len(d))
print(open(d[0], encoding='utf-8').read()[:700])
for p in ["masakhaner/shona_train.txt", "afriqa/queries_zul.json"]:
    fp = os.path.join(R, p)
    print("\n##", p, os.path.getsize(fp), "bytes")
    print(open(fp, encoding='utf-8').read()[:300])
