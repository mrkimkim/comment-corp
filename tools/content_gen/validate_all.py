import json, sys
from collections import Counter

TYPES = ['idol', 'actor', 'youtuber', 'sports', 'politician']
TARGET = {1: 75, 2: 125, 3: 125, 4: 100, 5: 75}
errors = []

for t in TYPES:
    path = f'data/comments/{t}.json'
    with open(path) as f:
        data = json.load(f)

    # 총 수
    if len(data) != 500:
        errors.append(f'{t}: count {len(data)} != 500')

    # 필수 필드
    required = ['id','celeb_type','text','type','difficulty','likes_min','likes_max','damage_weight','tags','language']
    for i, c in enumerate(data):
        for field in required:
            if field not in c:
                errors.append(f'{t}#{i}: missing {field}')
        if c.get('type') not in ('toxic','positive'):
            errors.append(f'{t}#{i}: bad type {c.get("type")}')
        if c.get('difficulty') not in (1,2,3,4,5):
            errors.append(f'{t}#{i}: bad difficulty {c.get("difficulty")}')
        if c.get('likes_min',0) > c.get('likes_max',0):
            errors.append(f'{t}#{i}: likes_min > likes_max')
        if c.get('celeb_type') != t:
            errors.append(f'{t}#{i}: celeb_type mismatch')

    # 난이도 분포
    diff = Counter(c['difficulty'] for c in data)
    for d, target in TARGET.items():
        if diff.get(d, 0) != target:
            errors.append(f'{t}: Lv{d} count {diff.get(d,0)} != {target}')

    # 중복
    texts = [c['text'] for c in data]
    dupes = [t for t, cnt in Counter(texts).items() if cnt > 1]
    if dupes:
        errors.append(f'{t}: {len(dupes)} duplicate texts')

    # toxic 비율
    toxic = sum(1 for c in data if c['type'] == 'toxic')
    ratio = toxic / len(data)
    if not (0.50 <= ratio <= 0.60):
        errors.append(f'{t}: toxic ratio {ratio:.2%} out of range')

    print(f'{t}: {len(data)} comments, Lv distribution: {dict(sorted(diff.items()))}, toxic: {toxic}/{len(data)} ({ratio:.1%})')

if errors:
    print(f'\n{len(errors)} ERRORS:')
    for e in errors[:20]:
        print(f'  {e}')
    sys.exit(1)
else:
    print('\nAll checks passed!')
