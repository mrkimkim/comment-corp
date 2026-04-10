#!/usr/bin/env python3
"""
Freesound API를 사용하여 CC0 라이선스 효과음을 다운로드합니다.
기존 placeholder 파일을 실제 오디오로 교체합니다.
표준 라이브러리만 사용 (urllib).
"""

import json
import os
import subprocess
import sys
import urllib.request
import urllib.parse
import urllib.error

API_KEY = os.environ.get('FREESOUND_API_KEY', 'NnPrUZsy0MPU8mHaLATgEaepUbNGcyS5woHlYgIT')
BASE_URL = 'https://freesound.org/apiv2'

# 프로젝트 루트 기준 출력 디렉토리
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, '..', '..'))
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'assets', 'audio', 'sfx')

# 효과음 맵: 파일명, 검색 키워드 목록, 목표 최대 길이(초)
SFX_LIST = [
    {
        'name': 'swipe_correct',
        'queries': [
            'ui success ding short',
            'success chime notification',
            'correct ding',
            'positive notification',
        ],
        'max_duration': 0.5,
        'desc': '정답 스와이프 - 밝은 딩 소리',
    },
    {
        'name': 'swipe_wrong',
        'queries': [
            'error buzz wrong short',
            'wrong buzzer error',
            'error notification buzz',
            'negative beep',
        ],
        'max_duration': 0.5,
        'desc': '오답 스와이프 - 부정적 버즈',
    },
    {
        'name': 'combo_tick',
        'queries': [
            'combo tick ascending chime',
            'tick pop short',
            'ui click tick',
            'short click pop',
        ],
        'max_duration': 0.3,
        'desc': '콤보 증가 - 상승하는 짧은 소리',
    },
    {
        'name': 'fever_start',
        'queries': [
            'power up energy burst',
            'power up game',
            'energy boost arcade',
            'powerup',
        ],
        'max_duration': 1.0,
        'desc': '피버 진입 - 에너지 폭발',
    },
    {
        'name': 'item_use',
        'queries': [
            'item pickup pop bubble',
            'bubble pop short',
            'pickup item game',
            'pop bubble',
        ],
        'max_duration': 0.5,
        'desc': '아이템 사용 - 팝/버블',
    },
    {
        'name': 'game_over',
        'queries': [
            'game over lose fail',
            'game over sad',
            'lose game descending',
            'failure sad',
        ],
        'max_duration': 2.0,
        'desc': '게임 오버 - 하강하는 슬픈 소리',
    },
    {
        'name': 'new_record',
        'queries': [
            'fanfare victory achievement short',
            'fanfare short victory',
            'achievement jingle',
            'victory fanfare',
        ],
        'max_duration': 2.0,
        'desc': '신기록 - 짧은 팡파레',
    },
]


def api_get(url, params=None):
    """urllib을 사용한 GET 요청, JSON 반환"""
    if params:
        query_string = urllib.parse.urlencode(params)
        url = f'{url}?{query_string}'
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'FetchSFX/1.0'})
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = resp.read()
            return json.loads(data), resp.status
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8', errors='replace')[:200]
        print(f'    API error ({e.code}): {body}')
        return None, e.code
    except Exception as e:
        print(f'    Request error: {e}')
        return None, 0


def download_file(url, output_path):
    """URL에서 파일 다운로드"""
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'FetchSFX/1.0'})
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read()
            with open(output_path, 'wb') as f:
                f.write(data)
            return True, len(data)
    except Exception as e:
        print(f'    Download error: {e}')
        return False, 0


def search_sounds(query, page_size=5):
    """Freesound에서 CC0 라이선스 사운드 검색"""
    data, status = api_get(f'{BASE_URL}/search/text/', {
        'query': query,
        'filter': 'license:"Creative Commons 0"',
        'sort': 'rating_desc',
        'token': API_KEY,
        'page_size': str(page_size),
    })
    if data is None:
        return []
    return data.get('results', [])


def get_sound_detail(sound_id):
    """사운드 상세 정보 조회"""
    data, status = api_get(f'{BASE_URL}/sounds/{sound_id}/', {'token': API_KEY})
    return data


def trim_audio(input_path, max_duration):
    """ffmpeg로 오디오 트리밍"""
    temp_path = input_path + '.tmp.mp3'
    try:
        result = subprocess.run([
            'ffmpeg', '-y', '-i', input_path,
            '-t', str(max_duration),
            '-codec:a', 'libmp3lame',
            '-qscale:a', '4',
            '-ar', '44100',
            temp_path,
        ], capture_output=True, text=True, timeout=30)
        if result.returncode == 0 and os.path.exists(temp_path):
            os.replace(temp_path, input_path)
            return True
        else:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return False
    except (FileNotFoundError, subprocess.TimeoutExpired):
        if os.path.exists(temp_path):
            os.remove(temp_path)
        return False


def get_duration(filepath):
    """ffprobe로 오디오 길이 조회"""
    try:
        result = subprocess.run([
            'ffprobe', '-v', 'error',
            '-show_entries', 'format=duration',
            '-of', 'default=noprint_wrappers=1:nokey=1',
            filepath
        ], capture_output=True, text=True, timeout=10)
        if result.returncode == 0 and result.stdout.strip():
            return float(result.stdout.strip())
    except (FileNotFoundError, subprocess.TimeoutExpired, ValueError):
        pass
    return None


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    has_ffmpeg = subprocess.run(['which', 'ffmpeg'], capture_output=True).returncode == 0
    if not has_ffmpeg:
        print('WARNING: ffmpeg not found. Audio trimming will be skipped.')
    else:
        print('ffmpeg found. Audio will be trimmed if needed.')

    success_count = 0
    fail_list = []

    for sfx in SFX_LIST:
        name = sfx['name']
        max_dur = sfx['max_duration']
        output_path = os.path.join(OUTPUT_DIR, f'{name}.mp3')

        print(f'\n=== {name}.mp3 ({sfx["desc"]}) ===')

        downloaded = False

        for qi, query in enumerate(sfx['queries']):
            print(f'  [{qi+1}] Searching: "{query}"')
            results = search_sounds(query)

            if not results:
                print(f'      No results.')
                continue

            # 결과에서 적합한 사운드 찾기
            for result in results:
                sound_id = result['id']
                detail = get_sound_detail(sound_id)
                if not detail:
                    continue

                duration = detail.get('duration', 0)
                preview_url = detail.get('previews', {}).get('preview-hq-mp3')

                if not preview_url:
                    continue

                print(f'      Found: #{sound_id} "{detail.get("name")}" ({duration:.1f}s)')

                ok, size = download_file(preview_url, output_path)
                if not ok:
                    print(f'      Download failed.')
                    continue

                size_kb = size / 1024
                print(f'      Downloaded: {size_kb:.1f} KB')

                # ffmpeg가 있으면 트리밍/최적화
                if has_ffmpeg:
                    actual_dur = get_duration(output_path)
                    if actual_dur and actual_dur > max_dur * 1.5:
                        print(f'      Trimming {actual_dur:.1f}s -> {max_dur}s ...')
                        if trim_audio(output_path, max_dur):
                            new_size = os.path.getsize(output_path) / 1024
                            new_dur = get_duration(output_path)
                            print(f'      Trimmed: {new_size:.1f} KB, {new_dur:.1f}s')
                        else:
                            print(f'      Trim failed, keeping original.')
                    elif actual_dur:
                        print(f'      Duration OK: {actual_dur:.1f}s')

                downloaded = True
                break

            if downloaded:
                break

        if downloaded:
            final_size = os.path.getsize(output_path)
            print(f'  OK: {name}.mp3 ({final_size/1024:.1f} KB)')
            success_count += 1
        else:
            print(f'  FAILED: Could not find suitable sound for {name}')
            fail_list.append(name)

    print(f'\n{"="*50}')
    print(f'Results: {success_count}/{len(SFX_LIST)} downloaded successfully')
    if fail_list:
        print(f'Failed: {", ".join(fail_list)}')

    # 최종 파일 목록
    print(f'\nFiles in {OUTPUT_DIR}:')
    for f in sorted(os.listdir(OUTPUT_DIR)):
        if f.endswith('.mp3'):
            fpath = os.path.join(OUTPUT_DIR, f)
            size = os.path.getsize(fpath)
            dur = get_duration(fpath) if has_ffmpeg else None
            dur_str = f'{dur:.1f}s' if dur else '?s'
            print(f'  {f:25s} {size/1024:8.1f} KB  {dur_str}')


if __name__ == '__main__':
    main()
