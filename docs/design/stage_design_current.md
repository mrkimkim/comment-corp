# Comment Corporation — 1스테이지 디자인 현황 (코드 기준)

## 1. 게임 플로우
MenuScreen → (셀럽 선택 탭) → GameScreen → (120초 or 멘탈 0) → ResultScreen → (다시 플레이 or 메뉴로)

## 2. 메뉴 화면 (MenuScreen)
- 배경: #FAFAFA
- 상단: "Comment\nCorporation" (36px, w900) + "댓글 주식회사" (16px, grey)
- 태그라인: "악성 댓글을 차단하고, 좋은 댓글을 승인하세요!" (12px, italic, hint color)
- 셀럽 리스트 5개 (ListView, 간격 12px):
  - idol: ★ 핑크(#FF6B9D), Easy(초록)
  - actor: 🎬 민트(#4ECDC4), Normal(주황)
  - youtuber: ▶ 노랑(#FFE66D), Normal(주황)
  - sports: ⚽ 오렌지(#FF8C42), Normal(주황)
  - politician: 🏛 연민트(#95E1D3), Hard(빨강)
- 각 버튼: 흰색 카드, elevation 2, 48x48 아이콘 영역 + 이름 + 타입명 + 난이도 뱃지 + 화살표
- 하단: "How to Play" 박스 — "좌 = 차단" (빨강) | "우 = 승인" (초록)

## 3. 게임 화면 (GameScreen)

### 3-1. 레이아웃 (위→아래)
```
[일시정지] [타이머 120s + 프로그레스바] [P1~P4] [점수]
[♥ 멘탈바 100] [콤보 0x]
[아이템 활성 배너] (freeze/boost 활성 시만)
[          댓글 카드 (중앙)          ]
[← 차단          승인 →]
[탐지기(3) 프리즈(1) 부스트(2) 스킵(1)]
```

### 3-2. HUD
- **상단바** (padding 16h, 8v):
  - 좌: 일시정지 IconButton (pause/play_arrow)
  - 중: 타이머 텍스트 (24px w900) + LinearProgressIndicator (높이 4, 민트색, radius 4)
  - 우: 페이즈 뱃지 "P1"~"P4" (12px w800, 노랑 배경 20% opacity) + 점수 (20px w800, 핑크)
- **스탯바** (padding 16h):
  - 좌: ♥ 아이콘(16px) + 멘탈 프로그레스바(높이 8, 핑크/빨강) + 숫자
  - 우: 콤보 뱃지 — 0~4: grey, 5+: amber, fever: orange + 🔥아이콘 + "FEVER Nx"

### 3-3. 댓글 카드 (CommentCard)
- 너비: 화면의 85%
- 패딩: 20 전체
- 모서리: 16 radius
- 그림자: black 10% opacity, blur 10, offset (0,4)
- **프로필 영역**: 회색 원형 아바타(36x36) + 닉네임 "익명_XXXX" (13px w700) + 난이도 뱃지(Lv.1~5, 색상별) + ♥ 좋아요 수 (12px)
- **텍스트**: 18px, height 1.4, 중앙정렬
- **스와이프 시**:
  - 드래그에 따라 X축 이동 + 회전 (ratio × 0.15 rad)
  - 배경색 변화: 좌=빨강 tint, 우=초록 tint (ratio 0.2 이상 시)
  - BLOCK/APPROVE 인디케이터 표시 (ratio 0.2 이상 시)
- **탐지기 활성 시**: 빨강(악플)/초록(선플) 테두리 3px + 글로우 + "🚨 악플!"/"✅ 선플!" 라벨

### 3-4. 스와이프 메카닉 (SwipeStack)
- 드래그 threshold: 80px
- 확정 시: 화면 밖으로 날아감 (200ms, easeIn)
- 취소 시: 원위치로 복귀 (200ms, easeOut)
- 스와이프 완료 → 즉시 다음 댓글 (타이머 없음, 큐 기반)

### 3-5. 아이템바
- 4개 아이템, 가로 균등 배치 (padding 24h):
  - 탐지기: 👁 아이콘, 민트(#4ECDC4), 3회 — 1회성 악플/선플 공개
  - 프리즈: ❄ 아이콘, 하늘(#87CEEB), 1회 — 5초간 타이머 정지
  - 부스트: ⚡ 아이콘, 오렌지(#FF8C42), 2회 — 8초간 점수 3배
  - 스킵: ⏭ 아이콘, 보라(#9B59B6), 1회 — 현재 댓글 패스
- 각 아이템: 44x44 컨테이너(radius 12) + 라벨 "이름(N)" (10px)
- 활성 상태: 배경 진해짐, 테두리 2px, 글로우, 아이콘 흰색, 라벨 "ON"
- 소진/활성 중: opacity 0.3 / 탭 비활성

### 3-6. 시각 피드백
- **정답/오답 플래시**: 전체 화면 overlay, 초록(정답)/빨강(오답), opacity 0.35→0 (400ms, easeOut)
- **멘탈 30% 이하**: 화면 테두리 빨간색 깜빡임 (600ms, 반복), ♥ 아이콘 pulse
- **일시정지**: 검정 60% overlay + "PAUSED" (40px w900 white) + Resume 버튼 (민트)
- **아이템 활성 배너**: freeze/boost 활성 시 상단에 카운트다운 "프리즈 4.3s" 표시

### 3-7. 게임 로직
- **120초, 5 Phase**:
  - P1 (0~30s): interval 2.0s, toxic 30%, max_diff 1
  - P2 (30~60s): interval 1.5s, toxic 40%, max_diff 2
  - P3 (60~90s): interval 1.0s, toxic 50%, max_diff 3
  - P4 (90~110s): interval 0.7s, toxic 55%, max_diff 4
  - P5 (110~120s): interval 0.5s, toxic 60%, max_diff 5
- **댓글 큐**: 라운드 시작 시 전체 셔플, 페이즈별 난이도/toxic 비율 반영, 중복 없음
- **콤보**: 연속 정답 시 +1, 오답 시 0으로 리셋
  - 5+ → 1.5배, 10+ → 2배, 20+ → 3배
  - 20 콤보 → 피버 진입 (8초, 초당 멘탈 +1)
- **멘탈**: 초기 100. 악플 승인 시 likes×0.3 데미지 (최소 1). 선플 정답 시 +2 회복.
- **점수**: (base + likes×2) × combo_multiplier × boost_mult
  - 악플 정답 base=100, 선플 정답 base=50
- **이벤트**: ~30/60/90초에 랜덤 발동, speed/toxic_ratio override, duration 후 복귀
- **셀럽 modifier**: idol(느림, 쉬움), politician(빠름, 어려움)

## 4. 결과 화면 (ResultScreen)
- 상단: "MENTAL BREAK" (빨강) 또는 "TIME UP" (민트)
- 등급 뱃지: 원형 100x100, 테두리 3px, 글로우
  - S: 50000+ (금색 #FFD700)
  - A: 30000+ (핑크 #FF6B9D)
  - B: 15000+ (민트 #4ECDC4)
  - C: 5000+ (오렌지 #FF8C42)
  - D: 나머지 (회색 #B2BEC3)
- 스코어 카드: 흰색, radius 20, shadow
  - "SCORE" 라벨 + 점수 (48px w900 핑크)
  - 6개 스탯 (아이콘 + 값 + 라벨): 최대콤보, 생존시간, 정확도, 처리, 정답, 오답
- 버튼: "다시 플레이" (핑크, 채움) + "메뉴로" (아웃라인)

## 5. 색상 시스템
- Primary: #FF6B9D (핑크), Secondary: #4ECDC4 (민트), Accent: #FFE66D (노랑)
- Background: #FAFAFA, Card: white
- Text: #2D3436 (primary), #636E72 (secondary), #B2BEC3 (hint)
- Feedback: #00B894 (correct), #FF7675 (wrong), #E17055 (warning)
- Grades: #FFD700(S), #FF6B9D(A), #4ECDC4(B), #FF8C42(C), #B2BEC3(D)

## 6. 현재 미비 사항 (코드에서 발견)
- Phase 표시가 P1~P4만 (코드의 _getCurrentPhase가 P5를 처리 안 함)
- 이벤트 발동 시 시각적 알림 없음 (로직만 존재)
- 피버 모드 진입/종료 시 시각 연출 없음
- 게임 오버 전환이 즉각적 (사망/타임업 연출 없음)
- 오디오 없음 (패키지 설치만 됨)
- 페이즈 전환 시 시각적 표시 없음
- 결과 화면에서 리더보드 연동 없음
- 댓글 카드 진입 애니메이션 없음 (즉시 표시)
