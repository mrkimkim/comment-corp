#!/usr/bin/env python3
"""
validate_similarity.py — Comment Quality Validator
Detects and removes duplicate / near-duplicate / low-quality comments
within each celeb_type file.

Criteria
--------
1. Exact duplicate text -> keep first only
2. High similarity (within same type only):
   a. Jaccard word-similarity >= 0.7 -> remove later one
   b. difflib.SequenceMatcher ratio >= 0.8 -> remove later one
   c. Same core nouns+verbs, only endings differ -> remove later one
3. Difficulty-length mismatch:
   - difficulty 1 and len(text) > 30 -> remove
   - difficulty 4-5 and len(text) <= 15 -> remove
4. Text <= 3 chars -> remove (meaningless)
"""

import json
import re
import sys
import os
import difflib
from collections import Counter, defaultdict
from pathlib import Path

# ── paths ──────────────────────────────────────────────────────────────
DATA_DIR = Path("/Users/hyeongyu/Documents/GitHub/comment-corp/data/comments")
FILES = ["idol.json", "actor.json", "youtuber.json", "sports.json", "politician.json"]

# ── helpers ────────────────────────────────────────────────────────────

def tokenize(text: str) -> set:
    """Split into word-level tokens."""
    tokens = re.findall(r'[가-힣a-zA-Z0-9]+', text)
    return set(t.lower() for t in tokens if len(t) > 0)


def jaccard(a: set, b: set) -> float:
    if not a and not b:
        return 1.0
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)


def seq_match_ratio(s1: str, s2: str) -> float:
    """difflib.SequenceMatcher ratio."""
    return difflib.SequenceMatcher(None, s1, s2).ratio()


def extract_core(text: str) -> str:
    """Extract core content words (nouns, verbs) by stripping common Korean endings."""
    tokens = re.findall(r'[가-힣]+', text)
    # Strip common endings: ~는, ~을, ~를, ~이, ~가, ~에, ~도, ~만, ~요, ~네, ~다, ~임, ~ㅋ etc.
    cores = []
    for t in tokens:
        # Remove trailing particles/endings (1-2 chars)
        if len(t) > 2:
            cores.append(t[:max(2, len(t)-2)])
        else:
            cores.append(t)
    return ' '.join(sorted(cores))


def is_meaningless(text: str) -> bool:
    """True if text is 3 chars or fewer."""
    stripped = text.strip()
    return len(stripped) <= 3


def difficulty_length_mismatch(difficulty: int, text: str) -> bool:
    length = len(text.strip())
    if difficulty == 1 and length > 30:
        return True
    if difficulty in (4, 5) and length <= 15:
        return True
    return False


# ── main validation ───────────────────────────────────────────────────

def validate_file(filepath: Path, save: bool = True) -> dict:
    """Return dict with 'kept', 'removed', stats."""
    with open(filepath, "r", encoding="utf-8") as f:
        comments = json.load(f)

    original_count = len(comments)
    removed_ids = set()
    removal_reasons = {}

    # Pass 1: exact duplicates
    seen_texts = {}
    for c in comments:
        txt = c["text"].strip()
        if txt in seen_texts:
            removed_ids.add(c["id"])
            removal_reasons[c["id"]] = f"exact_dup of {seen_texts[txt]}"
        else:
            seen_texts[txt] = c["id"]

    # Pass 2: meaningless / too short (<=3 chars)
    for c in comments:
        if c["id"] in removed_ids:
            continue
        if is_meaningless(c["text"]):
            removed_ids.add(c["id"])
            removal_reasons[c["id"]] = "meaningless_or_too_short"

    # Pass 3: difficulty-length mismatch
    for c in comments:
        if c["id"] in removed_ids:
            continue
        if difficulty_length_mismatch(c["difficulty"], c["text"]):
            removed_ids.add(c["id"])
            removal_reasons[c["id"]] = "difficulty_length_mismatch"

    # Pass 4: pairwise similarity (only among survivors)
    survivors = [c for c in comments if c["id"] not in removed_ids]
    token_cache = {c["id"]: tokenize(c["text"]) for c in survivors}
    core_cache = {c["id"]: extract_core(c["text"]) for c in survivors}

    for i in range(len(survivors)):
        if survivors[i]["id"] in removed_ids:
            continue
        for j in range(i + 1, len(survivors)):
            if survivors[j]["id"] in removed_ids:
                continue
            ci, cj = survivors[i], survivors[j]
            ti, tj = ci["text"].strip(), cj["text"].strip()

            # Jaccard >= 0.7
            jac = jaccard(token_cache[ci["id"]], token_cache[cj["id"]])
            if jac >= 0.7:
                removed_ids.add(cj["id"])
                removal_reasons[cj["id"]] = f"jaccard_{jac:.2f}_with_{ci['id']}"
                continue

            # SequenceMatcher ratio >= 0.8
            smr = seq_match_ratio(ti, tj)
            if smr >= 0.8:
                removed_ids.add(cj["id"])
                removal_reasons[cj["id"]] = f"seqmatch_{smr:.2f}_with_{ci['id']}"
                continue

            # Same core nouns+verbs (only endings differ)
            if len(core_cache[ci["id"]]) > 3 and core_cache[ci["id"]] == core_cache[cj["id"]]:
                removed_ids.add(cj["id"])
                removal_reasons[cj["id"]] = f"same_core_with_{ci['id']}"
                continue

    # Build kept list
    kept = [c for c in comments if c["id"] not in removed_ids]
    removed = [c for c in comments if c["id"] in removed_ids]

    # Save cleaned file
    if save:
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(kept, f, ensure_ascii=False, indent=2)

    return {
        "kept": kept,
        "removed": removed,
        "removal_reasons": removal_reasons,
        "original_count": original_count,
    }


def difficulty_distribution(comments: list) -> dict:
    return dict(sorted(Counter(c["difficulty"] for c in comments).items()))


# ── entry point ───────────────────────────────────────────────────────

def main():
    total_removed = 0
    summary = {}

    for fname in FILES:
        fpath = DATA_DIR / fname
        celeb_type = fname.replace(".json", "")

        result = validate_file(fpath)
        kept = result["kept"]
        removed = result["removed"]
        n_removed = len(removed)
        total_removed += n_removed

        dist = difficulty_distribution(kept)
        target = {1: 30, 2: 50, 3: 50, 4: 40, 5: 30}

        needs = {}
        for d in sorted(target):
            have = dist.get(d, 0)
            need = max(0, target[d] - have)
            needs[d] = {"have": have, "target": target[d], "need": need}

        reason_counts = Counter()
        for c in removed:
            reason = result["removal_reasons"][c["id"]]
            if "jaccard" in reason:
                prefix = "similar (jaccard)"
            elif "seqmatch" in reason:
                prefix = "similar (seqmatch)"
            elif "same_core" in reason:
                prefix = "same core pattern"
            elif "exact_dup" in reason:
                prefix = "exact duplicate"
            else:
                prefix = reason
            reason_counts[prefix] += 1

        summary[celeb_type] = {
            "original": result["original_count"],
            "removed": n_removed,
            "remaining": len(kept),
            "difficulty_remaining": dist,
            "difficulty_needs": {str(k): v for k, v in needs.items()},
            "removal_reasons": dict(reason_counts),
        }

    output = {
        "total_removed": total_removed,
        "by_type": summary,
    }

    print(json.dumps(output, ensure_ascii=False, indent=2))
    return total_removed


if __name__ == "__main__":
    removed = main()
    sys.exit(0)
