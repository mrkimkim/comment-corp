# Comment Corporation -- Swipe Interaction & Card Design 피드백 리포트

> 작성일: 2026-04-09
> 전문 영역: 모바일 게임 인터랙션 디자인 (스와이프 물리, 카드 UX, 피드백 시스템)
> 대상: Comment Corporation 1스테이지 (GameScreen의 CommentCard + SwipeStack)

---

## 현재 상태 요약

| 항목 | 현재 값 | 비고 |
|------|---------|------|
| 카드 너비 | 화면의 85% | 패딩 20, radius 16 |
| 스와이프 threshold | 80px | 고정값 |
| 확정 애니메이션 | 200ms easeIn (화면 밖 퇴장) | |
| 취소 애니메이션 | 200ms easeOut (원위치 복귀) | |
| 회전 | ratio x 0.15 rad | 드래그 비율 기반 |
| 색상 피드백 | ratio 0.2 이상 시 빨강/초록 tint | |
| 인디케이터 | "BLOCK" / "APPROVE" 텍스트 | ratio 0.2 이상 시 |
| 다음 카드 미리보기 | 없음 | 즉시 표시 |
| 카드 진입 애니메이션 | 없음 | 미비사항으로 명시됨 |
| Haptic 피드백 | 없음 | |
| 카드 퇴장 후 전환 | 즉시 (타이머 없음, 큐 기반) | |

---

## Round 1: 스와이프 카드 인터랙션 글로벌 베스트 프랙티스

### 리서치 키워드
"best swipe card interaction mobile game UX 2025 2026", "Reigns game swipe mechanic card design analysis UX"

### 발견 사항

**Reigns의 핵심 교훈:**
- Reigns는 Tinder식 스와이프를 게임 메카닉으로 승화시킨 대표 사례. "단순한 스와이프 제스처에 4개 차원의 결과가 부여되면서 엄청난 의미가 생겼다"는 개발자 코멘트가 핵심.
- 부분 스와이프(partial swipe) 시 결과 힌트를 보여줌 -- 원형 인디케이터 크기로 영향도를 표시하되, 긍정/부정은 숨김. 이는 "정보의 비대칭"으로 전략적 사고를 유도.
- 게임플레이의 유동성(fluidity)이 핵심 -- 사망이나 이벤트 시에도 컷씬 없이 카드 흐름을 유지.

**2025-2026 모바일 UX 트렌드:**
- Multi-directional swipe: 좌/우 외에 상/하 제스처로 추가 기능 제공.
- Animated transitions: 스와이프와 부드러운 애니메이션의 페어링이 필수.
- Contextual swipes: 스와이프가 문맥에 맞는 의미 있는 액션을 트리거해야 함.
- 카드 UI에 물리적 깊이감(tactile z-index)을 부여하는 트렌드.

### 현재 게임에 적용 시 토의

Comment Corporation은 이미 Reigns식 좌/우 이진 판단 구조를 채택하고 있으나, Reigns의 "부분 스와이프 시 결과 힌트" 메카닉이 없음. 현재 게임에서는 댓글이 악플인지 선플인지를 판단하는 것이 핵심이므로, 부분 스와이프 시 댓글의 "감정 온도계"나 좋아요 수의 변화 미리보기 같은 힌트를 줄 수 있음.

다만, Comment Corp은 Reigns과 달리 시간 압박이 있는 게임(120초)이므로, 너무 많은 정보 힌트는 "천천히 읽어보세요" 메시지와 충돌. 속도감과 정보 제공의 밸런스가 중요.

### 개선안 1-A: 부분 스와이프 감정 힌트 시스템
- 스와이프 50% 이상 시 카드 배경에 미묘한 "위험도 게이지" 표시
- 탐지기 아이템의 라이트 버전 -- 완전한 정보가 아니라 "분위기"만 전달
- **재미: 7** | **심플함: 5** | **구현용이: 4**

### 개선안 1-B: 카드 흐름 유동성 극대화
- 카드 퇴장과 다음 카드 진입을 오버랩시킴 (현재는 순차적)
- 퇴장 카드가 50% 사라질 때 다음 카드가 이미 올라오기 시작
- **재미: 8** | **심플함: 8** | **구현용이: 7**

### 다음 라운드 의문점
- 스와이프 물리(threshold, velocity, spring)의 최적 파라미터는?

---

## Round 2: 스와이프 물리 -- Threshold, Velocity, Spring 최적화

### 리서치 키워드
"swipe card physics animation threshold speed rotation mobile game development flutter", "Tinder swipe UX design card animation details threshold velocity haptic feedback 2025"

### 발견 사항

**Threshold 설계:**
- Tinder 스타일: position-based threshold (화면 폭의 30%) 또는 velocity-based threshold (500px/s 이상).
- flutter_card_swiper: thresholdValue 기본 0.3 (화면 폭의 30%), maxDragDistance 220px.
- 현재 Comment Corp은 80px 고정 -- 이는 작은 화면에서는 너무 쉽고, 큰 화면에서는 적절. **비율 기반으로 전환 필요.**

**Spring 물리:**
- 반응성 높은 UI: stiffness 200-300, damping 12-15, mass 0.2-1.0
- 바운시한 느낌: stiffness 100, damping 10, mass 1.0
- 부드러운 느낌: stiffness 50, damping 20, mass 1.0
- Flutter의 SpringSimulation 클래스로 구현 가능 (flutter/physics.dart)
- Velocity threshold: 일반적으로 500px/s, friction 2, damping 12

**복귀 애니메이션:**
- 현재 200ms easeOut은 너무 기계적. Spring 물리 기반 복귀가 자연스러움.
- Spring 복귀는 살짝 오버슈트 후 정착하는 느낌 -- "살아있는" 카드 감각.

### 현재 게임에 적용 시 토의

현재 80px 고정 threshold는 디바이스 크기를 고려하지 않음. iPhone SE(375px 폭)에서 80px은 약 21%이고, iPad(1024px 폭)에서는 약 8%로 너무 쉬움. 화면 폭의 25-30% 비율 기반으로 전환하면 일관된 경험 제공 가능.

easeIn/easeOut 대신 Spring 물리를 도입하면 카드가 "손에서 미끄러지듯" 날아가고, 취소 시 "고무줄처럼" 돌아오는 느낌을 줄 수 있음. 이는 게임 내 타이밍 프레셔와 결합하면 쾌감을 극대화.

### 개선안 2-A: 비율 기반 스와이프 Threshold
- 80px 고정 -> 화면 폭의 25% (position-based) + 500px/s (velocity-based) 듀얼 체크
- 빠른 플릭도 인정, 느린 드래그도 인정 -- 플레이 스타일 다양성 확보
- **재미: 7** | **심플함: 9** | **구현용이: 8**

### 개선안 2-B: Spring 물리 기반 카드 애니메이션
- 퇴장: SpringSimulation(mass: 0.5, stiffness: 250, damping: 15) + 초기 velocity 반영
- 복귀: SpringSimulation(mass: 1.0, stiffness: 150, damping: 12) -- 살짝 오버슈트
- 200ms 고정 duration 제거 -> Spring이 자연스럽게 settle
- **재미: 8** | **심플함: 7** | **구현용이: 6**

### 다음 라운드 의문점
- 카드의 시각적 정보 위계(visual hierarchy)와 최적 사이즈/레이아웃은?

---

## Round 3: 카드 디자인 -- 시각적 정보 위계 & 레이아웃

### 리서치 키워드
"card game visual hierarchy information architecture mobile UI typography layout", "mobile game card size ratio screen percentage optimal touch target ergonomics one hand"

### 발견 사항

**카드 내 정보 위계:**
- 1순위: 가장 중요한 콘텐츠를 카드 상단에 배치, 타이포그래피로 강조
- 2순위: 사이즈, 컬러, 포지션으로 명확한 위계 생성
- 3순위: 2차 정보(비용, 키워드 등)는 보이되 주목받지 않도록
- 핵심: 폰트 8pt 이하 금지, 10pt 이하는 접근성 이슈

**현재 Comment Corp 카드의 정보 구성:**
1. 프로필 영역: 아바타(36x36) + 닉네임(13px) + 난이도 뱃지 + 좋아요 수(12px)
2. 댓글 텍스트: 18px, 중앙정렬

**문제점:**
- 프로필 영역과 댓글 텍스트의 시각적 무게가 비슷 -- 어디를 먼저 봐야 할지 불분명
- 12px 좋아요 수는 너무 작아서 의사결정에 활용하기 어려움
- 중앙정렬 텍스트는 긴 댓글에서 가독성 저하
- 닉네임 "익명_XXXX"가 13px w700인데, 이는 실제 판단에 불필요한 정보가 과도한 시각적 무게를 가짐

**터치 타겟과 한 손 조작:**
- 최적 터치 타겟: 20mm x 20mm (약 57px x 57px)
- 엄지 영역: 평균 2.5cm(1인치) -- 게임 컨트롤은 엄지 기준
- 화면 85%는 카드에 적절하나, 아이템바(44x44)도 한 손으로 편하게 닿아야 함

### 현재 게임에 적용 시 토의

Comment Corp의 핵심 의사결정 정보는 "댓글 텍스트 내용"임. 그런데 현재 카드에서 프로필 영역이 상단에 위치하여 시선이 먼저 가게 됨. 플레이어가 닉네임이나 아바타를 볼 필요는 없음 -- 실질적으로 "댓글 내용"과 "좋아요 수(난이도 힌트)"만 필요.

정보 위계를 재설계하여 댓글 텍스트를 시각적으로 가장 강하게 만들고, 프로필 정보는 "소셜 미디어 맥락 제공"용으로 축소하는 것이 바람직.

### 개선안 3-A: 카드 정보 위계 재설계
- **1순위 (시선 집중)**: 댓글 텍스트 -- 20px, w600, 좌측정렬, line-height 1.5
- **2순위 (판단 보조)**: 좋아요 수 -- 16px, 하트 아이콘과 함께 카드 하단 좌측에 배치
- **3순위 (맥락 제공)**: 프로필 -- 28x28 아바타 + 닉네임 10px w500, 카드 상단에 작게
- **4순위 (게임 정보)**: 난이도 뱃지 -- 카드 우상단 작은 태그
- 텍스트 좌측정렬로 변경 (가독성 개선)
- **재미: 6** | **심플함: 9** | **구현용이: 9**

### 개선안 3-B: 카드 크기 반응형 + 엄지 최적화
- 세로가 긴 댓글: 카드 높이 유동적 (max: 화면 높이 40%)
- 짧은 댓글: 최소 높이 보장 (화면 높이 25%)
- 카드 하단 여백을 충분히 두어 아이템바 접근성 확보
- **재미: 5** | **심플함: 7** | **구현용이: 7**

### 다음 라운드 의문점
- Haptic 피드백은 어떻게 적용할 것인가?

---

## Round 4: Haptic 피드백 설계

### 리서치 키워드
"mobile game haptic feedback vibration pattern swipe gesture iOS Android implementation best practices", "flutter haptic feedback implementation HapticFeedback light medium heavy vibrate package"

### 발견 사항

**Haptic 설계 원칙:**
- "Less is more" -- 과도한 진동은 짜증을 유발하고 감각을 마비시킴
- 트리거 타이밍: 액션 완료, 상태 변화, 위험 경고 시 정확히 실행
- 지연 시간 10ms 미만 -- 시각/청각과 동기화되어야 뇌가 하나의 이벤트로 인식
- 단순한 패턴 사용, 복잡한 정보 전달에 haptic 사용 금지

**Flutter 구현:**
- `HapticFeedback.lightImpact()`: iOS UIImpactFeedbackStyleLight / Android VIRTUAL_KEY
- `HapticFeedback.mediumImpact()`: iOS UIImpactFeedbackStyleMedium / Android KEYBOARD_TAP
- `HapticFeedback.heavyImpact()`: 강한 충격
- `HapticFeedback.selectionClick()`: 선택 피드백 (가장 미묘)
- 서드파티 `haptic_feedback` 패키지: success/warning/error/rigid/soft 지원

### 현재 게임에 적용 시 토의

Comment Corp은 빠른 판단 게임이므로 haptic은 "결과 확인"과 "위험 알림"에 집중해야 함. 매 스와이프마다 진동하면 120초 동안 수십 번 진동 -- 이는 "감각 마비"를 유발.

핵심 순간에만 적용:
1. 정답 스와이프 확정 시: lightImpact (미묘한 확인감)
2. 오답 시: mediumImpact + 짧은 정지감 (실수 인지)
3. 멘탈 30% 이하: warning 패턴 (경고)
4. 피버 모드 진입: heavyImpact (큰 이벤트 감각)
5. 콤보 5/10/20 달성: selectionClick 연타 패턴

### 개선안 4-A: 상황별 Haptic 피드백 시스템
- 정답: `HapticFeedback.lightImpact()` -- 1회
- 오답: `HapticFeedback.mediumImpact()` -- 1회
- 콤보 마일스톤 (5/10/20): `HapticFeedback.selectionClick()` x 2 (더블 탭 느낌)
- 피버 진입: `HapticFeedback.heavyImpact()` -- 1회
- 멘탈 위험 (30% 이하, 첫 도달 시만): `HapticFeedback.heavyImpact()` -- 1회
- 게임 오버: `HapticFeedback.heavyImpact()` x 3 (점점 세지는 패턴)
- **재미: 7** | **심플함: 8** | **구현용이: 9**

### 다음 라운드 의문점
- 카드 진입/퇴장 애니메이션과 다음 카드 미리보기는?

---

## Round 5: 카드 진입/퇴장 애니메이션 & 다음 카드 미리보기

### 리서치 키워드
"card entry exit animation spring physics bounce easing mobile game micro interaction", "swipe card stacked deck preview next card animation mobile UX pattern peek behind"

### 발견 사항

**Spring vs. Bounce 애니메이션:**
- Bounce: 정해진 easing curve와 타이밍 사용
- Spring: 물리 기반으로 실시간 계산 -- 제스처 velocity를 자연스럽게 이어받음
- 바운시: mass 1.0, stiffness 100, damping 10
- 인터랙티브 요소: stiffness 200-300 (빠른 피드백)
- 부드러운 진입: stiffness 50, damping 20

**스택 카드 미리보기:**
- 시각적 레이어링: 뒤 카드들이 약간 축소되고 오프셋되어 덱의 깊이감 제공
- 스택 카드 수 제한: 일반적으로 2-3장 표시
- 현재 카드 스와이프 시 뒤 카드가 동시에 스케일업 + 올라옴
- 제스처에 따른 연동: 현재 카드를 끌수록 다음 카드가 점진적으로 커지는 인터랙션

**Squash & Stretch 원칙:**
- 카드 진입 시 살짝 늘어났다 원래 크기로 -- "착지" 느낌
- 강한 액션(빠른 스와이프)에는 더 큰 변형, 느린 액션에는 작은 변형

### 현재 게임에 적용 시 토의

현재 Comment Corp은 카드 진입 애니메이션이 없어서 "즉시 표시"됨. 이는 카드 교체 시 시각적 연결고리가 없어 "뚝뚝 끊기는" 느낌을 줌.

다음 카드 미리보기(peek)를 2장 표시하면:
1. 아직 처리할 댓글이 있다는 게임 상태 인지
2. "다음은 뭘까?" 하는 기대감 (물론 내용은 가려야 함)
3. 시각적 깊이감으로 인한 세련된 느낌

### 개선안 5-A: 스택형 카드 미리보기 (2장 Peek)
- 현재 카드 뒤에 2장의 카드가 보임 (내용은 블러 처리 또는 뒷면)
- 2번째 카드: scale 0.95, Y offset +8px, opacity 0.6
- 3번째 카드: scale 0.90, Y offset +16px, opacity 0.3
- 현재 카드를 드래그하면 뒤 카드들이 점진적으로 scale up
- **재미: 8** | **심플함: 7** | **구현용이: 6**

### 개선안 5-B: 카드 진입 애니메이션 (Spring Pop-in)
- 새 카드가 아래에서 위로 spring 등장 (stiffness: 200, damping: 15)
- 등장 시 살짝 scale 1.05 -> 1.0 (squash/stretch)
- 등장 소요 시간: ~300ms (spring이 settle되는 시간)
- Phase 4-5(빠른 구간)에서는 spring 더 빠르게 (stiffness: 350)
- **재미: 7** | **심플함: 8** | **구현용이: 7**

### 다음 라운드 의문점
- 스와이프 방향 인디케이터와 색상 피드백을 어떻게 개선할 것인가?

---

## Round 6: 스와이프 방향 인디케이터 & 색상 피드백 강화

### 리서치 키워드
"mobile game swipe direction indicator visual cue color gradient overlay approve reject UX", "swipe card game accessibility color blind friendly indicators shape icon alternative feedback"

### 발견 사항

**방향 인디케이터 설계:**
- 화살표는 명시적 방향 큐이지만 게임에서는 과도할 수 있음
- 색상 코딩: 초록 = 승인, 빨강 = 거부 -- 보편적이지만 색맹 접근성 문제
- Hint motion: 애니메이션으로 인터랙션 방법 자체를 보여주는 기법
- Content tease: 뒤에 다른 카드가 있음을 보여주면 스와이프 가능성을 암시

**접근성 (색맹 대응):**
- 색상만으로 정보 전달 금지 -- 반드시 아이콘/패턴/텍스트 병행
- 체크마크(v)와 X 아이콘: 색상과 무관하게 즉시 인식
- 일관된 위치(예: 카드 좌상단)에 심볼 배치
- 빗금(hatching), 점, 텍스처와 색상 병행

**현재 시스템 분석:**
- ratio 0.2에서 색상 tint + "BLOCK"/"APPROVE" 텍스트 표시
- 빨강/초록만 사용 -- 적록 색맹에 완전히 불리
- 텍스트 인디케이터는 영어 -- 한국어 게임인데 영어 사용이 불일치

### 현재 게임에 적용 시 토의

현재 인디케이터 시스템은 기능적이지만 "제가 어디로 가고 있는지"를 충분히 전달하지 못함. 특히:
1. ratio 0.2는 너무 늦은 피드백 -- 드래그 시작 즉시 방향감을 줘야 함
2. 색상만으로 판단하면 접근성 문제
3. 영어 텍스트 "BLOCK"/"APPROVE"는 불필요한 인지 부하

### 개선안 6-A: 점진적 방향 피드백 시스템
- **Phase 1 (ratio 0.05~)**: 카드 가장자리에 미묘한 그림자 색상 변화 시작
- **Phase 2 (ratio 0.15~)**: 아이콘 등장 -- 좌측 X (빨강), 우측 체크마크 (초록)
- **Phase 3 (ratio 0.25~)**: 아이콘 커지고, 배경 tint 강해짐, 텍스트 "차단" / "승인" 표시
- 아이콘은 색상과 독립적으로 의미 전달 (X = 차단, V = 승인)
- 배경 overlay에 빗금 패턴 추가 (색맹 모드 옵션)
- **재미: 7** | **심플함: 7** | **구현용이: 7**

### 개선안 6-B: 카드 기울기 연동 동적 그림자
- 드래그 방향에 따라 카드 그림자가 반대로 이동 -- 조명 효과
- 좌로 기울면 우측에 짙은 그림자, 우로 기울면 좌측에 짙은 그림자
- 그림자 색상도 방향에 따라 변화 (좌=빨강 계열, 우=초록 계열)
- 물리적 실재감 강화 -- "카드를 진짜 들고 있는" 느낌
- **재미: 6** | **심플함: 6** | **구현용이: 5**

### 다음 라운드 의문점
- 게임 "juice" -- 스와이프 확정 시 쾌감을 극대화하는 이펙트는?

---

## Round 7: Game Juice -- 스와이프 쾌감 극대화 이펙트

### 리서치 키워드
"swipe game juice feel polish screen shake particles trail effect mobile casual game", "combo system visual feedback escalation mobile game streak counter screen effects glow shake intensity progressive"

### 발견 사항

**Game Juice의 핵심 요소:**
- 스크린 셰이크: 가장 보편적이고 효과적인 즉각 피드백. 강도와 방향 제어 중요.
- 파티클: "쥬시한 게임의 가장 친한 친구". 충격, 확인, 축하 모두에 활용.
- 트레일 이펙트: 카드가 날아갈 때 잔상을 남기면 속도감 증가.
- UI 폴리시: 버튼 반응, 숫자 카운터 애니메이션 등이 전체적 "살아있는" 느낌.
- 중요: juice는 핵심 게임플레이를 반영(echo)해야 함 -- 불필요한 이펙트는 오히려 방해.

**콤보/스트릭 시각 에스컬레이션:**
- 콤보 레벨에 따른 점진적 이펙트 강화가 핵심
- 콤보 5+: 카운터 흔들림(shake) 시작
- 콤보 10+: 화면 테두리 글로우 강화
- 콤보 20+: 파티클 분출 + 화면 전체 색감 변화
- 피버 모드: 모든 이펙트 최대치 + 배경 맥동(pulse)

### 현재 게임에 적용 시 토의

현재 Comment Corp의 피드백은 "정답/오답 플래시" (초록/빨강 overlay, 400ms)만 존재. 이것은 "맞다/틀렸다"를 알려주지만 "쾌감"을 주지는 못함.

시간 압박 게임에서는 빠르고 강렬한 피드백이 핵심. 특히 콤보 시스템이 이미 구현되어 있으므로(5+, 10+, 20+ 콤보), 이에 맞는 시각적 에스컬레이션이 필수.

### 개선안 7-A: 스와이프 확정 시 Juice 패키지
- **기본**: 카드 퇴장 시 미세 스크린 셰이크 (2px, 50ms) + 작은 파티클 버스트
- **정답 시**: 카드 퇴장 방향으로 초록 파티클 흩뿌림 (5-8개, 300ms)
- **오답 시**: 빨강 파티클 + 화면 살짝 붉어짐 (150ms) + 셰이크 강화 (4px, 100ms)
- **카드 트레일**: 퇴장 시 카드 뒤에 흐릿한 잔상 3프레임 (opacity 0.3 -> 0)
- **점수 팝업**: "+150" 숫자가 카드 퇴장 위치에서 떠올라 사라짐 (scale 1.0->1.3->0, 500ms)
- **재미: 9** | **심플함: 6** | **구현용이: 5**

### 개선안 7-B: 콤보 에스컬레이션 시각 시스템
- **콤보 0-4**: 기본 피드백 (셰이크 없음)
- **콤보 5-9 (1.5x)**: 콤보 뱃지 펄스 + 카드 테두리에 미세 금색 글로우
- **콤보 10-19 (2x)**: 화면 테두리 주황 글로우 + 배경에 미세한 파티클 상승
- **콤보 20+ (3x, 피버)**: 화면 전체 황금빛 맥동 + 대형 파티클 + "FEVER" 텍스트 애니메이션(진입 시) + 배경 색상 시프트 + 카드 테두리 무지개빛 순환
- 각 콤보 마일스톤 돌파 시: 숫자 확대 팝 + 짧은 폭죽 파티클
- **재미: 9** | **심플함: 5** | **구현용이: 4**

### 다음 라운드 의문점
- 카드의 물리적 존재감을 높이는 시각 기법 (parallax, 3D depth, 동적 그림자)은?

---

## Round 8: 카드의 물리적 존재감 -- Parallax, 3D Depth, 동적 효과

### 리서치 키워드
"mobile card swipe animation parallax depth effect shadow elevation dynamic tilt gyroscope", "card swipe micro animation satisfying wobble squash stretch anticipation follow through game feel polish"

### 발견 사항

**Parallax와 3D Depth:**
- 다중 레이어로 카드 내부에 깊이감 생성 (배경, 텍스트, 아이콘이 각각 다른 속도로 이동)
- transform-style: preserve-3d로 실제 3D 회전
- 드래그 방향에 따른 동적 tilt (rotateX/rotateY)
- 그림자가 기울기 반대 방향으로 이동 -- 조명 시뮬레이션
- 자이로스코프: 기기 기울기에 따라 카드가 살짝 반응 (미묘한 parallax)

**Squash & Stretch (디즈니 12원칙 적용):**
- 카드 착지: 약간 눌려졌다(squash) 원래 형태로 복원
- 카드 퇴장: 이동 방향으로 살짝 늘어남(stretch)
- 강한 액션 = 큰 변형, 약한 액션 = 작은 변형
- 후속 동작(follow-through): 카드 내부 요소가 카드보다 살짝 늦게 따라옴

### 현재 게임에 적용 시 토의

현재 카드는 단일 레이어 -- 프로필, 텍스트 모두 하나의 위젯으로 이동. 이는 "종이 한 장"을 움직이는 느낌. 카드 내부에 미세한 parallax를 적용하면 "두께가 있는 카드"처럼 느껴짐.

다만, Comment Corp은 2초마다 판단을 내려야 하는 빠른 게임이므로, 시각적 효과가 판단을 방해하면 안 됨. Parallax는 극히 미묘하게(1-3px 차이), 자이로스코프는 옵션으로.

### 개선안 8-A: 미세 Parallax 카드 내부 깊이감
- 카드 드래그 시 내부 레이어 분리: 배경 1px, 텍스트 0.5px, 프로필 0.3px 차이로 이동
- 카드 정지 상태에서 자이로스코프로 +-2px 미세 반응 (선택적)
- **재미: 6** | **심플함: 5** | **구현용이: 4**

### 개선안 8-B: Squash/Stretch 카드 동적 변형
- 카드 퇴장 시: 이동 방향으로 scaleX 1.05, 반대 방향 scaleY 0.97 (stretch)
- 새 카드 등장 시: scaleY 1.03 -> 1.0 (착지 squash)
- 빠른 스와이프일수록 변형 크게 (velocity 연동)
- 매우 미묘한 효과(3-5% 변형)이지만 무의식적으로 "살아있는" 느낌
- **재미: 7** | **심플함: 7** | **구현용이: 6**

### 다음 라운드 의문점
- 온보딩과 튜토리얼에서 스와이프를 어떻게 가르칠 것인가?

---

## Round 9: 스와이프 온보딩 & 난이도에 따른 인터랙션 변화

### 리서치 키워드
"swipe card game onboarding tutorial first time user experience gesture teaching mobile", "progressive difficulty swipe speed increase card game pacing tension curve mobile game design"

### 발견 사항

**온보딩 베스트 프랙티스:**
- "가장 좋은 앱 온보딩은 제스처를 실제 행동으로 가르치는 것" -- 스와이프를 하게 만들어서 배우게 함
- Progressive disclosure: 한 번에 하나의 인터랙션만 교육
- Just-in-time tips: 해당 기능이 필요한 순간에 설명
- 슬라이드 캐러셀 형태의 온보딩은 스와이프 자체를 연습시키는 효과
- 튜토리얼은 최후의 수단 -- 문맥 내 교육이 최선

**난이도와 인터랙션의 관계:**
- 최적 난이도: 플레이어 스킬보다 살짝 높은 수준
- sqrt 함수 커브: 초반 빠른 상승 후 완만 -- 모바일 게임에 적합
- 동적 난이도 조정(DDA): 승률, 소요시간 등으로 실시간 조정
- 긴장과 이완의 교차: 완벽한 강도 곡선은 불가능, 피크와 트로프의 교차가 핵심

### 현재 게임에 적용 시 토의

현재 Comment Corp은 "How to Play" 박스로 "좌 = 차단, 우 = 승인"을 알려주지만, 이것은 텍스트 설명일 뿐 실제 체험이 아님.

P1(0-30초)의 interval 2.0s, toxic 30%, max_diff 1은 이미 "온보딩 구간"처럼 설계되어 있으나, 첫 카드에서 실제로 스와이프를 유도하는 인터랙션이 없음.

### 개선안 9-A: 인터랙티브 첫 3장 튜토리얼
- 최초 플레이 시 첫 3장은 특별 처리:
  - 1장째: "이 댓글을 왼쪽으로 밀어 차단하세요" + 손가락 애니메이션 가이드
  - 2장째: "이 댓글을 오른쪽으로 밀어 승인하세요" + 가이드
  - 3장째: "이제 직접 판단해 보세요!" + 가이드 없음
- 타이머는 튜토리얼 3장 동안 정지 (또는 별도 튜토리얼 모드)
- 2회째 플레이부터는 건너뜀
- **재미: 6** | **심플함: 8** | **구현용이: 7**

### 개선안 9-B: 페이즈별 인터랙션 변화
- **P1-P2**: 기본 스와이프, 여유로운 타이밍, 카드 진입 부드럽게
- **P3**: 카드 진입 속도 증가, 미세 스크린 셰이크 시작 (긴장감)
- **P4**: 카드 등장 시 살짝 흔들림(wobble), 배경 어두워짐, 파티클 증가
- **P5 (마지막 10초)**: 카드 테두리 붉은 맥동, 숫자 타이머 확대, 매우 빠른 진입 spring
- Phase 진입 시 짧은 "Phase X!" 텍스트 팝 (500ms) + 화면 번쩍임
- **재미: 8** | **심플함: 6** | **구현용이: 6**

### 다음 라운드 의문점
- 전체적인 시각 테마, 다크모드, 그리고 "실수 용서" 메카닉은?

---

## Round 10: 시각 테마, 다크모드, 실수 용서 메카닉

### 리서치 키워드
"card design dark mode light mode mobile game color palette comment social media aesthetic 2026", "swipe gesture cancel undo mechanic mobile game forgiveness error recovery UX"

### 발견 사항

**2026 다크모드 트렌드:**
- near-black (#121212, #1A1A1A) 배경 -- pure black 금지 (눈 피로)
- 어두운 배경 + bold accent color로 시선 유도
- 네온 그라디언트, 발광 아이콘, 글로우 액센트가 주요 트렌드
- 다크모드에서는 accent color의 채도/밝기를 별도 조정 필요
- 배경과 텍스트 최소 대비 15.8:1

**실수 용서 (Error Recovery):**
- Undo: 전용 버튼, 스와이프 제스처, 흔들기 제스처, 컨텍스트 메뉴 등으로 구현
- 게임에서: "플레이어는 무죄 추정" -- 실수에 대한 비난 금지
- 확정 전 취소 기회: 스와이프 threshold 이전에 손을 떼면 복귀
- Tinder의 "되돌리기" 기능은 프리미엄 기능으로 수익화 (게임에서도 적용 가능)

### 현재 게임에 적용 시 토의

**다크모드:**
현재 배경 #FAFAFA (밝은 회색)는 소셜 미디어 앱 느낌을 주지만, 게임으로서의 몰입감은 부족. 다크모드를 기본으로 하면:
- Comment Corp의 핑크/민트 accent가 더 돋보임
- 게임적 몰입감 증가
- 배터리 절약 (OLED)
- 밤시간 플레이 편의성

다만, "소셜 미디어 댓글을 관리한다"는 설정상 밝은 테마도 설득력이 있음. 선택지 제공이 최선.

**실수 용서:**
Comment Corp에서 "오답 스와이프"는 멘탈 데미지로 이어짐. 완전한 undo는 게임의 긴장감을 깨트리므로 부적절하나, "1회성 되돌리기" 아이템은 전략적 깊이를 추가.

### 개선안 10-A: 다크모드 지원 + 카드 시각 강화
- 배경: #1A1A1A, 카드: #2D2D2D (미세한 elevation 차이)
- 텍스트: #EEEEEE (primary), #9E9E9E (secondary)
- Accent 색상 조정: 핑크 #FF8EB3 (밝기 +), 민트 #6EEBD5 (채도 +)
- 카드 그림자: 다크모드에서는 그림자 대신 미세한 밝은 테두리 (1px, #3A3A3A)
- 토글: 설정에서 라이트/다크 전환
- **재미: 5** | **심플함: 6** | **구현용이: 6**

### 개선안 10-B: "되돌리기" 아이템 추가
- 5번째 아이템: ↩ 아이콘, 금색(#FFD700), 1회
- 마지막 스와이프를 취소하고 해당 카드를 다시 표시
- 되돌리기 시 카드가 화면 밖에서 역방향으로 날아와 복귀
- 시간은 계속 흐름 (멈추지 않음) -- 전략적 선택: 시간 소모 vs 실수 만회
- 피버 모드 중에는 사용 불가 (남용 방지)
- **재미: 8** | **심플함: 7** | **구현용이: 5**

---

## 최종 상위 10개 개선안 (종합 스코어 순)

> 종합 스코어 = 재미 + 심플함 + 구현용이

| 순위 | 개선안 | 재미 | 심플함 | 구현용이 | 종합 | 요약 |
|------|--------|------|--------|----------|------|------|
| **1** | 2-A: 비율 기반 스와이프 Threshold | 7 | 9 | 8 | **24** | 80px 고정 -> 화면폭 25% + velocity 500px/s 듀얼 체크. 디바이스 일관성 확보. |
| **2** | 4-A: 상황별 Haptic 피드백 시스템 | 7 | 8 | 9 | **24** | 정답=light, 오답=medium, 피버=heavy, 콤보 마일스톤=selectionClick. Flutter 내장 API. |
| **3** | 3-A: 카드 정보 위계 재설계 | 6 | 9 | 9 | **24** | 댓글 텍스트 최우선, 좋아요 수 2순위, 프로필 축소. 좌측정렬. |
| **4** | 1-B: 카드 퇴장/진입 오버랩 | 8 | 8 | 7 | **23** | 퇴장 카드 50% 사라질 때 다음 카드 진입 시작. 끊김 없는 흐름. |
| **5** | 5-B: Spring Pop-in 카드 진입 | 7 | 8 | 7 | **22** | 아래에서 spring으로 등장, scale 1.05->1.0. Phase에 따라 stiffness 변동. |
| **6** | 6-A: 점진적 방향 피드백 시스템 | 7 | 7 | 7 | **21** | 3단계 피드백 (미묘한 색상 -> 아이콘 -> 텍스트+강한 tint). 색맹 대응. |
| **7** | 2-B: Spring 물리 기반 카드 애니메이션 | 8 | 7 | 6 | **21** | 퇴장=빠른 spring+velocity, 복귀=오버슈트 spring. easeIn/Out 대체. |
| **8** | 5-A: 스택형 카드 미리보기 | 8 | 7 | 6 | **21** | 현재 카드 뒤에 2장 peek. scale/offset/opacity 차등. 드래그 연동. |
| **9** | 9-A: 인터랙티브 첫 3장 튜토리얼 | 6 | 8 | 7 | **21** | 최초 플레이 시 3장 가이드. 손가락 애니메이션. 2회째부터 스킵. |
| **10** | 10-B: "되돌리기" 아이템 | 8 | 7 | 5 | **20** | 1회용 undo 아이템. 역방향 카드 복귀 애니메이션. 시간은 계속 흐름. |

### 차점자 (참고용)

| 순위 | 개선안 | 종합 | 제외 사유 |
|------|--------|------|-----------|
| 11 | 8-B: Squash/Stretch 카드 변형 | 20 | 미묘한 효과로 우선순위 낮음 |
| 12 | 9-B: 페이즈별 인터랙션 변화 | 20 | 재미 높으나 구현 복잡 |
| 13 | 7-A: 스와이프 확정 시 Juice 패키지 | 20 | 파티클 시스템 구현 비용 높음 |
| 14 | 3-B: 카드 크기 반응형 | 19 | 기본 개선 (심플하나 재미 기여 낮음) |
| 15 | 7-B: 콤보 에스컬레이션 시각 시스템 | 18 | 재미 최고점(9)이나 구현 매우 복잡 |
| 16 | 10-A: 다크모드 지원 | 17 | 전체 테마 작업으로 범위 큼 |
| 17 | 6-B: 카드 기울기 연동 동적 그림자 | 17 | 미묘한 시각 개선, 우선순위 낮음 |
| 18 | 1-A: 부분 스와이프 감정 힌트 | 16 | 재미있으나 복잡, 게임 속도와 충돌 가능 |
| 19 | 8-A: 미세 Parallax 내부 깊이감 | 15 | 시각적 향상이나 판단 게임에서 우선순위 낮음 |

---

## 구현 우선순위 로드맵 제안

### Phase A: 기초 인터랙션 개선 (1-2일)
1. **비율 기반 threshold** (#2-A) -- 단순 값 변경
2. **카드 정보 위계 재설계** (#3-A) -- 레이아웃 조정
3. **Haptic 피드백 추가** (#4-A) -- Flutter 내장 API 호출만

### Phase B: 애니메이션 시스템 교체 (2-3일)
4. **Spring 물리 기반 애니메이션** (#2-B) -- AnimationController 교체
5. **카드 진입 Spring Pop-in** (#5-B) -- 새 애니메이션 추가
6. **카드 퇴장/진입 오버랩** (#1-B) -- 타이밍 로직 수정

### Phase C: 피드백 시스템 강화 (2-3일)
7. **점진적 방향 인디케이터** (#6-A) -- 3단계 피드백 구현
8. **스택 카드 미리보기** (#5-A) -- 스택 위젯 구조 변경

### Phase D: 신규 기능 (1-2일)
9. **인터랙티브 튜토리얼** (#9-A) -- 최초 실행 감지 + 가이드 오버레이
10. **되돌리기 아이템** (#10-B) -- 아이템 시스템 확장

---

## 기술 참조 (Flutter 구현 힌트)

### Spring 물리 설정값 참고
```dart
// 카드 퇴장 (빠르고 결정적)
SpringDescription exitSpring = SpringDescription(
  mass: 0.5,
  stiffness: 250,
  damping: 15,
);

// 카드 복귀 (살짝 바운스)
SpringDescription returnSpring = SpringDescription(
  mass: 1.0,
  stiffness: 150,
  damping: 12,
);

// 카드 진입 (부드러운 pop)
SpringDescription entrySpring = SpringDescription(
  mass: 0.8,
  stiffness: 200,
  damping: 15,
);
```

### Haptic 패턴 참고
```dart
// 정답
HapticFeedback.lightImpact();

// 오답
HapticFeedback.mediumImpact();

// 콤보 마일스톤
HapticFeedback.selectionClick();
await Future.delayed(Duration(milliseconds: 50));
HapticFeedback.selectionClick();

// 피버 진입
HapticFeedback.heavyImpact();
```

### 비율 기반 Threshold 참고
```dart
final screenWidth = MediaQuery.of(context).size.width;
final positionThreshold = screenWidth * 0.25; // 화면 폭의 25%
final velocityThreshold = 500.0; // px/s

bool shouldConfirmSwipe(double dragDistance, double velocity) {
  return dragDistance.abs() > positionThreshold ||
         velocity.abs() > velocityThreshold;
}
```

---

## 라운드별 리서치 소스

### Round 1
- [Mobile-First UX Patterns: Design Strategies Driving Engagement in 2026](https://tensorblue.com/blog/mobile-first-ux-patterns-driving-engagement-design-strategies-for-2026)
- [Game Design Deep Dive: Creating an adaptive narrative in Reigns](https://www.gamedeveloper.com/design/game-design-deep-dive-creating-an-adaptive-narrative-in-i-reigns-i-)
- [The Casual (but Regal) Swipe: Creating Game Mechanics in 'Reigns' (GDC)](https://www.gdcvault.com/play/1024278/The-Casual-(but-Regal)-Swipe)

### Round 2
- [Flutter: Animate a widget using a physics simulation](https://docs.flutter.dev/cookbook/animation/physics-simulation)
- [flutter_card_swiper package](https://pub.dev/packages/flutter_card_swiper)
- [Building a Tinder-esque Card Interface](https://medium.com/@phillfarrugia/building-a-tinder-esque-card-interface-5afa63c6d3db)

### Round 3
- [17 Card UI Design Examples and Best Practices](https://www.eleken.co/blog-posts/card-ui-examples-and-best-practices-for-product-owners)
- [4 Layout Tips for Designing Card Games](https://medium.com/@dylanmangini/4-layout-tips-for-designing-card-games-17cc98b89b96)
- [Touch Targets on Touchscreens - NN/g](https://www.nngroup.com/articles/touch-target-size/)
- [Finger-Friendly Design: Ideal Mobile Touch Target Sizes](https://uxmovement.com/mobile/finger-friendly-design-ideal-mobile-touch-target-sizes/)

### Round 4
- [2025 Guide to Haptics: Enhancing Mobile UX](https://saropa-contacts.medium.com/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback-676dd5937774)
- [Haptics design principles - Android Developers](https://developer.android.com/develop/ui/views/haptics/haptics-principles)
- [HapticFeedback class - Flutter API](https://api.flutter.dev/flutter/services/HapticFeedback-class.html)
- [haptic_feedback Flutter package](https://pub.dev/packages/haptic_feedback)

### Round 5
- [Spring animations theory](https://animations.dev/learn/animation-theory/spring-animations)
- [SwipeableStack - FlutterFlow Documentation](https://docs.flutterflow.io/resources/ui/widgets/built-in-widgets/swipeable-stack/)
- [Creating a smooth stacked cards animation in Flutter](https://liquidatorcoder.medium.com/creating-a-smooth-stacked-cards-animation-in-flutter-4c03db79ee68)

### Round 6
- [How to Get Users to Swipe Content on Mobile Screens](https://uxmovement.medium.com/how-to-get-users-to-swipe-content-on-mobile-screens-e0648b51c9d0)
- [Unlocking Colorblind Friendly Game Design](https://chrisfairfield.com/unlocking-colorblind-friendly-game-design/)
- [Accessible UI Design for Color Blindness](https://rgblind.com/blog/accessible-ui-design-for-color-blindness)

### Round 7
- [Juice in Game Design: Making Your Games Feel Amazing](https://www.bloodmooninteractive.com/articles/juice.html)
- [Squeezing more juice out of your game design - GameAnalytics](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design)
- [The Design of Combos and Chains - Game Developer](https://www.gamedeveloper.com/design/the-design-of-combos-and-chains)

### Round 8
- [SwiftUI: How to Create a 3D Flip Card with Parallax Effect](https://medium.com/@jc_builds/swiftui-tutorials-how-to-create-a-3d-flip-card-with-parallax-effect-d75b2cd22d38)
- [Squash and Stretch: The 12 Basic Principles of Animation](https://www.animationmentor.com/blog/squash-and-stretch-the-12-basic-principles-of-animation/)
- [A (more) realistic card flip animation](https://auroratide.com/posts/realistic-flip-animation/)

### Round 9
- [How To Communicate Hidden Gestures in Mobile App](https://uxplanet.org/how-to-communicate-hidden-gestures-in-mobile-app-e55397f4006b)
- [Pacing and Progression in Game Design](https://www.bloodmooninteractive.com/articles/pacing-and-progression.html)
- [Difficulty curves: how to get the right balance](https://www.gamedeveloper.com/design/difficulty-curves-how-to-get-the-right-balance-)

### Round 10
- [Dark Mode Design Best Practices in 2026](https://www.tech-rz.com/blog/dark-mode-design-best-practices-in-2026/)
- [Best 8 Mobile App Color Scheme Trends for 2026](https://elements.envato.com/learn/color-scheme-trends-in-mobile-app-design)
- [Error Recovery UX: That Protects a Game's Reputation](https://www.criticalhit.net/gaming/error-recovery-ux-that-protects-a-games-reputation)
