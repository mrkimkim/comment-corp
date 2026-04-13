import urllib.request, urllib.parse, json, subprocess, os

API_KEY = 'NnPrUZsy0MPU8mHaLATgEaepUbNGcyS5woHlYgIT'
BASE = 'https://freesound.org/apiv2'
OUT = 'assets/audio/bgm'

os.makedirs(OUT, exist_ok=True)

# Refined queries: multiple fallback options per BGM, targeting 15-30s
BGM = {
    'bgm_idol': [
        ('pop instrumental loop', '[10 TO 60]'),
        ('upbeat bright loop', '[10 TO 60]'),
        ('happy pop loop', '[5 TO 60]'),
        ('cheerful loop', '[5 TO 60]'),
    ],
    'bgm_actor': [
        ('cinematic piano loop', '[10 TO 60]'),
        ('piano ambient', '[10 TO 60]'),
        ('piano emotional loop', '[5 TO 60]'),
    ],
    'bgm_youtuber': [
        ('quirky fun loop', '[10 TO 60]'),
        ('funky electronic loop', '[10 TO 60]'),
        ('fun loop music', '[5 TO 60]'),
    ],
    'bgm_sports': [
        ('action sport drums loop', '[10 TO 60]'),
        ('energetic drums loop', '[10 TO 60]'),
        ('drum beat loop', '[10 TO 45]'),
    ],
    'bgm_politician': [
        ('suspense tension loop', '[10 TO 60]'),
        ('tense minimal loop', '[10 TO 60]'),
        ('news background loop', '[5 TO 60]'),
        ('dark ambient loop', '[10 TO 60]'),
    ],
}


def search(query, dur_range):
    params = urllib.parse.urlencode({
        'query': query,
        'filter': f'license:"Creative Commons 0" duration:{dur_range}',
        'sort': 'rating_desc',
        'token': API_KEY,
        'page_size': 15,
    })
    url = f'{BASE}/search/text/?{params}'
    with urllib.request.urlopen(url) as r:
        return json.loads(r.read()).get('results', [])


def get_detail(sound_id):
    url = f'{BASE}/sounds/{sound_id}/?token={API_KEY}'
    with urllib.request.urlopen(url) as r:
        return json.loads(r.read())


for name, queries in BGM.items():
    out_path = f'{OUT}/{name}.mp3'
    print(f'\n=== {name} ===')

    best = None
    for query, dur_range in queries:
        print(f'  Trying: "{query}" duration:{dur_range}')
        results = search(query, dur_range)
        if not results:
            continue

        # Pick the best result: prefer duration 15-30s, pick first that fits
        for r in results:
            detail = get_detail(r['id'])
            dur = detail.get('duration', 0)
            sname = detail.get('name', '')
            preview = detail.get('previews', {}).get('preview-hq-mp3')
            if not preview:
                continue
            # Prefer 15-30s; accept 10-60s
            if 10 <= dur <= 60:
                best = (r['id'], detail, preview)
                print(f'    Found: #{r["id"]} "{sname}" ({dur:.1f}s)')
                if 15 <= dur <= 35:
                    break  # ideal range, stop looking
        if best:
            break

    if not best:
        print(f'  SKIP: {name} - nothing suitable found')
        continue

    sound_id, detail, preview = best
    tmp = f'/tmp/{name}_raw.mp3'
    urllib.request.urlretrieve(preview, tmp)

    result = subprocess.run([
        'ffmpeg', '-y', '-i', tmp,
        '-t', '30',
        '-codec:a', 'libmp3lame', '-qscale:a', '4',
        out_path
    ], capture_output=True, text=True)

    if result.returncode != 0:
        print(f'  ffmpeg error: {result.stderr[:300]}')
        continue

    size = os.path.getsize(out_path) / 1024
    print(f'  SAVED: {out_path} ({size:.0f}KB)')
    print(f'    Source: #{sound_id} "{detail.get("name")}"')
    print(f'    Duration: {detail.get("duration"):.1f}s')
    print(f'    License: {detail.get("license")}')

print('\n=== All done! ===')
