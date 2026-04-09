# Comment Corporation — Agent 운영 매뉴얼 v3.0

> v2.0 → v3.0 주요 변경: 6 Agent → 4 Agent 체제, Agent Team 기반 구조 전환, 자동화 파이프라인 도입, 패키지 현행화, 누락 스펙 보완

## 원칙

- 개발 프레임워크: **순수 Flutter** (Flame 사용하지 않음, 단 `flame_audio` 등 유틸 패키지 선택적 허용)
- 1인 개발. Agent = Claude Code Agent Team의 Teammate 단위
- **Agent Team 기능 사용**: TaskList 공유, SendMessage 직접 소통, 병렬 실행
- 각 Agent는 이 문서의 자기 섹션을 읽고 자율적으로 작업 가능해야 함
- Agent 간 인터페이스는 **TaskList + SendMessage + Git repo 파일** 조합

---

## Agent 체제 개요 (4 Agent)

| # | Agent 이름 | 역할 | 담당 디렉토리 |
|---|---|---|---|
| 1 | **코어 개발** | Flutter 앱 코드 + PM/태스크 관리 | `lib/`, `test/`, `docs/` |
| 2 | **콘텐츠 & 밸런스** | 댓글 생성, QA 시뮬레이션, 밸런스 조정 | `data/`, `tools/` |
| 3 | **디자인** | 이미지/사운드/애니메이션 에셋 | `assets/` |
| 4 | **배포** | CI/CD, 스토어 등록, 모니터링 | `scripts/` |

> v2 대비 변경: 오케스트레이터를 코어 개발에 흡수, QA&밸런스를 콘텐츠와 합병.
> 이유: 1인 개발에서 6개 세션 전환은 과다. 콘텐츠+QA는 둘 다 `data/` + Python 스크립트 기반으로 기술 스택 동일.

---

## 레포지토리 구조

```
comment-corp/
├── lib/                      # Flutter 앱 코드
│   ├── main.dart
│   ├── models/               # 데이터 모델 (Comment, GameState 등)
│   ├── providers/            # Riverpod 상태 관리
│   ├── screens/              # 화면 (GameScreen, MenuScreen, ResultScreen 등)
│   ├── widgets/              # 재사용 위젯 (CommentCard, SwipeStack 등)
│   ├── services/             # 외부 연동 (LeaderboardService, AudioService 등)
│   ├── utils/                # 유틸 (ScoreCalculator, BalanceConfig 등)
│   ├── l10n/                 # 다국어 ARB 파일
│   └── constants/            # 상수 (밸런스 파라미터, 테마 등)
├── assets/
│   ├── audio/
│   │   ├── bgm/              # BGM 파일 (.mp3)
│   │   └── sfx/              # 효과음 파일 (.mp3)
│   ├── images/               # UI 아이콘, 캐릭터, 배경
│   │   ├── 2.0x/             # @2x 에셋
│   │   └── 3.0x/             # @3x 에셋
│   └── animations/           # Lottie JSON 파일
├── data/
│   ├── comments/             # 댓글 JSON (타입별)
│   │   ├── idol.json
│   │   ├── actor.json
│   │   ├── youtuber.json
│   │   ├── sports.json
│   │   ├── politician.json
│   │   └── event_*.json      # 이벤트 전용 댓글
│   ├── events/
│   │   └── events.json
│   └── balance/
│       └── balance.json
├── tools/
│   ├── simulator/            # 밸런스 시뮬레이터 (Python)
│   ├── content_gen/          # 댓글 생성 스크립트 (Python)
│   ├── asset_gen/            # 에셋 생성 자동화 (Python) ← NEW
│   └── analytics/            # 분석 스크립트 (Python)
├── scripts/
│   ├── fastlane/             # 빌드 & 배포 자동화
│   │   ├── Fastfile
│   │   ├── Matchfile
│   │   └── Gemfile           # ← NEW: Fastlane 버전 고정
│   └── ci/                   # GitHub Actions 워크플로우
├── functions/                # Firebase Cloud Functions ← NEW
│   └── src/
│       └── index.ts          # 점수 검증 함수
├── docs/
│   ├── gdd.md
│   ├── agent-manual.md       # 이 문서
│   ├── balance-log.md
│   └── setup-guide.md        # ← NEW: 초기 설정 가이드 (사람이 수행)
├── test/
├── .fvmrc                    # ← NEW: Flutter 버전 고정
└── pubspec.yaml
```

---

## 사전 준비 (사람이 수행 — Agent 자동화 불가)

아래 항목들은 브라우저 인증, 결제, 물리 디바이스가 필요하여 Agent가 수행할 수 없다.
**프로젝트 시작 전에 반드시 완료할 것.**

### Apple Developer

- [ ] Apple Developer Program 등록 ($99/년)
- [ ] App ID 생성 + Game Center Capability 활성화
- [ ] Fastlane match 용 private Git repo 생성
- [ ] `fastlane match init` 실행하여 인증서 저장소 설정

### Google Play

- [ ] Google Play Developer 등록 ($25 일회성)
- [ ] 앱 최초 등록 (이름, 카테고리, 콘텐츠 등급 설문)
- [ ] 서비스 계정 생성 → Play Console API 권한 부여
- [ ] 앱 서명 키 설정 (Google Play App Signing)

### Firebase

- [ ] Firebase 프로젝트 생성 (Blaze 플랜)
- [ ] `flutterfire configure` 실행 → `firebase_options.dart` 생성
- [ ] `google-services.json` → `android/app/`
- [ ] `GoogleService-Info.plist` → `ios/Runner/`
- [ ] Crashlytics 대시보드 활성화

### GitHub Secrets

| 시크릿 이름 | 용도 |
|---|---|
| `KEYSTORE_BASE64` | Android 서명용 keystore (Base64 인코딩) |
| `STORE_PASSWORD` | Keystore 비밀번호 |
| `KEY_PASSWORD` | Key 비밀번호 |
| `KEY_ALIAS` | Key alias |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play API 인증 |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect 인증 |
| `MATCH_PASSWORD` | Fastlane match 인증서 복호화 |
| `MATCH_GIT_URL` | match 인증서 저장소 URL |
| `FIREBASE_TOKEN` | Firebase CLI 인증 |

### API 키

- [ ] OpenAI API Key (이미지 생성용)
- [ ] Freesound API Key (효과음 수급용)
- [ ] Anthropic API Key (댓글 생성용)

---

## Agent Team 시작 방법

```bash
# 환경 변수 설정 (settings.json에서 설정 가능)
# CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# Agent Team 생성 — 이 매뉴얼을 참조하여 4개 Agent 생성
# Team Lead = 코어 개발 Agent
# Teammates: 콘텐츠&밸런스, 디자인, 배포
```

### Agent 간 통신 프로토콜

```
코어 개발 ←── TaskList ──→ 콘텐츠&밸런스
코어 개발 ←── TaskList ──→ 디자인
코어 개발 ←── TaskList ──→ 배포
콘텐츠&밸런스 ── SendMessage ──→ 코어 개발 (버그 발견 시)
디자인 ── SendMessage ──→ 코어 개발 (에셋 준비 완료 알림)

파일 인터페이스 (유지):
  콘텐츠&밸런스 ──JSON──→ data/** ──→ 코어 개발
  디자인 ──에셋──→ assets/** ──→ 코어 개발
  코어 개발 ──빌드──→ 배포
```

### 스키마 변경 시 프로토콜

Comment 모델이나 balance.json 스키마 변경 시:
1. 변경하는 Agent가 SendMessage로 관련 Agent에게 사전 공지
2. TaskList에 "스키마 변경 반영" 태스크 생성
3. 모든 관련 Agent가 반영 완료 후 태스크 클로즈

---

## Agent 1: 코어 개발 (Team Lead)

### 역할
Flutter 앱 코드 개발 + PM/태스크 관리. Team Lead로서 Agent 간 조율.

### 핵심 기술 스택

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.2       # 상태 관리 (v3 — StateNotifierProvider 제거됨)
  audioplayers: ^6.5.1            # BGM + 효과음 (race condition 수정 포함)
  lottie: ^3.3.1                  # 이펙트 애니메이션
  hive: ^2.2.3                    # 로컬 데이터 저장 (SharedPreferences 대체)
  hive_flutter: ^1.1.0
  games_services: ^4.x            # Game Center / Google Play Games
  google_sign_in: ^6.x            # Google 로그인
  cloud_firestore: ^5.x           # 글로벌 리더보드
  uuid: ^4.x
  flutter_localizations:          # 다국어
    sdk: flutter
  intl: ^0.19.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.x
  mockito: ^5.x
  hive_generator: ^2.x
  build_runner: ^2.x
```

> v2 대비 변경:
> - `flutter_riverpod` 2.x → **3.x** (StateNotifierProvider 폐기, Ref 타입 파라미터 제거)
> - `audioplayers` 5.x → **6.x** (race condition 수정, AudioCache 아키텍처 변경)
> - `shared_preferences` → **hive** (18배 빠르고 구조화된 데이터 지원, AES-256 암호화)
> - `flutter_localizations` + `intl` 추가 (다국어 지원)

### 게임플레이 스펙 (v3 신규)

| 항목 | 정의 |
|---|---|
| 스와이프 좌 | **차단** (악플로 판정) |
| 스와이프 우 | **승인** (선플로 판정) |
| 판정 threshold | 스와이프 거리 80px 이상 시 확정 |
| 아이템 활성화 | 화면 하단 아이템 버튼 탭 |
| 일시정지 | 화면 우상단 일시정지 버튼 (타이머 중지, 댓글 큐 유지) |
| 게임 오버 조건 | 멘탈 0 도달 **즉시** 또는 타이머 120초 종료 |
| 오프라인 모드 | 리더보드 제외 전체 플레이 가능. 재접속 시 점수 동기화 |

### 댓글 데이터 연동 규격

```dart
// lib/models/comment.dart
class Comment {
  final String id;
  final String celebType;    // "idol" | "actor" | "youtuber" | "sports" | "politician"
  final String text;
  final String type;          // "toxic" | "positive"
  final int difficulty;       // 1~4
  final int likesMin;
  final int likesMax;
  final double damageWeight;  // 1.0~3.0
  final List<String> tags;
  final String language;      // "ko" | "en" | "ja"
  final bool eventOnly;
}
```

### 에러 처리 정책 (v3 신규)

| 상황 | 처리 |
|---|---|
| 댓글 JSON 로드 실패 | 내장 기본 댓글 세트(최소 20개) 사용 |
| balance.json 파싱 실패 | 하드코딩된 기본 밸런스 사용 |
| 오디오 재생 실패 | 무음으로 게임 계속 (게임 중단 금지) |
| 네트워크 실패 | 로컬 리더보드만 표시, 재접속 시 Firestore 동기화 |
| Lottie 로드 실패 | 간단한 Flutter 애니메이션으로 fallback |

### 성능 최적화 가이드 (v3 신규)

순수 Flutter 게임이므로 다음을 반드시 적용:
- `RepaintBoundary`로 애니메이션 위젯(댓글 카드, 이펙트) 격리
- `const` 생성자 최대 활용
- Phase 4 (interval 0.6초)에서 위젯 풀링 적용 — 카드 위젯을 재사용하여 GC 부담 감소
- Lottie 프레임레이트를 30fps로 제한 (60fps 불필요)
- Flutter DevTools Performance 탭으로 주기적 프로파일링

### 다국어 전략 (v3 신규)

- **UI 텍스트**: `flutter_localizations` + ARB 파일 기반 (`lib/l10n/`)
- **댓글 데이터**: `language` 필드 기반 필터링 (시스템 언어 또는 유저 선택)
- **지원 언어**: 한국어(ko), 영어(en), 일본어(ja)
- **댓글 언어 ≠ UI 언어 가능** (예: 일본어 UI에서 한국어 댓글 플레이 가능)

### Firebase 리더보드 — 보안 강화 (v3 변경)

```
// v2: 클라이언트 → Firestore 직접 쓰기 (점수 조작 가능)
// v3: 클라이언트 → Cloud Function → 검증 후 Firestore 쓰기

// functions/src/index.ts
export const submitScore = onCall(async (request) => {
  // 1. 인증 확인
  if (!request.auth) throw new HttpsError('unauthenticated');
  // 2. 점수 범위 검증 (0 ~ 999999)
  // 3. 플레이 시간 논리 검증 (survival_seconds <= 120)
  // 4. 콤보-점수 일관성 검증
  // 5. rate limiting (유저당 1분 1회)
  // 6. Firestore에 서버 타임스탬프로 기록
});
```

Firestore 보안 규칙:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /leaderboards/{type}/scores/{scoreId} {
      allow read: if true;
      allow create, update, delete: if false;  // Cloud Functions만 쓰기 가능
    }
  }
}
```

### PM/태스크 관리 (오케스트레이터 흡수)

코어 개발 Agent가 Team Lead로서 다음을 수행:
- Agent Team의 TaskList에 태스크 생성/할당
- GitHub Issues는 **외부 가시성용**으로만 유지 (Agent 간 조율은 TaskList)
- 마일스톤: Phase 1(프로토타입, 3주) → Phase 2(코어, 7주) → Phase 3(콘텐츠, 11주) → Phase 4(출시, 14주)
- 주간 리포트: `docs/weekly/week-{N}.md`에 진행 상황 기록

### 개발 플로우

```
1. 브랜치: feat/{기능명}, fix/{버그명}
2. 커밋: Conventional Commits (feat:, fix:, refactor:)
3. PR 생성 → squash merge to main
4. CI에서 자동 테스트 + 빌드 확인
```

### Placeholder 규격 (의존 에셋 부재 시)

콘텐츠/디자인 Agent의 산출물이 아직 없을 때 사용:
- **댓글 JSON**: `data/comments/placeholder.json` — 타입별 10개씩 기본 댓글
- **이미지**: 128x128 투명 PNG (무지 or 단색 원)
- **오디오**: 0.5초 무음 MP3
- **Lottie**: 빈 JSON `{"v":"5.5.2","fr":30,"ip":0,"op":30,"w":200,"h":200,"layers":[]}`

---

## Agent 2: 콘텐츠 & 밸런스

### 역할
댓글 데이터 생성/검증 + 게임 밸런스 시뮬레이션/조정.

### 댓글 생성 스크립트 (v3 개선)

```python
# tools/content_gen/generate_comments.py

import anthropic
import json
import time

client = anthropic.Anthropic()

def generate_comments(celeb_type: str, count: int, difficulty: int,
                      existing_texts: list[str] = None) -> list:
    """특정 타입/난이도의 댓글을 배치 생성 (한 번에 10개씩)"""

    avoid_clause = ""
    if existing_texts:
        samples = existing_texts[:20]  # 중복 방지용 샘플
        avoid_clause = f"\n이미 생성된 댓글 예시 (이와 다른 문체/내용으로):\n{json.dumps(samples, ensure_ascii=False)}"

    prompt = f"""
    셀럽 타입: {celeb_type}
    난이도: Lv.{difficulty}
    생성 개수: {count}개

    아래 JSON 배열 형식으로만 응답해. 다른 텍스트 없이 JSON만.

    각 댓글 객체:
    {{
      "text": "댓글 내용",
      "type": "toxic" 또는 "positive",
      "difficulty": {difficulty},
      "likes_min": 숫자,
      "likes_max": 숫자,
      "damage_weight": 난이도별 (Lv1=1.0, Lv2=1.5, Lv3=2.0, Lv4=3.0),
      "tags": ["태그1", "태그2"],
      "language": "ko",
      "event_only": false
    }}

    규칙:
    - Lv.1: 노골적 욕설/비하 또는 명확한 칭찬
    - Lv.2: 약간의 판단 필요. 비꼬기, 간접 비하
    - Lv.3: 교묘한 악플 (악의적 칭찬, 비꼬기) 또는 팬 드립(선플인데 악플처럼 보임)
    - Lv.4: 문맥 의존. 단독으로는 판단 불가
    - likes_min/max: Lv.1(0~50), Lv.2(0~200), Lv.3(0~500), Lv.4(0~999)
    - likes_min <= likes_max 반드시 보장
    - 극단적 혐오, 자해, 실존 인물 언급 금지
    - 한국어 인터넷 문체 (ㅋㅋ, ㅠㅠ, ㄹㅇ 등)
    - 다양한 커뮤니티 문체 반영 (디시, 인스타, 유튜브, 트위터 등)
    - 나이대별 화법 변형 (10대, 20대, 30대+)
    {avoid_clause}
    """

    # 재시도 로직 포함
    for attempt in range(3):
        try:
            response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=8192,  # 한국어 토큰 비효율성 고려
                temperature=0.9,  # 다양성 확보
                messages=[{"role": "user", "content": prompt}]
            )
            return json.loads(response.content[0].text)
        except json.JSONDecodeError:
            if attempt < 2:
                time.sleep(1)
                continue
            raise

def generate_full_type(celeb_type: str):
    """한 셀럽 타입의 전체 댓글 생성 (100개+)"""
    all_comments = []
    distribution = {1: 25, 2: 35, 3: 30, 4: 10}

    for difficulty, total_count in distribution.items():
        existing_texts = [c["text"] for c in all_comments]
        # 10개씩 배치 (JSON 안정성 확보)
        for batch_start in range(0, total_count, 10):
            batch_size = min(10, total_count - batch_start)
            comments = generate_comments(celeb_type, batch_size, difficulty, existing_texts)
            for i, c in enumerate(comments):
                c["id"] = f"{celeb_type}_{difficulty}_{batch_start + i:03d}"
                c["celeb_type"] = celeb_type
            all_comments.extend(comments)
            existing_texts.extend([c["text"] for c in comments])

    # 악플:선플 비율 검증
    toxic_count = sum(1 for c in all_comments if c["type"] == "toxic")
    toxic_ratio = toxic_count / len(all_comments)
    if not (0.50 <= toxic_ratio <= 0.60):
        print(f"WARNING: {celeb_type} toxic ratio {toxic_ratio:.2%} (target: 55%)")

    output_path = f"data/comments/{celeb_type}.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(all_comments, f, ensure_ascii=False, indent=2)

    print(f"Generated {len(all_comments)} comments for {celeb_type} (toxic: {toxic_ratio:.1%})")

# 실행
for t in ["idol", "actor", "youtuber", "sports", "politician"]:
    generate_full_type(t)
```

> v2 대비 변경:
> - 배치 크기 10개로 축소 (JSON 파싱 안정성)
> - max_tokens 4096 → 8192 (한국어 토큰 비효율성)
> - temperature 0.9 설정 (다양성)
> - 재시도 로직 추가 (JSON 파싱 실패 대비)
> - 기존 댓글 참조로 중복 방지
> - 악플:선플 비율 자동 검증
> - 커뮤니티별/나이대별 문체 다양성 지시

### 이벤트 댓글 생성 (v3 신규)

```python
# tools/content_gen/generate_event_comments.py
# events.json의 comment_pool이 있는 이벤트별 전용 댓글 생성

EVENT_CONFIGS = {
    "trending": {"count": 30, "types": ["idol","actor","youtuber","sports","politician"]},
    "idol_comeback": {"count": 20, "types": ["idol"]},
    "actor_dating": {"count": 20, "types": ["actor"]},
    "sports_mistake": {"count": 20, "types": ["sports"]},
    "politician_conference": {"count": 20, "types": ["politician"]},
}
# fan_rally, youtuber_algorithm은 comment_pool=null → 일반 댓글 풀 사용
```

### 댓글 품질 검증 (v3 강화)

```python
# tools/content_gen/validate_comments.py

def validate(filepath: str):
    # ... 기존 스키마/분포/중복 검사 ...

    # v3 추가 검증:
    # 1. 악플:선플 비율 검증 (목표: 55:45 ±5%)
    toxic_ratio = type_dist.get("toxic", 0) / len(comments)
    if not (0.50 <= toxic_ratio <= 0.60):
        errors.append(f"toxic ratio {toxic_ratio:.2%} out of range (50-60%)")

    # 2. damage_weight 범위 검증
    for i, c in enumerate(comments):
        if not (1.0 <= c.get("damage_weight", 0) <= 3.0):
            errors.append(f"#{i}: damage_weight {c.get('damage_weight')} out of range (1.0-3.0)")

    # 3. likes_min <= likes_max 논리 검증
    for i, c in enumerate(comments):
        if c.get("likes_min", 0) > c.get("likes_max", 0):
            errors.append(f"#{i}: likes_min > likes_max")

    # 4. Claude 기반 의미적 품질 검증 (선택적, 비용 발생)
    # 생성된 댓글을 Claude에게 난이도 재분류시켜 일치율 확인
```

### 시뮬레이터 (v3 보완)

```python
# tools/simulator/simulator.py
# v3: 피버 모드, 아이템, 이벤트, toxic_ratio 반영

def simulate_game(celeb_type: str, player_skill: float = 0.85) -> SimResult:
    balance = load_balance()
    comments = load_comments(celeb_type)
    modifier = balance["celeb_type_modifiers"][celeb_type]

    mental = balance["mental"]["initial"]
    score = 0
    combo = 0
    max_combo = 0
    fever_active = False
    fever_timer = 0.0

    # 아이템 잔여 횟수
    items = {
        "detector": balance["items"]["detector_per_game"],
        "freeze": balance["items"]["freeze_per_game"],
        "boost": balance["items"]["boost_per_game"],
        "shield": balance["items"]["shield_per_game"],
    }
    boost_active = False
    boost_timer = 0.0

    elapsed = 0.0
    while elapsed < balance["timer"]["total_seconds"]:
        if mental <= 0:
            break

        # 현재 페이즈 결정
        phase = get_current_phase(balance, elapsed)
        if not phase:
            break

        # 댓글 간격
        interval = phase["interval"] * modifier["speed_multiplier"]
        elapsed += interval

        # 피버 타이머 감소
        if fever_active:
            fever_timer -= interval
            mental = min(100, mental + balance["mental"]["fever_heal_per_second"] * interval)
            if fever_timer <= 0:
                fever_active = False

        # v3: toxic_ratio 반영하여 댓글 선택
        is_toxic_roll = random.random() < phase["toxic_ratio"]
        max_diff = phase["max_difficulty"] + modifier["difficulty_offset"]
        filtered = [c for c in comments
                    if (c["type"] == "toxic") == is_toxic_roll
                    and c["difficulty"] <= max(1, min(4, max_diff))]
        if not filtered:
            filtered = comments
        comment = random.choice(filtered)

        # 아이템 사용 시뮬레이션 (AI 플레이어 전략)
        if items["detector"] > 0 and comment["difficulty"] >= 3 and random.random() < 0.5:
            items["detector"] -= 1
            player_skill_effective = min(1.0, player_skill + 0.15)
        else:
            player_skill_effective = player_skill

        if items["freeze"] > 0 and elapsed > 60 and random.random() < 0.3:
            items["freeze"] -= 1
            elapsed -= balance["items"]["freeze_duration_seconds"]  # 시간 되돌림 효과

        correct = random.random() < player_skill_effective

        if correct:
            combo += 1
            max_combo = max(max_combo, combo)

            base = balance["score"]["toxic_correct_base"] if comment["type"] == "toxic" else balance["score"]["positive_correct_base"]
            likes = random.randint(comment["likes_min"], comment["likes_max"])
            likes_bonus = likes * balance["score"]["likes_bonus_multiplier"]

            multiplier = get_combo_multiplier(balance, combo)
            boost_mult = balance["items"]["boost_multiplier"] if boost_active else 1
            score += int((base + likes_bonus) * multiplier * boost_mult)

            if comment["type"] == "positive":
                mental = min(100, mental + balance["mental"]["positive_correct_heal"])

            # 피버 진입
            if combo >= balance["combo"]["fever_threshold"] and not fever_active:
                fever_active = True
                fever_timer = balance["combo"]["fever_duration_seconds"]
        else:
            combo = 0
            if comment["type"] == "toxic":
                likes = random.randint(comment["likes_min"], comment["likes_max"])
                damage = likes * balance["mental"]["toxic_approve_damage_coefficient"]
                damage = max(damage, 1)
                if items["shield"] > 0:
                    items["shield"] -= 1
                    damage = 0
                mental -= damage

    # ... (SimResult 반환)
```

> v2 대비 변경: 피버 모드, 아이템 4종, toxic_ratio 기반 댓글 선택, difficulty 필터링 추가.
> 시뮬레이터 정확도: ~50% → ~90% (이벤트 제외)

### 밸런스 목표

| 셀럽 타입 | 난이도 | skill 0.8 평균 생존 | 즉사율 |
|---|---|---|---|
| 아이돌 | 이지 | 100초+ | < 20% |
| 배우 | 노멀 | 80~100초 | 20~40% |
| 유튜버 | 노멀 | 85~100초 | 20~35% |
| 스포츠 | 노멀 | 80~100초 | 20~40% |
| 정치인 | 하드 | 60~80초 | 40~60% |

### 중장기 제안: Dart 기반 시뮬레이터

게임 로직(`lib/utils/`)에서 UI 의존성을 분리 → `dart run tools/simulator/simulate.dart`로 CLI 실행.
장점: 게임 로직 변경 시 시뮬레이터 자동 동기화. Python 별도 유지보수 불필요.

---

## Agent 3: 디자인

### 역할
이미지/사운드/애니메이션 에셋 생성 및 관리. 자동화 파이프라인 활용.

### 이미지 생성 — API 자동화 (v3 변경)

> v2에서는 Midjourney/DALL-E를 "수동 실행"으로 분류했으나, **OpenAI GPT Image API로 완전 자동화 가능**.

```python
# tools/asset_gen/generate_images.py
from openai import OpenAI
import subprocess

client = OpenAI()

STYLE_GUIDE = """
- 스타일: Cute chibi, 2등신, 둥근 눈, 굵은 외곽선
- 색상: 파스텔 톤 (메인: #FFB6C1, #87CEEB, #98FB98)
- 배경: 투명 (transparent)
- 해상도: 1024x1024
- 그림자: 없음 (flat style)
"""

CHARACTER_PROMPTS = {
    "idol": "Cute chibi K-pop idol character with microphone and star effects, pastel pink theme",
    "actor": "Cute chibi movie actor character with clapperboard, pastel blue theme",
    "youtuber": "Cute chibi YouTuber character with ring light and play button, pastel green theme",
    "sports": "Cute chibi athlete character with medal, pastel orange theme",
    "politician": "Cute chibi politician character at podium with microphone, pastel gray theme",
}

def generate_character(celeb_type: str):
    prompt = f"{CHARACTER_PROMPTS[celeb_type]}, {STYLE_GUIDE}"
    response = client.images.generate(
        model="gpt-image-1",
        prompt=prompt,
        size="1024x1024",
        quality="high",
        output_format="png",
    )
    # 1x/2x/3x 리사이즈
    # ... ImageMagick 처리 ...

for t in CHARACTER_PROMPTS:
    generate_character(t)
```

### 효과음 수급 — Freesound API 자동화 (v3 변경)

> v2에서는 "웹 검색 후 수동 다운로드"였으나, **Freesound API로 완전 자동화 가능**.

```python
# tools/asset_gen/fetch_sfx.py
import freesound

client = freesound.FreesoundClient()
client.set_token("<FREESOUND_API_KEY>", "token")

SFX_MAP = {
    "swipe_correct": "ui success tick short",
    "swipe_wrong": "error buzz wrong short",
    "combo_tick": "ascending note chime",
    "fever_start": "crowd cheer short",
    "fever_end": "descending tone",
    "game_over": "notification lock close",
    "new_record": "fanfare short victory",
    "mental_warning": "heartbeat tension",
    # 아이템 효과음
    "item_detector": "scan beep radar",
    "item_freeze": "ice freeze crystal",
    "item_boost": "power up energy",
    "item_shield": "shield activate metal",
}

for filename, query in SFX_MAP.items():
    results = client.text_search(query=query, filter="license:CC0", sort="rating_desc")
    if results.count > 0:
        sound = results[0]
        sound.retrieve_preview(".", sound.name)
        # ffmpeg 변환: WAV → MP3, 트리밍
        subprocess.run(["ffmpeg", "-i", sound.name, "-codec:a", "libmp3lame",
                       "-qscale:a", "2", "-t", "1.0", f"assets/audio/sfx/{filename}.mp3"])
```

### BGM 생성

BGM은 6곡(타입별 5 + fever 1)으로 한정적이므로 **수동 생성 허용**.
- 도구: Suno 또는 Udio (서드파티 API 경유 자동화도 가능)
- 포맷: MP3, 루프 가능하게 편집
- 프롬프트 참조: 아래 표

| 타입 | 프롬프트 | BPM |
|---|---|---|
| idol | "Upbeat K-pop instrumental, bright synth, energetic, game bgm, loop" | 128 |
| actor | "Cinematic piano, light orchestral, elegant, drama ost style, loop" | 90 |
| youtuber | "Electronic pop, quirky synth, fun beats, internet vibe, loop" | 120 |
| sports | "Stadium anthem, epic drums, crowd energy, sports highlight, loop" | 140 |
| politician | "Tense news broadcast bgm, serious, minimal synth, suspense, loop" | 100 |
| fever | "High energy remix, bass drop, euphoric, power-up theme, loop" | 150 |

### Lottie 애니메이션 (v3 신규)

v2에서 완전히 누락되었던 섹션.

**필요 애니메이션 목록:**

| 파일명 | 용도 | 길이 |
|---|---|---|
| `swipe_correct.json` | 정답 스와이프 피드백 (체크마크) | 0.5초 |
| `swipe_wrong.json` | 오답 스와이프 피드백 (X 마크) | 0.5초 |
| `combo_fire.json` | 콤보 10+ 이펙트 (불꽃) | 루프 |
| `fever_enter.json` | 피버 모드 진입 (폭발) | 1초 |
| `fever_loop.json` | 피버 모드 유지 (반짝임) | 루프 |
| `mental_warning.json` | 멘탈 30% 이하 경고 (깨짐) | 루프 |
| `item_activate.json` | 아이템 사용 (빛남) | 0.5초 |

**생성 도구:**
- **LottieFiles AI** (텍스트 프롬프트 → Lottie JSON): 간단한 이펙트에 적합
- **OmniLottie** (CVPR 2026, 오픈소스): 이미지/텍스트 → Lottie, 복잡한 애니메이션에 적합
- 수동: After Effects + Bodymovin 플러그인

### 에셋 스타일 가이드 (v3 신규)

```
색상 팔레트:
  Primary: #FF6B9D (핑크), #4ECDC4 (민트), #FFE66D (노랑)
  Secondary: #95E1D3 (연민트), #F38181 (코랄)
  Background: #FAFAFA (라이트), #1A1A2E (다크)
  Text: #2D3436 (다크), #FFFFFF (라이트)

캐릭터:
  등신: 2등신 (머리:몸 = 1:1)
  외곽선: 3px, #2D3436
  그림자: 없음 (flat style)
  표정: 항상 긍정적 (웃음, 윙크)

아이콘:
  크기: 128x128px 기준 (1x)
  스타일: Flat, 단색 + 그라데이션
  여백: 아이콘 영역의 10% padding
```

### Git LFS

```bash
git lfs install
git lfs track "*.mp3"
git lfs track "*.wav"
git lfs track "assets/images/**/*.png"  # 3.0x 이상만
```
임계값: 500KB 이상 파일은 LFS 관리.

---

## Agent 4: 배포

### 역할
CI/CD 파이프라인 구축, 스토어 등록, 출시 후 모니터링. Phase 4에서 주로 활성화.

### Fastlane 설정 (v3 수정)

```ruby
# scripts/fastlane/Gemfile
source "https://rubygems.org"
gem "fastlane", "~> 2.225"
```

```ruby
# scripts/fastlane/Fastfile

platform :ios do
  desc "TestFlight 배포"
  lane :beta do
    match(type: "appstore", readonly: true)
    sh("cd ../.. && flutter build ios --release")
    build_app(workspace: "../../ios/Runner.xcworkspace", scheme: "Runner")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end

  desc "App Store 배포"
  lane :release do
    match(type: "appstore", readonly: true)
    sh("cd ../.. && flutter build ios --release")
    build_app(workspace: "../../ios/Runner.xcworkspace", scheme: "Runner")
    upload_to_app_store(
      force: true,
      submit_for_review: true,
      automatic_release: true
    )
  end
end

platform :android do
  desc "내부 테스트 트랙 배포"
  lane :beta do
    sh("cd ../.. && flutter build appbundle --release")
    upload_to_play_store(
      track: "internal",
      aab: "../../build/app/outputs/bundle/release/app-release.aab",
      json_key_file: ENV["PLAY_STORE_SERVICE_ACCOUNT_JSON_PATH"]
    )
  end

  desc "프로덕션 배포"
  lane :release do
    sh("cd ../.. && flutter build appbundle --release")
    upload_to_play_store(
      track: "production",
      aab: "../../build/app/outputs/bundle/release/app-release.aab",
      json_key_file: ENV["PLAY_STORE_SERVICE_ACCOUNT_JSON_PATH"]
    )
  end
end
```

> v2 대비 변경:
> - `build_flutter_app` (존재하지 않는 액션) → `sh("flutter build ...")` + `build_app`
> - iOS에 `match` 호출 추가 (코드 서명)
> - Android에 `json_key_file` 추가
> - Gemfile 추가 (버전 고정)

### GitHub Actions CI/CD (v3 수정)

```yaml
# scripts/ci/build.yml
name: Build & Test & Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'  # 정확한 버전 고정
          cache: true
      - name: Cache pub dependencies
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 70" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 70% threshold"
            exit 1
          fi

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          cache: true
      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('android/**/*.gradle*') }}
      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.STORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          cache: true
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: scripts/fastlane
      - name: Install Fastlane
        run: cd scripts/fastlane && bundle install
      - name: Build & Sign
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
        run: cd scripts/fastlane && bundle exec fastlane ios beta
```

> v2 대비 변경:
> - Flutter 버전 정확히 고정 (3.24.0)
> - pub/Gradle 캐싱 추가
> - Android keystore 디코딩 + 서명
> - iOS Fastlane match 연동
> - 테스트 커버리지 threshold (70%)

### 앱 심사 주의사항 (v3 신규)

이 게임은 "악플" 콘텐츠를 다루므로 심사 시 주의:
- **Apple**: App Store Review Guideline 1.1 (Objectionable Content) 해당 가능성. "교육적/게임적 맥락에서 악플을 다룬다"는 설명 필수.
- **Google**: User Generated Content 정책. 실제 UGC가 아닌 사전 생성된 콘텐츠임을 명시.
- **연령 등급**: IARC 설문에서 "사이버불링 참조 콘텐츠" 체크 → 12+ 또는 16+ 예상.

### 배포 체크리스트

```markdown
## 빌드
- [ ] flutter analyze 경고 0
- [ ] flutter test 전체 통과, 커버리지 70%+
- [ ] Android release 빌드 + 서명 성공
- [ ] iOS release 빌드 + 서명 성공

## 스토어
- [ ] 앱 아이콘 등록 (iOS 1024x1024, Android 512x512)
- [ ] 스크린샷 등록 (최소 3장, iPhone 6.7" + Android 1080x1920)
- [ ] 앱 설명 작성 (한국어, 영어)
- [ ] 키워드/ASO 설정
- [ ] 개인정보 처리방침 URL
- [ ] 연령 등급 설정 (IARC)

## 기능
- [ ] 5개 셀럽 타입 전체 플레이 가능
- [ ] 리더보드 등록/조회 (Cloud Functions 경유)
- [ ] 아이템 4종 정상 작동
- [ ] 이벤트 정상 발동
- [ ] BGM/효과음 정상 재생
- [ ] 피버 모드 정상 진입/종료
- [ ] 다국어 전환 (ko/en/ja)

## 밸런스
- [ ] 시뮬레이터 최종 결과 목표치 충족
- [ ] 전 타입 즉사율 목표치 내

## 보안
- [ ] Cloud Functions 점수 검증 동작 확인
- [ ] Firestore 보안 규칙 배포 확인
- [ ] 클라이언트에서 직접 Firestore 쓰기 차단 확인
```

---

## Agent 간 인터페이스 요약

```
콘텐츠&밸런스 ──JSON──→ data/comments/*.json ──→ 코어 개발
콘텐츠&밸런스 ──JSON──→ data/balance/balance.json → 코어 개발
디자인 ──────에셋──→ assets/**/* ──────────→ 코어 개발
코어 개발 ───빌드──→ 배포 Agent ──────────→ 스토어

TaskList: 전 Agent 공유
SendMessage: 스키마 변경, 버그 발견, 에셋 준비 완료 등 즉시 알림
GitHub Issues: 외부 가시성용 (선택)
```

---

## v2 → v3 변경 이력 요약

| 항목 | v2 | v3 | 이유 |
|---|---|---|---|
| Agent 수 | 6 | 4 | 1인 개발 컨텍스트 스위칭 비용 감소 |
| Agent 통신 | Git 파일 + Issues만 | TaskList + SendMessage + Git | Agent Team 기능 활용, 동기화 문제 해소 |
| Riverpod | ^2.x | ^3.0.2 | 2.x는 deprecated, breaking changes 다수 |
| audioplayers | ^5.x | ^6.5.1 | race condition 수정, AudioCache 변경 |
| 로컬 저장소 | SharedPreferences | Hive | 18배 빠르고 구조화 데이터 지원 |
| 리더보드 보안 | 클라이언트 직접 쓰기 | Cloud Functions 검증 | 점수 조작 방지 |
| 이미지 생성 | Midjourney/DALL-E 수동 | OpenAI GPT Image API | 완전 자동화 가능 |
| 효과음 수급 | 웹 검색 수동 다운로드 | Freesound API | 완전 자동화 가능 |
| Lottie | 미기재 | OmniLottie/LottieFiles AI | 섹션 완전 신규 |
| 시뮬레이터 | 기본 로직만 | 피버/아이템/이벤트/toxic_ratio | 정확도 50% → 90% |
| CI/CD | 빌드만 | 빌드 + 서명 + 배포 + 캐싱 | 실제 실행 가능하게 |
| 에러 처리 | 미정의 | fallback 정책 명시 | Agent 자율 작업 가능 |
| 다국어 | language 필드만 | flutter_localizations + ARB | 구체적 전략 |
| 게임플레이 스펙 | 미정의 | 스와이프 방향, 아이템 UI 등 명시 | 구현 모호성 제거 |
| 스타일 가이드 | 미정의 | 색상/캐릭터/아이콘 규격 명시 | 에셋 일관성 확보 |
