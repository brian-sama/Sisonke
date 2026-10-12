"""
Sisonke E-Friend dataset builder (SFT + DPO).

Reads every source in data/raw, filters it down to the E-Friend style
(short, warm, non-clinical, Grade 7 English), merges it with the hand-written
Zimbabwean / 4-Domains / crisis seeds, and writes:

  data/processed/sisonke_train.jsonl   (ChatML "messages", SFT)
  data/processed/sisonke_val.jsonl
  data/processed/sisonke_dpo.jsonl     (prompt / chosen / rejected)
  data/processed/build_report.json     (counts per source)

Run:  ai-training\\.venv\\Scripts\\python ai-training\\scripts\\build_dataset.py
"""
import os
import re
import csv
import sys
import json
import glob
import random
import hashlib
from collections import defaultdict, Counter

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(__file__))
from prepare_training_data import (  # noqa: E402  (hand-written seeds live there)
    SYSTEM_PROMPT,
    FOUR_DOMAINS_FACILITATOR_DIALOGUES,
    LOCAL_ZIM_CONVERSATIONS,
    clean_text,
)

BASE = os.path.join(os.path.dirname(__file__), "..", "data")
RAW = os.path.join(BASE, "raw")
EXTRACTED = os.path.join(RAW, "extracted")
CUSTOM = os.path.join(BASE, "custom")  # drop your own *.jsonl (ChatML "messages") here
OUT = os.path.join(BASE, "processed")
os.makedirs(OUT, exist_ok=True)
os.makedirs(CUSTOM, exist_ok=True)
csv.field_size_limit(10**9)
random.seed(42)

SEED_OVERSAMPLE = 3  # was 10x; heavy duplication makes a 1.5B model memorise, not generalise

# Caps keep any single generic source from drowning out the Zimbabwean seeds.
CAP_EMPATHETIC = 1200
CAP_MENTALCHAT = 1500
CAP_COUNSELCHAT = 800
CAP_INTENTS = 150

# ---------------------------------------------------------------- filters
CLINICAL = re.compile(
    r"\b(xanax|prozac|zoloft|ssri|antidepress\w*|medicat\w*|prescri\w*|dosage|diagnos\w*|disorder|"
    r"psychiatr\w*|psycholog\w*|therap\w*|cbt|dbt|clinic\w*|my office|dsm|"
    r"as an ai|language model|988|911|hotline|counsel+or|licensed|session|sessions|hypnosis|hypnotherapy|"
    r"existential|we'?ll work|we will work|i'?m here to help you explore|your therapist|as your)\b",
    re.I,
)
# Western-specific trivia that teaches the wrong cultural register for Zimbabwean youth.
WESTERN = re.compile(
    r"(walmart|target|starbucks|mcdonald|iphone|ipod|ipad|netflix|thanksgiving|halloween|dollars?|\$\d|"
    r"\bmom\b|\bcollege\b|\bdorm|\bsorority|\bfraternity|\bprom\b|\bthe states\b|\bdmv\b|\bhoa\b)",
    re.I,
)
# Users in danger must get the scripted handoff, never a generic reply from a dataset.
CRISIS_USER = re.compile(
    r"(suicid|kill myself|end my life|ending it all|want to die|better off dead|self[- ]?harm|"
    r"hurt myself|cut myself|cutting myself|overdose|rape|raped|molest|abus(e|ed|ing|ive)|"
    r"beat(s|ing)? me|hits me|shouldn'?t be here|no reason to live)",
    re.I,
)
URL = re.compile(r"https?://|www\.", re.I)


def sentences(text):
    return [s for s in re.split(r"(?<=[.!?])\s+", text.strip()) if s]


def words(text):
    return len(text.split())


def fix_ed(text):
    return clean_text(text.replace("_comma_", ",").replace("_period_", "."))


def good_reply(text, min_w=8, max_w=70, max_s=4):
    if not (min_w <= words(text) <= max_w):
        return False
    if len(sentences(text)) > max_s:
        return False
    return not (CLINICAL.search(text) or URL.search(text))


def good_user(text, max_chars=800):
    return 5 <= words(text) and len(text) <= max_chars and not CRISIS_USER.search(text)


def msgs(*turns):
    out = [{"role": "system", "content": SYSTEM_PROMPT}]
    for role, content in turns:
        out.append({"role": role, "content": content})
    return {"messages": out}


samples = []  # (source, example)


def add(source, example):
    samples.append((source, example))


# ---------------------------------------------------------------- 1. hand-written seeds
for item in FOUR_DOMAINS_FACILITATOR_DIALOGUES:
    add("seed_four_domains", msgs(("user", item["user"]), ("assistant", item["assistant"])))
for item in LOCAL_ZIM_CONVERSATIONS:
    add("seed_zimbabwe", msgs(("user", item["user"]), ("assistant", item["assistant"])))

# Crisis handoff behaviour (no phone numbers on purpose - those come from RAG, not weights).
CRISIS_SEEDS = [
    ("I don't want to be alive anymore.",
     "I'm really glad you told me, and I'm taking it seriously. You don't have to carry this alone tonight. "
     "Please reach out to a live counselor on Sisonke right now so a real person can be with you. "
     "Are you somewhere safe at the moment?"),
    ("I want to kill myself.",
     "I'm so sorry it hurts this much. Your life matters, and you deserve support from a real person right now. "
     "Please tap the counselor button to talk to a live counselor. I'm staying right here with you. Are you safe right now?"),
    ("Sometimes I cut myself when everything gets too much.",
     "Thank you for trusting me with that. It sounds like the pain is very heavy, and I'm not judging you. "
     "A live counselor can help you with this properly, so please reach out to one now. Are you hurt or in danger right now?"),
    ("My uncle touches me when nobody is home and he said I must not tell anyone.",
     "I'm so sorry. What is happening is not your fault, and you did the right thing by telling me. "
     "You deserve to be safe, so please speak to a live counselor right now. Is he near you at this moment?"),
    ("My boyfriend beats me when he is angry but I love him.",
     "I'm sorry you are being hurt. Loving someone does not make violence okay, and none of this is your fault. "
     "A live counselor can help you plan to stay safe, so please reach out to one now. Are you safe right now?"),
    ("My parents want me to marry an older man next month and I can't say no.",
     "That sounds frightening, and I'm glad you told me. You deserve to be heard and protected. "
     "Please talk to a live counselor now so they can help you stay safe. Are you safe where you are right now?"),
    ("I took too many tablets because I wanted to sleep forever.",
     "I'm really worried about you right now. Please get help immediately: tell an adult near you or go to the nearest clinic, "
     "and contact a live counselor on Sisonke now. Please don't be alone. Is someone with you?"),
]
for u, a in CRISIS_SEEDS:
    add("seed_crisis", msgs(("user", u), ("assistant", a)))

BOUNDARY_SEEDS = [
    ("What tablets should I take for my depression? How many?",
     "I can't tell you which medicine to take, because I'm a peer friend and not a doctor. "
     "Please visit your nearest clinic so a health worker can check you properly. "
     "In the meantime, what has been weighing on you the most?"),
    ("Do I have depression? Please just tell me.",
     "I can't say what you have, because only a health worker can do that. What I can hear is that you've been carrying a lot, "
     "and that matters. Can you tell me how long you've been feeling this way?"),
    ("Can you be my therapist and diagnose me?",
     "I'm not a therapist or a doctor, but I'm here as a friend who will listen without judging. "
     "A clinic or a counselor can do the diagnosing part. Would you like to tell me what's been going on?"),
    ("Which cough syrup will make me forget everything for a while?",
     "I hear that you're trying to escape something heavy, and I'm not judging you. I can't help with that, because it can hurt you badly. "
     "Can we talk about what you want to forget? I'm listening."),
]
for u, a in BOUNDARY_SEEDS:
    add("seed_boundary", msgs(("user", u), ("assistant", a)))

# Multi-turn peer-support seeds (3 exchanges, ends on assistant).
MULTI_TURN_SEEDS = [
    [("user", "I failed my maths mock and I don't want to go to school tomorrow."),
     ("assistant", "That sounds really disappointing, and it makes sense you want to hide today. Failing a mock doesn't mean you will fail the final. What part of it hurts the most?"),
     ("user", "My dad pays so much for fees and I feel like I'm wasting his money."),
     ("assistant", "You clearly care about your family, and that's a lot of pressure to carry. Feeling guilty shows how much you want to do well. Is there one topic in maths you'd like to fix first?"),
     ("user", "Maybe fractions. I always get lost there."),
     ("assistant", "That's a good place to start, and it's small enough to manage. Maybe ask a classmate you trust to go through fractions with you for ten minutes. Who could you ask?")],
    [("user", "My friends left for South Africa and I'm just here with nothing."),
     ("assistant", "It's hard to watch friends move on while you feel stuck. Your feelings make sense. How have you been coping with it lately?"),
     ("user", "I stay in my room. I don't even want to talk to anyone."),
     ("assistant", "Thank you for telling me. Pulling away when we feel low is very human. You're talking to me now, and that's already one step. Is there one person you can greet or message today, even briefly?"),
     ("user", "My cousin maybe. He is also jobless."),
     ("assistant", "That could be good, because he may understand exactly how you feel. You don't have to fix everything, just share a little time. What could you two do together this week?")],
]
for turns in MULTI_TURN_SEEDS:
    add("seed_multiturn", msgs(*turns))

# User-supplied custom data (ChatML jsonl with a "messages" field).
for path in glob.glob(os.path.join(CUSTOM, "*.jsonl")):
    if "dpo" in os.path.basename(path):
        continue
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.strip():
                row = json.loads(line)
                if row.get("messages") and row["messages"][0]["role"] != "system":
                    row["messages"].insert(0, {"role": "system", "content": SYSTEM_PROMPT})
                add("custom", row)

# ---------------------------------------------------------------- 2. EmpatheticDialogues (real multi-turn)
# Only emotionally heavy contexts - the rest of EmpatheticDialogues is casual small talk.
POSITIVE_OK = {"hopeful"}
NEGATIVE_OK = {"sad", "anxious", "lonely", "afraid", "terrified", "devastated", "disappointed", "ashamed",
               "guilty", "embarrassed", "jealous", "apprehensive", "anguished"}
EMPATHY_MARKER = re.compile(
    r"(sorry|that sounds|i understand|i can imagine|must (be|have been)|hard|tough|difficult|scary|painful|"
    r"hurt|here for you|makes sense|not alone|how are you feeling|how did you feel|what happened|"
    r"do you want to talk|that.?s (rough|awful|terrible|heartbreaking))",
    re.I,
)

ed_rows = defaultdict(list)
for split in ("train", "validation", "test"):
    p = os.path.join(EXTRACTED, "empathetic_dialogues", f"{split}.csv")
    if not os.path.exists(p):
        continue
    with open(p, encoding="utf-8", errors="replace", newline="") as f:
        for r in csv.DictReader(f):
            ed_rows[(split, r["conv_id"])].append(r)

ed_candidates = []
for (_, _cid), rows in ed_rows.items():
    rows.sort(key=lambda r: int(r["utterance_idx"]))
    emotion = rows[0]["context"]
    if emotion not in NEGATIVE_OK | POSITIVE_OK:
        continue
    turns = []
    ok = True
    for i, r in enumerate(rows[:6]):
        text = fix_ed(r["utterance"])
        role = "user" if i % 2 == 0 else "assistant"
        if WESTERN.search(text):
            ok = False
            break
        if role == "user" and not good_user(text, 500):
            ok = False
            break
        if role == "assistant" and (
            not good_reply(text, min_w=8, max_w=60, max_s=3)
            or not EMPATHY_MARKER.search(text)
            or ":)" in text or ":(" in text or "lol" in text.lower()
        ):
            ok = False
            break
        turns.append((role, text))
    # end on an assistant turn, need at least one full exchange
    while turns and turns[-1][0] != "assistant":
        turns.pop()
    if ok and len(turns) >= 2:
        ed_candidates.append(msgs(*turns))
random.shuffle(ed_candidates)
for ex in ed_candidates[:CAP_EMPATHETIC]:
    add("empathetic_dialogues", ex)
n_ed_total = len(ed_candidates)

# ---------------------------------------------------------------- 3. MentalChat16K (heavy filtering)
mc_candidates = []
mc_path = os.path.join(RAW, "mentalchat16k.json")
if os.path.exists(mc_path):
    for r in json.load(open(mc_path, encoding="utf-8")):
        u, a = clean_text(r.get("input", "")), clean_text(r.get("output", ""))
        if good_user(u) and good_reply(a, min_w=15, max_w=90, max_s=4):
            mc_candidates.append(msgs(("user", u), ("assistant", a)))
random.shuffle(mc_candidates)
for ex in mc_candidates[:CAP_MENTALCHAT]:
    add("mentalchat16k", ex)
n_mc_total = len(mc_candidates)

# ---------------------------------------------------------------- 4. CounselChat (deduped; also gives DPO pairs)
by_context = defaultdict(list)
for p in (os.path.join(RAW, "counseling_conversations.json"),):
    if os.path.exists(p):
        for r in json.load(open(p, encoding="utf-8")):
            c, a = clean_text(r.get("Context", "")), clean_text(r.get("Response", ""))
            if c and a and a not in by_context[c]:
                by_context[c].append(a)

dpo_pairs = []
cc_candidates = []
for ctx, answers in by_context.items():
    if CRISIS_USER.search(ctx) or len(ctx) > 800:
        continue
    short = [a for a in answers if good_reply(a, min_w=12, max_w=80, max_s=4) and EMPATHY_MARKER.search(a)]
    for a in short[:2]:
        cc_candidates.append(msgs(("user", ctx), ("assistant", a)))
    # NOTE: auto-built DPO pairs from CounselChat were reviewed and dropped: the "chosen" side
    # was not reliably peer-style. DPO data must be hand-written / reviewed (see DPO_SEEDS).
random.shuffle(cc_candidates)
for ex in cc_candidates[:CAP_COUNSELCHAT]:
    add("counselchat", ex)
n_cc_total = len(cc_candidates)

# ---------------------------------------------------------------- 5. intents.json (short emotional openers only)
EMO_TAGS = {"sad", "stressed", "worthless", "anxious", "scared", "not-talking", "sleep", "friends", "user-advice"}
intent_samples = []
ip = os.path.join(EXTRACTED, "mental_health_intents", "intents.json")
if os.path.exists(ip):
    for it in json.load(open(ip, encoding="utf-8"))["intents"]:
        if it["tag"] not in EMO_TAGS:
            continue
        resp = [r for r in it["responses"] if good_reply(r, min_w=6, max_w=60, max_s=3)]
        if not resp:
            continue
        for pat in it["patterns"]:
            if good_user(pat, 300) and words(pat) >= 3:
                intent_samples.append(msgs(("user", pat), ("assistant", random.choice(resp))))
random.shuffle(intent_samples)
for ex in intent_samples[:CAP_INTENTS]:
    add("intents", ex)

# ---------------------------------------------------------------- 6. DPO: hand-written Zimbabwean pairs
DPO_SEEDS = [
    ("I'm so stressed about my ZIMSEC results and school fees.",
     "That's a lot to carry, and it makes sense you feel stressed. Your worth is more than one exam result. What feels heaviest right now, the results or the fees?",
     "You should consider seeing a psychiatrist for your anxiety disorder and discuss starting medication. Additionally, you could relocate to a less stressful environment and enroll in a private tutoring programme."),
    ("Ndakaneta chete. Home is too much.",
     "Ndinonzwisisa, friend. Being tired of a home that feels heavy is real, and you don't have to be strong all the time. Have you had something to eat and drink today?",
     "Feeling exhausted may indicate clinical depression. It is recommended that you schedule a consultation with a licensed therapist and consider moving out to reduce environmental stressors."),
    ("My friends are all abroad and I'm stuck here jobless.",
     "It's painful to watch others move ahead while you feel stuck. That doesn't mean you're behind in life. What's one small thing you could try this week?",
     "Many young people go through this. Here are ten steps: 1. Update your CV. 2. Apply online daily. 3. Network on LinkedIn. 4. Consider emigrating. 5. Take online courses. 6. See a psychologist for your low mood."),
]
for u, c, r in DPO_SEEDS:
    dpo_pairs.append({
        "source": "seed",
        "prompt": [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": u}],
        "chosen": c,
        "rejected": r,
    })

# ---------------------------------------------------------------- split + write
def key(example):
    return hashlib.md5(json.dumps(example["messages"][1:], ensure_ascii=False).encode()).hexdigest()


seen, unique = set(), []
for src, ex in samples:
    k = key(ex)
    if k not in seen:
        seen.add(k)
        unique.append((src, ex))

# Hand-written seeds are oversampled; templated synthetic/custom data is NOT (it already repeats phrasing).
SEED_SOURCES = {"seed_four_domains", "seed_zimbabwe", "seed_crisis", "seed_boundary", "seed_multiturn"}
NO_VAL_HOLDOUT = SEED_SOURCES
# Split BEFORE oversampling so duplicated seeds never leak into validation.
random.shuffle(unique)
val, train = [], []
for src, ex in unique:
    rate = 0.08 if src == "custom" else 0.05
    if src not in NO_VAL_HOLDOUT and random.random() < rate:
        val.append((src, ex))
    else:
        train.append((src, ex))
# a few seeds in val so Zimbabwe-specific behaviour is measured too
seed_train = [t for t in train if t[0] in SEED_SOURCES]
for t in random.sample(seed_train, k=min(6, len(seed_train))):
    train.remove(t)
    val.append(t)

final_train = []
for src, ex in train:
    final_train.extend([ex] * (SEED_OVERSAMPLE if src in SEED_SOURCES else 1))
random.shuffle(final_train)


def dump(path, rows):
    with open(path, "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


dump(os.path.join(OUT, "sisonke_train.jsonl"), final_train)
dump(os.path.join(OUT, "sisonke_val.jsonl"), [ex for _, ex in val])
for path in glob.glob(os.path.join(CUSTOM, "*dpo*.jsonl")):
    with open(path, encoding="utf-8") as f:
        dpo_pairs.extend(json.loads(l) for l in f if l.strip())
dump(os.path.join(OUT, "sisonke_dpo.jsonl"), dpo_pairs)

# ---------------------------------------------------------------- safety re-check + report
def assistant_texts(ex):
    return [m["content"] for m in ex["messages"] if m["role"] == "assistant"]


leaks = 0
for src, ex in unique:
    if src in SEED_SOURCES or src == "custom":
        continue
    if any(CLINICAL.search(t) for t in assistant_texts(ex)):
        leaks += 1
    if any(CRISIS_USER.search(m["content"]) for m in ex["messages"] if m["role"] == "user"):
        leaks += 1

report = {
    "unique_examples": len(unique),
    "train_rows_after_oversample": len(final_train),
    "val_rows": len(val),
    "dpo_pairs": len(dpo_pairs),
    "by_source_unique": dict(Counter(s for s, _ in unique)),
    "available_before_cap": {
        "empathetic_dialogues": n_ed_total, "mentalchat16k": n_mc_total, "counselchat": n_cc_total,
    },
    "generic_rows_failing_safety_recheck": leaks,
}
json.dump(report, open(os.path.join(OUT, "build_report.json"), "w", encoding="utf-8"), indent=2)
print(json.dumps(report, indent=2))
