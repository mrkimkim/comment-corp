# Comment Corporation -- 결과 화면 + 보상감 리서치 & 토의 기록

> 전문 영역: 게임 보상 시스템 / 결과 화면 UX
> 10 Rounds of Research + Discussion
> Date: 2026-04-09
> Scoring: Total = (Impact x3 + Feasibility x2 + Retention x3 + Polish x1 + Delight x1) / 10

---

## 현재 상태 진단

현재 `ResultScreen`은 다음과 같은 상태이다:

| 항목 | 현재 구현 | 문제점 |
|------|-----------|--------|
| 결과 화면 진입 | 즉시 전환 | 게임 오버 감정을 처리할 시간 없음 |
| 점수 표시 | 즉시 최종 점수 표시 (48px) | 카운트업 없이 정적이라 보상감 없음 |
| 등급 공개 | 즉시 뱃지 표시 (S/A/B/C/D) | 서프라이즈 요소 0, 기대감 0 |
| 스탯 표시 | 6개 동시 표시 | 정보 과부하, 읽는 순서 없음 |
| 최고 기록 갱신 | 표시 없음 | 갱신 여부를 알 수 없음 |
| 공유 기능 | 없음 | 바이럴 잠재력 활용 못함 |
| 리더보드 | 없음 | 경쟁 동기 부여 없음 |
| "한 번 더" 동기 | "다시 플레이" 버튼만 존재 | near-miss 정보 제공 없음 |

**핵심 문제: 120초의 긴장감 넘치는 게임플레이가 끝나는 순간, 결과 화면이 "플랫"하게 떨어진다. 감정 곡선의 정점에서 골짜기로 추락.**

---

## Round 1: 모바일 게임 결과 화면 디자인 기초

### 리서치 요약
- **즉각적 피드백의 중요성**: 플레이어 행동에 대해 빛나는 버튼, 축하 사운드 등으로 즉각 반응해야 도파민 반응 유발 ([UI/UX for Game Design](https://www.trinergydigital.com/news/ui-ux-for-game-design-key-elements-for-gamified-interfaces))
- **버튼 색상 전략**: "Done" 대신 "Claim"처럼 성취감을 주는 문구 사용, 긍정적 액션은 초록색 ([Game Design UX Best Practices](https://uxplanet.org/game-design-ux-best-practices-guide-4a3078c32099))
- **2025 트렌드**: 미니멀 인터페이스, 개인화된 경험, 진행 지표(바, 마일스톤, 뱃지) 활용 ([UX Design Trends for Mobile Games 2025](https://redappletechnologies.medium.com/user-experience-ux-design-trends-for-mobile-games-in-2025-ff8293c63d87))
- **도파민 루프**: 빠르고 빈번한 피드백이 지연된 보상보다 주의력 유지에 효과적. 서프라이즈 보상이 예상된 보상보다 강한 도파민 반응 유발 ([The Dopamine Loop](https://medium.com/design-bootcamp/the-dopamine-loop-how-ux-designs-hook-our-brains-bd1a50a9f22e))

### 토의
Comment Corporation의 결과 화면은 현재 "정보 표시판"이지 "보상 경험"이 아니다. 게임 내에서 스와이프마다 정답/오답 플래시가 주는 즉각 피드백은 잘 되어 있는데, 결과 화면에서는 이 원칙이 완전히 사라진다. 120초 동안 쌓인 감정 에너지를 해소(release)하는 과정이 필요하다. 이것은 음악의 클라이맥스 이후 코다(coda)와 같다.

### 스코어링: "결과 화면 진입 전환 연출"
| 항목 | 점수 |
|------|------|
| Impact | 9 |
| Feasibility | 8 |
| Retention | 7 |
| Polish | 9 |
| Delight | 9 |
| **Total** | **8.4** |

### 다음 라운드 의문점
- 등급 공개를 어떻게 "이벤트"로 만들 수 있는가?
- Near-miss 표시가 실제로 리텐션에 얼마나 기여하는가?

---

## Round 2: 등급 공개 연출 + Near-Miss 심리학

### 리서치 요약
- **등급 시스템의 심리**: S/A/B/C/D 같은 Gameplay Grading은 플레이어에게 명확한 목표와 자기 평가 기준을 제공. 등급 공개 순간이 "보상 이벤트" 자체가 되어야 함 ([Gameplay Grading - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/GameplayGrading))
- **Near-Miss 효과**: "거의 성공할 뻔한" 경험이 승리나 완전한 패배보다 더 강한 동기 부여 유발. 같은 신경 회로(도파민 스파이크, 보상 예측 오류)가 활성화 ([The Near Miss Effect](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/))
- **자기 효능감 강화**: Near-miss는 "내 방법이 통했다, 조금만 더 하면 된다"는 자기 효능감을 증가시켜 재도전 의지 강화 ([The Near-Miss Effect and Almost-Winning Mechanics](https://medium.com/@milijanakomad/the-near-miss-effect-and-almost-winning-mechanics-378de92f88a8))
- **프레이밍 효과**: "실패를 성공에 대한 근접"으로 재프레이밍하면 좌절이 아니라 동기로 전환. "Almost-winning mechanics exploit cognitive biases that cause failure to be misinterpreted as progress" ([Near-miss effect - Wikipedia](https://en.wikipedia.org/wiki/Near-miss_effect))

### 토의
현재 등급 뱃지가 즉시 표시되는 것은 큰 낭비다. 등급 공개 순간은 가차(gacha)의 "뽑기 연출"과 동일한 기대-해소 구조를 활용해야 한다. 카운트업으로 점수가 올라가는 동안 플레이어는 "혹시 A등급 넘을까?"라는 기대를 갖게 되고, 이 기대감 자체가 도파민을 유발한다.

Near-miss는 Comment Corporation에 특히 효과적이다. 등급 경계선이 명확(S: 50000, A: 30000, B: 15000, C: 5000)하기 때문에 "A등급까지 1,240점 남았습니다"라는 표시가 매우 강력한 재도전 동기가 된다.

### 스코어링: "등급 공개 시퀀스 + Near-Miss 표시"
| 항목 | 점수 |
|------|------|
| Impact | 9 |
| Feasibility | 9 |
| Retention | 10 |
| Polish | 8 |
| Delight | 9 |
| **Total** | **9.1** |

### 다음 라운드 의문점
- Wordle 스타일 공유 카드를 Comment Corporation에 어떻게 최적화할 것인가?
- 최고 기록 갱신 시 어떤 연출이 가장 효과적인가?

---

## Round 3: Wordle 스타일 공유 카드 디자인

### 리서치 요약
- **Wordle 성공 요인**: "스포일러 없이 드라마를 보여주는" 컬러 그리드. 작은 그래프에 플레이어의 전체 여정이 시각적으로 압축 ([Why Wordle Went Viral](https://www.smithsonianmag.com/smart-news/heres-why-the-word-game-wordle-went-viral-180979439/))
- **공유 메커닉의 핵심**: 혼자 하는 게임을 공유 습관으로 변환. "사람들은 단순히 플레이하는 것이 아니라 결과를 비교하고, 포스팅하며, 솔로 활동을 공유 습관으로 전환" ([Wordle's viral marketing](https://beastoftraal.com/2022/01/04/wordles-viral-marketing-tactic-makes-brilliant-use-of-people-as-media/))
- **미니멀리즘의 힘**: Wordle의 미니멀한 디자인이 오히려 바이럴을 촉진. 복잡한 스크린샷이 아니라 텍스트 기반 이모지 그리드가 어떤 플랫폼에서든 자연스럽게 공유 가능 ([Wordle Minimalist Design](https://blockchain.news/ainews/why-wordle-s-minimalist-ai-design-drives-viral-engagement-analysis-business-insights))

### 토의
`final_ideas.md`에서 이미 4위로 선정된 "Wordle 스타일 결과 카드"를 결과 화면 UX 관점에서 더 발전시켜야 한다. 핵심은:

1. **결과 화면에서 공유 버튼의 위치와 타이밍**: 모든 연출이 끝난 후, 감정이 최고조일 때 공유 버튼이 등장해야 한다.
2. **카드 자체가 대화를 유발하는 디자인**: 이모지 그리드 한 줄로 120초의 드라마가 보여야 한다.
3. **이미지 카드 옵션**: 텍스트 공유 외에, RepaintBoundary를 활용한 시각적 카드도 제공. 인스타그램 스토리용.

기존 설계(12구간 이모지)에 추가로 고려할 점:
- 멘탈 브레이크인 경우 💀로 끝나는 것이 드라마틱
- 엔딩 카드 획득 시 카드명도 포함
- 셀럽별 고유 이모지 사용 (아이돌: ★, 정치인: 🏛 등)

### 스코어링: "공유 카드 시스템 (결과 화면 통합)"
| 항목 | 점수 |
|------|------|
| Impact | 9 |
| Feasibility | 9 |
| Retention | 8 |
| Polish | 8 |
| Delight | 9 |
| **Total** | **8.7** |

### 다음 라운드 의문점
- 최고 기록 갱신 연출의 구체적 방법은?
- 축하 이펙트(confetti, particles)의 최적 사용법은?

---

## Round 4: 최고 기록 갱신 연출 + 축하 이펙트

### 리서치 요약
- **행동에 대한 응답 필수**: "모든 플레이어 행동에는 반응이 있어야 한다 -- 탭에는 애니메이션이나 사운드, 성취에는 시각적 축하" ([Game UX High Score](https://pageflows.com/resources/game-ux-reaching-the-high-score/))
- **Fall Guys 사례**: 승리/통과 시 축하 메시지가 게임의 즐거운 톤을 강화
- **Candy Crush 사례**: 레벨 클리어 시 축하 메시지, UI가 매칭과 맵 이동을 보상적으로 느끼게 만듦
- **UI 애니메이션의 중요성**: 부드러운 전환, 인터랙티브 효과, 애니메이션 버튼이 인터페이스에 깊이와 감정을 더함 ([Hypercasual Games UI/UX](https://pixune.com/blog/hypercasual-games-ui-ux-design-guide/))

### 토의
최고 기록 갱신은 결과 화면에서 가장 강력한 "보상 이벤트"다. 현재는 이를 전혀 감지하지 못한다. 구현 방안:

1. **NEW BEST! 배너**: 카운트업이 이전 최고 기록을 넘는 순간, 카운트업이 잠시 멈추며 "NEW BEST!" 텍스트가 터지듯 등장. 금색 confetti 폭발.
2. **이전 기록 대비 표시**: "이전 최고: 28,400 (+3,950)" 형태로 얼마나 갱신했는지 표시.
3. **첫 S등급 특별 연출**: 처음으로 S등급 달성 시, 일반 등급 공개와 다른 특별 시퀀스. 화면 전체가 금색으로 변하며 "FIRST S RANK!" 표시.

축하 이펙트 계층:
- D등급: 이펙트 없음 (담백)
- C등급: 미세한 파티클
- B등급: confetti (민트색 계열)
- A등급: 풍성한 confetti + 화면 가장자리 빛남
- S등급: 대형 confetti 폭발 + 화면 흔들림 + 금색 파티클 + 배경 색상 변경

### 스코어링: "최고 기록 갱신 연출 시스템"
| 항목 | 점수 |
|------|------|
| Impact | 8 |
| Feasibility | 8 |
| Retention | 9 |
| Polish | 10 |
| Delight | 10 |
| **Total** | **8.7** |

### 다음 라운드 의문점
- 스탯 정보를 어떤 순서로, 어떻게 공개해야 가장 효과적인가?
- Progressive disclosure 원칙을 결과 화면에 어떻게 적용하는가?

---

## Round 5: 스탯 표시 순서와 Progressive Disclosure

### 리서치 요약
- **Progressive Disclosure 핵심**: "추상에서 구체로" 이동, 처음엔 가장 중요한 정보만 보이고, 나머지는 요청 시 공개 ([Progressive Disclosure - NN/G](https://www.nngroup.com/articles/progressive-disclosure/))
- **게임에서의 적용**: 게임은 Progressive Disclosure의 훌륭한 예시. 메커닉을 사용자 경험의 적절한 시점에 공개 ([Progressive Disclosure in UX](https://blog.logrocket.com/ux-design/progressive-disclosure-ux-types-use-cases/))
- **Staged Disclosure**: 선형 시퀀스로 옵션을 단계적으로 표시하는 변형. 위저드가 대표적 ([Shopify Progressive Disclosure](https://www.shopify.com/partners/blog/progressive-disclosure))
- **Conditional Disclosure**: 특정 조건이 충족될 때만 정보 공개. 사용자 행동에 따라 점진적으로 더 많은 것을 드러냄 ([IxDF Progressive Disclosure](https://ixdf.org/literature/topics/progressive-disclosure))

### 토의
현재 6개 스탯(최대콤보, 생존시간, 정확도, 처리, 정답, 오답)이 동시에 표시되는 것은 Progressive Disclosure 원칙에 위배된다. 스탯 공개를 "미니 스토리"로 만들어야 한다.

**제안 시퀀스** (각 스탯이 0.4초 간격으로 순차 등장):

```
[1단계: 상황 요약] 0.0s
  "TIME UP" 또는 "MENTAL BREAK" (큰 텍스트, 화면 중앙)
  → 1.0초 후 위로 슬라이드

[2단계: 핵심 스탯 순차 공개] 1.0s~
  ① 생존시간: "120.0s" (타이머 런 느낌으로 카운트업)
  ② 처리 댓글 수: "67개" (빠르게 카운트업)
  ③ 정확도: "%"로 카운트업 (가장 주목도 높음)

[3단계: 전투 스탯] 3.0s~
  ④ 최대 콤보: 숫자 카운트업 + 콤보 색상(5+amber, 20+orange)
  ⑤ 정답 / 오답: 바 차트 형태로 시각화

[4단계: 점수 카운트업] 4.5s~
  ⑥ 점수: 0에서 최종 점수까지 2초 동안 카운트업
     (속도: 처음 빠르게 → 최종 점수 근처에서 감속)
     이전 최고 기록 라인 표시 (점선)
     → 넘으면 "NEW BEST!" 트리거

[5단계: 등급 공개] 7.0s~
  ⑦ 등급 뱃지 드롭 (위에서 떨어지며 바운스)
  + 등급별 이펙트 (S: confetti 폭발, A: sparkle 등)
  + "다음 등급까지 X점" (near-miss 표시)

[6단계: 액션] 8.5s~
  ⑧ 공유 버튼 + 다시 플레이 + 메뉴로
```

이 시퀀스는 영화 크레딧의 감정 곡선과 유사하다. 결과를 소화하고 → 스탯을 이해하고 → 점수에 집중하고 → 등급에서 서프라이즈를 느끼고 → 행동을 선택한다.

### 스코어링: "순차적 스탯 공개 시퀀스"
| 항목 | 점수 |
|------|------|
| Impact | 9 |
| Feasibility | 7 |
| Retention | 8 |
| Polish | 10 |
| Delight | 9 |
| **Total** | **8.6** |

### 다음 라운드 의문점
- 리더보드를 어떻게 통합하면 동기 부여가 되면서 좌절감은 최소화하는가?
- 하위권 플레이어의 이탈을 막으려면?

---

## Round 6: 리더보드 진입 표시 + 경쟁 동기

### 리서치 요약
- **리더보드의 양면성**: 상위 5~10% 유저에게는 동기 부여되지만, 중하위권 유저에게는 사기 저하 효과 ([Increase Competitiveness with Leaderboards](https://www.interaction-design.org/literature/article/increase-competitiveness-in-users-with-leader-boards))
- **해결책 -- 상대적 리더보드**: "자신의 점수와 위아래 5명만 표시"하여 달성 가능한 목표에 집중, 긴급한 낙관주의(urgent optimism) 촉진 ([Designing Effective Leaderboards](https://yukaichou.com/advanced-gamification/how-to-design-effective-leaderboards-boosting-motivation-and-engagement/))
- **소규모 그룹 분할**: 10~200명 단위 그룹(100명 권장)으로 플레이어를 나누어, 모든 사람이 "Top 10"에 들어갈 현실적 가능성을 느끼게 함 ([Building better leaderboards](https://uxdesign.cc/building-better-leaderboards-a5013d19cbd7))
- **주기적 리셋**: 주간/월간 리더보드로 정기 리셋하여 참여 유지. "이번 주는 될 수 있다"는 희망 ([When To Use Leaderboards](https://medium.com/design-bootcamp/gamification-strategy-when-to-use-leaderboards-7bef0cf842e1))

### 토의
Comment Corporation에 리더보드를 넣을 때, 결과 화면에서의 통합 방법이 중요하다:

1. **결과 화면 내 "순위 변동" 표시**: 등급 공개 직후, "전체 N위 (+12 상승)" 또는 "이번 주 N위" 표시. 순위가 올랐으면 초록 화살표, 내렸으면 빨간 화살표.
2. **Top 10 진입 시 특별 연출**: "TOP 10 진입!" 배너 + 금색 파티클. 이것은 최고 기록 갱신과 별개의 보상 이벤트.
3. **"친구 리더보드" 우선**: 글로벌보다 친구/그룹 리더보드가 동기 부여에 더 효과적. 소셜 연결이 약한 초기에는 "이번 주 100인 그룹" 자동 배정.
4. **데일리 챌린지 리더보드 연동**: `final_ideas.md`의 데일리 챌린지와 결합하면, "오늘 같은 조건에서 나는 몇 위?"라는 강력한 비교가 가능.

**결과 화면에서의 리더보드 UI 배치**:
- 등급 뱃지 아래, 버튼 위에 배치
- 탭하면 전체 리더보드 화면으로 이동
- 간략하게: "주간 순위: 23위 / 100명 (상위 23%)"

### 스코어링: "결과 화면 내 리더보드 통합"
| 항목 | 점수 |
|------|------|
| Impact | 8 |
| Feasibility | 6 |
| Retention | 9 |
| Polish | 7 |
| Delight | 8 |
| **Total** | **7.9** |

### 다음 라운드 의문점
- "한 번 더" 플레이를 유도하는 가장 효과적인 심리적 트리거는 무엇인가?
- 하이퍼캐주얼 게임의 즉시 재시작 패턴을 어떻게 적용하는가?

---

## Round 7: "한 번 더" 동기 부여 + 즉시 재시작 심리학

### 리서치 요약
- **즉시 재시작의 힘**: "실패와 리플레이 사이의 빠른 전환(quick restart)이 리텐션을 높인다." 하이퍼캐주얼의 핵심 ([Hyper-Casual Retention Best Practices](https://supersonic.com/learn/blog/is-your-hyper-casual-game-fun-best-practices-for-boosting-retention))
- **리셋 모먼트**: "모든 게임 루프에는 리셋 순간이 있어야 한다 -- 짧은 축하 후 다음 레벨로 이어지는 정지." 피로 감소 + 장기 참여 유지 ([Casual Game Loops](https://gdevelop.io/blog/casual-game-loops))
- **빈번한 저위험 승리**: "하이퍼캐주얼 스튜디오는 빈번한, 저위험 승리로 도파민 방출을 유도하도록 게임플레이를 구조화" ([Hyper Casual Game Psychology](https://www.antiersolutions.com/blogs/5-secrets-to-addictive-hypercasual-game-design-rooted-in-player-psychology/))
- **명확한 목표의 리텐션 효과**: "명확한 목표가 리텐션을 유의미하게 향상시킨다. 목적 없이 레벨만 반복하는 경험을 보상적 여정으로 변환" ([Lifting Retention Case Study](https://www.theexperimentation.group/our-work/lifting-retention-in-hyper-casual-games))

### 토의
Comment Corporation의 결과 화면에서 "다시 플레이" 동기를 강화하는 복합 전략:

**1. Near-Miss 정보 제공 (수동적 동기)**
```
현재 점수: 28,760 (B등급)
━━━━━━━━━━━━━━━━━━━━━━░░░░░░ A등급까지 1,240점
```
프로그레스 바로 다음 등급까지의 거리를 시각화. "이 정도면 한 번만 더 하면 되겠는데?"

**2. 구체적 도전 제안 (능동적 동기)**
점수 분석 기반으로 개인화된 힌트 제공:
- 정확도가 낮으면: "정확도를 85%까지 올리면 A등급 가능!"
- 콤보가 낮으면: "콤보 15 이상 유지하면 점수 2배!"
- 생존시간이 짧으면: "멘탈 관리에 집중하면 더 높은 점수를!"

**3. "다시 플레이" 버튼 강화**
- 텍스트: "다시 도전" (더 능동적)
- 색상: 핑크 (primary) 유지하되, 크기를 1.2배로 키움
- 마이크로 애니메이션: 부드러운 pulse (1.5초 주기)
- "다시 도전" 옆에 셀럽 아이콘 표시 (같은 셀럽으로 즉시 재시작)

**4. 스킵 가능한 연출**
중요: 모든 연출은 탭하면 스킵 가능해야 한다. 빠르게 재시작하고 싶은 플레이어를 막으면 안 된다.

### 스코어링: "복합 재도전 동기 시스템"
| 항목 | 점수 |
|------|------|
| Impact | 10 |
| Feasibility | 8 |
| Retention | 10 |
| Polish | 8 |
| Delight | 8 |
| **Total** | **9.2** |

### 다음 라운드 의문점
- "Juice" (confetti, screen shake, particles)의 구체적 구현 전략은?
- Flutter에서 성능을 유지하면서 시각 이펙트를 어떻게 최적화하는가?

---

## Round 8: Juice -- Confetti, Particles, Screen Shake

### 리서치 요약
- **Screen Shake**: "즉각적 피드백을 주는 가장 흔히 사용되는 기법 중 하나. 0.1~0.3초, 방향 약간 랜덤, easing으로 부드럽게 감쇠" ([Game Feel Tutorial](https://gamedevacademy.org/game-feel-tutorial/))
- **Juice 정의**: "게임이 살아 있고 반응적으로 느끼게 하는 작지만 미묘한 효과들" -- confetti, 격려 사운드, 짧은 화면 정지를 결합하면 성공 순간이 훨씬 만족스러워짐 ([Making a Game Feel Juicy](https://gamedev4u.medium.com/when-you-play-a-great-game-it-feels-good-d23761b6eccf))
- **Confetti 효과**: "최종 화면에서 플레이어에게 성공적 완료를 축하하기 위해 사용" ([Confetti Particle Effect](https://defold.com/examples/particles/confetti/))
- **Flutter confetti 패키지**: `confetti` pub.dev 패키지로 Flutter에서 즉시 구현 가능. Lottie JSON 파일을 활용하면 고급 파티클 이펙트도 가능 ([Flutter Confetti with Lottie](https://medium.com/easy-flutter/flutter-confetti-with-lottie-bf47cb38d2cd))

### 토의
Comment Corporation 결과 화면의 "Juice" 계층 설계:

**등급별 축하 이펙트 매트릭스:**

| 등급 | Confetti | Screen Shake | 배경 변화 | 사운드 | 파티클 색상 |
|------|----------|-------------|-----------|--------|------------|
| S | 대형 폭발 (3초) | 강하게 (0.3s) | 금색 그라디언트 | 팡파르 | 금색 + 핑크 |
| A | 중형 (2초) | 중간 (0.2s) | 핑크 글로우 | 브라스 | 핑크 + 흰색 |
| B | 소형 (1.5초) | 약하게 (0.1s) | 민트 글로우 | 차임 | 민트 + 흰색 |
| C | 미세 (1초) | 없음 | 약간 밝아짐 | 소프트 | 오렌지 |
| D | 없음 | 없음 | 없음 | 저음 | 없음 |

**Flutter 구현 방안:**
- `confetti` 패키지: `ConfettiController` + `ConfettiWidget`으로 기본 confetti
- Lottie 파일: S등급 전용 금색 폭죽 애니메이션 (LottieFiles에서 무료 에셋)
- Screen shake: `AnimationController` + `Transform.translate`로 랜덤 오프셋
- 배경 그라디언트: `AnimatedContainer`로 색상 전환

**성능 최적화:**
- confetti 파티클 수: S등급 최대 200개, B등급 50개
- Lottie 애니메이션은 캐시하여 재사용
- 화면 밖 파티클 즉시 제거
- 저사양 기기 감지 시 이펙트 축소

### 스코어링: "등급별 Juice 이펙트 시스템"
| 항목 | 점수 |
|------|------|
| Impact | 8 |
| Feasibility | 8 |
| Retention | 7 |
| Polish | 10 |
| Delight | 10 |
| **Total** | **8.1** |

### 다음 라운드 의문점
- Flutter에서 카운트업 애니메이션의 최적 구현 방법은?
- 전체 결과 시퀀스의 기술적 구현 구조는?

---

## Round 9: Flutter 기술 구현 전략

### 리서치 요약
- **Lottie Flutter**: "After Effects 애니메이션을 순수 Dart로 네이티브 렌더링. JSON 파일로 내보내져 크기가 작고 파싱/렌더링이 빨라 로드 타임이 빠르고 애니메이션이 부드러움" ([Lottie Flutter Package](https://pub.dev/packages/lottie))
- **카운트업 구현**: "시간에 따라 증가/감소하는 애니메이션 숫자 텍스트. 스코어보드, 타이머 등에서 시각적으로 매력적인 숫자 변화 표시" ([Flutter Countup](https://www.dhiwise.com/post/mastering-flutter-countup-build-animated-counter-texts))
- **Lottie 커스터마이징**: "재생 속도, 루프 설정, 애니메이션 상태를 코드에서 조작 가능. 사용자 인터랙션이나 앱 이벤트에 따라 다른 부분 트리거" ([Lottie Animations in Flutter](https://dianapps.com/blog/lottie-animations-in-flutter-learn-easy-integration-strategies))
- **Confetti 패키지**: `ConfettiWidget`은 발사 방향, 파티클 수, 중력, 색상 등을 세밀하게 제어 가능 ([confetti | Flutter package](https://pub.dev/packages/confetti))

### 토의
전체 결과 시퀀스의 기술 아키텍처:

**ResultScreen 상태 머신:**
```dart
enum ResultPhase {
  entering,        // 0.0s - 게임 오버 전환 연출
  headline,        // 0.5s - "TIME UP" / "MENTAL BREAK"
  statsReveal,     // 1.5s - 스탯 순차 공개 (6개, 각 0.4s)
  scoreCountUp,    // 4.0s - 점수 카운트업 (2초 소요)
  gradeReveal,     // 6.5s - 등급 뱃지 드롭 + 이펙트
  nearMiss,        // 7.5s - "다음 등급까지 X점"
  newBest,         // 8.0s - (조건부) 최고 기록 갱신 표시
  endingCard,      // 8.5s - (조건부) 새 엔딩 카드 획득 표시
  leaderboard,     // 9.0s - (조건부) 순위 표시
  actions,         // 9.5s - 공유/다시 플레이/메뉴로
  idle,            // 전체 시퀀스 완료
}
```

**핵심 Flutter 패키지:**
```yaml
dependencies:
  confetti: ^0.7.0          # confetti 이펙트
  lottie: ^3.1.0            # Lottie 애니메이션
  share_plus: ^7.0.0        # 공유 기능
  # 이미 설치된 audioplayers로 사운드 이펙트
```

**카운트업 구현 (커스텀):**
```dart
// AnimationController + Tween으로 카운트업
// CurvedAnimation에 Curves.easeOutExpo 적용
// → 처음 빠르게, 끝에서 감속 (슬롯머신 느낌)
late final _scoreAnimation = Tween<double>(
  begin: 0, end: finalScore.toDouble()
).animate(CurvedAnimation(
  parent: _scoreController,
  curve: Curves.easeOutExpo,
));
```

**스킵 메커닉:**
```dart
// 화면 아무 곳이나 탭하면 현재 phase 스킵
// → 모든 값 즉시 표시 + actions phase로 점프
void _skipToEnd() {
  _currentPhase = ResultPhase.actions;
  // 모든 애니메이션 controller를 .value = 1.0으로 설정
  setState(() {});
}
```

### 스코어링: "결과 시퀀스 기술 구현 프레임워크"
| 항목 | 점수 |
|------|------|
| Impact | 7 |
| Feasibility | 9 |
| Retention | 7 |
| Polish | 9 |
| Delight | 7 |
| **Total** | **7.6** |

### 다음 라운드 의문점
- 보상 심리의 전체적 프레임워크에서 결과 화면이 어떤 역할을 하는가?
- 장기 리텐션을 위한 결과 화면의 "메타 보상"은 무엇인가?

---

## Round 10: 보상 심리 통합 프레임워크 + 최종 정리

### 리서치 요약
- **보상 스케줄의 핵심**: "Variable ratio schedule에서는 보상이 예측 불가능한 횟수의 행동 후에 제공. 캐주얼한 호기심을 지속적이고 고빈도의 행동으로 전환하는 데 가장 효과적" ([Variable Ratio Schedule](https://www.psu.com/news/the-slot-machine-psyche-how-variable-ratio-reinforcement-drives-modern-gaming-engagement/))
- **기대감이 보상 자체보다 중요**: "도파민 방출은 보상 자체뿐 아니라 보상에 대한 기대와도 연관. 이 기대가 심리적 반응을 만들어 플레이어가 다음 보상을 받기 위해 계속 플레이하도록 동기 부여" ([Psychology of Reward Cycles](https://good2gorecruiter.com/the-psychology-of-reward-cycles-in-modern-games/))
- **슬로우모션 리빌**: "시각-청각 디자인에서 플래싱 라이트, 슬로우모션 리빌, 흥분되는 사운드 이펙트가 일반적인 결과에서도 높은 가치의 승리 드라마를 연출" ([Gaming Psychology Triggers 2025](https://shadowlandswow.com/player-motivation/))
- **투명성 권고**: "캠브리지 대학과 APA의 최근 연구는 게임 디자인의 투명성을 권고 -- 확률 공개와 보상 상한 구현" ([Game Design and Player Retention](https://www.badgeunlock.com/2025/12/03/how-game-design-impacts-player-engagement-and-drives-long-term-retention/))

### 토의
결과 화면은 게임의 "보상 심리 앵커 포인트"다. 120초의 게임플레이에서 얻은 모든 경험을 응축하여 플레이어의 감정 상태를 조절하는 최후의 터치포인트.

**보상 심리 프레임워크: Comment Corporation 결과 화면의 5가지 레이어**

```
Layer 1: 즉각적 보상 (Immediate Reward)
├── 점수 카운트업의 시각적/청각적 만족
├── 등급 뱃지의 서프라이즈 공개
└── Confetti/파티클의 감각적 축하

Layer 2: 성취 인식 (Achievement Recognition)
├── 최고 기록 갱신 표시
├── 엔딩 카드 획득 (final_ideas.md 1위)
└── 리더보드 순위 상승

Layer 3: 사회적 보상 (Social Reward)
├── 공유 카드 생성 (Wordle 스타일)
├── 리더보드에서의 위치
└── 데일리 챌린지 공통 경험

Layer 4: 진행 보상 (Progress Reward)
├── 다음 등급까지의 거리 (near-miss)
├── 스트릭 유지 (데일리)
└── 도감 진행률

Layer 5: 기대감 보상 (Anticipation Reward)
├── "다음엔 S등급 가능할까?"
├── "아직 못 찾은 엔딩 카드가 있다"
└── "이번 주 보스는 누구지?"
```

이 5개 레이어가 매 라운드 결과 화면에서 겹겹이 작동하면, 플레이어는 다음과 같은 감정 곡선을 경험한다:

```
감정
  ^
  |      ★등급공개     ★최고기록
  |     /  \         / \
  |    /    \  ★카운트업  \    ★공유
  |   /      \/     \  \/    \
  |  / 스탯공개       \/      \____→ "다시 도전"
  | /                nearMiss
  +──────────────────────────────→ 시간
  0s     3s     5s     7s    9s
```

감정이 한 번 내려갔다 올라갔다를 반복하며, 마지막에 "다시 도전"의 의지로 자연스럽게 이어진다.

### 스코어링: "5레이어 보상 심리 프레임워크"
| 항목 | 점수 |
|------|------|
| Impact | 10 |
| Feasibility | 6 |
| Retention | 10 |
| Polish | 9 |
| Delight | 9 |
| **Total** | **8.9** |

---

## 전체 라운드 스코어 요약

| 순위 | 라운드 | 개선안 | Total |
|------|--------|--------|-------|
| 1 | R7 | 복합 재도전 동기 시스템 (near-miss + 구체적 도전 + 버튼 강화) | **9.2** |
| 2 | R2 | 등급 공개 시퀀스 + Near-Miss 표시 | **9.1** |
| 3 | R10 | 5레이어 보상 심리 프레임워크 | **8.9** |
| 4 | R3 | 공유 카드 시스템 (결과 화면 통합) | **8.7** |
| 5 | R4 | 최고 기록 갱신 연출 시스템 | **8.7** |
| 6 | R5 | 순차적 스탯 공개 시퀀스 | **8.6** |
| 7 | R1 | 결과 화면 진입 전환 연출 | **8.4** |
| 8 | R8 | 등급별 Juice 이펙트 시스템 | **8.1** |
| 9 | R6 | 결과 화면 내 리더보드 통합 | **7.9** |
| 10 | R9 | 결과 시퀀스 기술 구현 프레임워크 | **7.6** |

---

## 최종 상위 10개 개선안 (구현 우선순위 순)

---

### 개선안 #1: 점수 카운트업 애니메이션 (MVP)
- **현재**: 최종 점수가 즉시 표시됨
- **개선**: 0에서 최종 점수까지 2초 동안 카운트업. `Curves.easeOutExpo`로 처음 빠르게, 끝에서 감속. 카운트업 중 짧은 틱 사운드. 이전 최고 기록 점선 라인 표시.
- **구현**: `AnimationController` + `Tween<double>` + `AnimatedBuilder`
- **왜 중요한가**: 점수 카운트업은 결과 화면 보상감의 기초. 이것 없이는 모든 후속 연출이 무의미.
- **예상 공수**: 0.5일

---

### 개선안 #2: 등급 공개 연출 시퀀스 (MVP)
- **현재**: 등급 뱃지가 즉시 표시됨
- **개선**: 카운트업 완료 후, 등급 뱃지가 위에서 떨어지며 바운스. 떨어지는 동안 0.5초 정지(기대감). 착지 시 등급별 이펙트 발동. S등급: 금색 confetti + screen shake. A등급: 핑크 sparkle. B등급: 민트 파티클.
- **구현**: `SlideTransition` + `ConfettiWidget` + `AnimationController`
- **왜 중요한가**: 등급 공개는 결과 화면의 클라이맥스. 이 순간의 서프라이즈가 전체 경험을 정의한다.
- **예상 공수**: 1일

---

### 개선안 #3: Near-Miss 표시 + 재도전 메시지 (MVP)
- **현재**: 다음 등급까지의 거리 정보 없음
- **개선**: 등급 뱃지 아래에 프로그레스 바 표시. "A등급까지 1,240점 (96% 달성)". 점수 분석 기반 개인화 힌트: "정확도 5% 올리면 A등급!". 이미 S등급이면: "S+ 목표: 70,000점까지 도전!"
- **구현**: 등급 경계 계산 로직 + `LinearProgressIndicator` + 조건부 텍스트
- **왜 중요한가**: Near-miss는 리텐션에 가장 직접적으로 기여하는 심리적 메커니즘. "거의 다 왔다"는 느낌이 즉시 재도전 결정을 유도.
- **예상 공수**: 0.5일

---

### 개선안 #4: 순차적 스탯 공개 (v1.0)
- **현재**: 6개 스탯이 동시 표시
- **개선**: 스탯이 0.4초 간격으로 하나씩 슬라이드인. 순서: 생존시간 -> 처리수 -> 정확도 -> 최대콤보 -> 정답/오답. 각 숫자는 짧은 카운트업으로 표시. 정확도는 특히 강조(크기 1.2배, 색상).
- **구현**: `AnimationController` + `StaggeredAnimation` 패턴 + `Interval`
- **왜 중요한가**: 정보를 순차적으로 소화시키면 각 스탯에 대한 주목도가 올라가고, 전체 결과를 "이야기"로 경험하게 된다.
- **예상 공수**: 1일

---

### 개선안 #5: 게임 오버 전환 연출 (v1.0)
- **현재**: GameScreen -> ResultScreen 즉시 전환
- **개선**:
  - **TIME UP**: 타이머가 0에 도달하면 화면이 1초간 슬로우모션 -> 마지막 댓글 카드가 서서히 사라짐 -> 화면이 어두워지며 "TIME UP" 텍스트 등장 -> ResultScreen으로 전환
  - **MENTAL BREAK**: 멘탈이 0에 도달하면 화면에 균열 이펙트 -> 화면이 깨지는 듯한 연출 -> "MENTAL BREAK" (빨간색) -> ResultScreen
- **구현**: 게임 종료 시 `_gameOverPhase` 상태 추가 + overlay 애니메이션 1~1.5초 -> Navigator.pushReplacement
- **왜 중요한가**: 감정 곡선의 "전이 구간". 고강도 게임플레이에서 결과 화면으로의 급격한 전환을 부드럽게 만든다.
- **예상 공수**: 1일

---

### 개선안 #6: 최고 기록 갱신 연출 (v1.0)
- **현재**: 최고 기록 갱신 여부 표시 없음
- **개선**: 카운트업 중 점수가 이전 최고 기록을 넘는 순간, 카운트가 0.3초 정지 -> "NEW BEST!" 텍스트 팝업 (금색, scale bounce) -> 금색 confetti 소량 폭발 -> 카운트 재개. 결과 카드에 "이전 최고: XX,XXX (+Y,YYY)" 표시.
- **구현**: SharedPreferences에서 셀럽별 최고 기록 로드 -> 카운트업 중간에 조건 체크 -> 추가 애니메이션 트리거
- **왜 중요한가**: 개인 최고 기록 갱신은 가장 보편적인 보상 경험. 이를 명시적으로 축하하면 자기 효능감이 강화된다.
- **예상 공수**: 0.5일

---

### 개선안 #7: Wordle 스타일 공유 카드 (v1.0)
- **현재**: 공유 기능 없음
- **개선**: 결과 시퀀스 완료 후 "결과 공유" 버튼 등장. 탭하면:
  ```
  댓글주식회사 | 아이돌
  A등급 | 31,250점
  🟩🟩🟩🔥🟩🟨🟥🟩🟩🔥🟩🟩
  콤보 38 | 정확도 89% | 멘탈 65%
  ★ 첫 A등급 달성!
  ```
  클립보드 복사 + 시스템 공유 시트. 이미지 카드 옵션: `RepaintBoundary` -> 이미지 저장.
- **구현**: 10초 구간별 퍼포먼스 추적 (GameNotifier) + `share_plus` 패키지 + 이모지 변환 로직
- **왜 중요한가**: 바이럴 성장의 핵심 엔진. 유저가 자발적으로 게임을 홍보하게 만드는 가장 저비용 마케팅.
- **예상 공수**: 1.5일

---

### 개선안 #8: 등급별 Confetti/파티클 이펙트 (v1.0)
- **현재**: 결과 화면에 시각 이펙트 없음
- **개선**: 등급에 따라 차등 이펙트:
  - S: 대형 confetti 폭발(200파티클, 3초) + screen shake(0.3s) + 배경 금색 그라디언트
  - A: 중형 confetti(100파티클, 2초) + 핑크 글로우
  - B: 소형 confetti(50파티클, 1.5초) + 민트 글로우
  - C: 미세 파티클(20개, 1초)
  - D: 이펙트 없음
- **구현**: `confetti` 패키지 + `ConfettiController` 등급별 프리셋 + Lottie for S등급 특별 애니메이션
- **왜 중요한가**: "Juice"는 동일한 콘텐츠를 10배 더 만족스럽게 만든다. 비용 대비 체감 효과가 가장 큰 개선.
- **예상 공수**: 1일

---

### 개선안 #9: 결과 화면 내 리더보드 미니뷰 (v1.1)
- **현재**: 리더보드 없음
- **개선**: 등급 아래에 한 줄 표시: "주간 순위: 23위 / 100명 (상위 23%)". 순위 상승 시 초록 화살표 + 숫자. Top 10 진입 시 "TOP 10!" 특별 배지 + 금색 파티클. 탭하면 전체 리더보드 화면으로.
- **구현**: Firebase Firestore + 주간 그룹 자동 배정(100명 단위) + 결과 화면에 `StreamBuilder`
- **왜 중요한가**: 사회적 비교는 "나 혼자"와 "우리 모두" 사이의 긴장을 만들어 경쟁 동기를 부여한다.
- **예상 공수**: 3일 (서버 인프라 포함)

---

### 개선안 #10: 스킵 가능한 전체 시퀀스 + 결과 화면 상태 머신 (MVP)
- **현재**: 결과 화면에 상태 개념 없음 (모든 것이 즉시)
- **개선**: `ResultPhase` enum으로 상태 머신 구현. 각 phase가 자동으로 다음 phase로 전환. 화면 어디든 탭하면 즉시 최종 상태로 스킵 (모든 값 표시 + actions). 빠른 재시작을 원하는 플레이어를 방해하지 않음.
- **구현**:
  ```dart
  enum ResultPhase {
    entering, headline, statsReveal, scoreCountUp,
    gradeReveal, nearMiss, newBest, endingCard,
    leaderboard, actions, idle
  }
  ```
  `Timer` 또는 `AnimationController`로 phase 자동 전환 + `GestureDetector`로 스킵
- **왜 중요한가**: 이것이 다른 모든 개선안의 "뼈대". 이 상태 머신 없이는 순차적 연출 자체가 불가능.
- **예상 공수**: 0.5일

---

## 구현 로드맵

### Phase 1: MVP (1주차)
| 순서 | 개선안 | 공수 |
|------|--------|------|
| 1 | #10 결과 화면 상태 머신 | 0.5일 |
| 2 | #1 점수 카운트업 | 0.5일 |
| 3 | #3 Near-Miss 표시 | 0.5일 |
| 4 | #6 최고 기록 갱신 | 0.5일 |
| | **소계** | **2일** |

### Phase 2: v1.0 (2주차)
| 순서 | 개선안 | 공수 |
|------|--------|------|
| 5 | #2 등급 공개 연출 | 1일 |
| 6 | #5 게임 오버 전환 | 1일 |
| 7 | #4 순차 스탯 공개 | 1일 |
| 8 | #8 등급별 Confetti | 1일 |
| 9 | #7 공유 카드 | 1.5일 |
| | **소계** | **5.5일** |

### Phase 3: v1.1 (3주차~)
| 순서 | 개선안 | 공수 |
|------|--------|------|
| 10 | #9 리더보드 미니뷰 | 3일 |
| | **소계** | **3일** |

**총 예상 공수: 약 10.5일 (2~3주)**

---

## 부록: 결과 화면 전체 시퀀스 타임라인

```
시간   이벤트                              감정곡선
─────────────────────────────────────────────────
0.0s   [게임 오버 전환 시작]                 ████████░░ 긴장
0.5s   "TIME UP" / "MENTAL BREAK"          ███████░░░ 해소
1.0s   위로 슬라이드, 스탯 영역 준비          ██████░░░░ 안정
1.5s   ① 생존시간 슬라이드인                 ██████░░░░
1.9s   ② 처리 댓글 수 슬라이드인             ██████░░░░
2.3s   ③ 정확도 슬라이드인 (강조)            ███████░░░ 관심
2.7s   ④ 최대 콤보 슬라이드인               ███████░░░
3.1s   ⑤ 정답/오답 바차트                   ██████░░░░
4.0s   [점수 카운트업 시작]                  ███████░░░ 기대
5.0s   (카운트업 중 -- 이전 최고 기록 통과?)  ████████░░ 긴장
5.3s   ★ "NEW BEST!" (조건부)              █████████░ 흥분!
6.0s   [카운트업 완료 -- 최종 점수]           ████████░░
6.5s   [등급 뱃지 드롭 시작]                 █████████░ 기대!
7.0s   ★ 등급 착지 + Confetti!             ██████████ 정점!
7.5s   "A등급까지 1,240점"                  ███████░░░ 아쉬움+동기
8.0s   ★ 새 엔딩 카드 "NEW!" (조건부)       █████████░ 서프라이즈
8.5s   순위: "주간 23위 (+12)" (조건부)      ████████░░
9.0s   [공유] [다시 도전] [메뉴로] 등장       ███████░░░ 행동 준비
       탭하면 어디서든 → 즉시 최종 상태로 스킵
```

---

## 참고 자료 (Sources)

### Round 1
- [UI/UX for Game Design - Trinergy Digital](https://www.trinergydigital.com/news/ui-ux-for-game-design-key-elements-for-gamified-interfaces)
- [Game Design UX Best Practices - UX Planet](https://uxplanet.org/game-design-ux-best-practices-guide-4a3078c32099)
- [UX Design Trends for Mobile Games 2025 - Red Apple Technologies](https://redappletechnologies.medium.com/user-experience-ux-design-trends-for-mobile-games-in-2025-ff8293c63d87)
- [The Complete Game UX Guide 2025 - Game-Ace](https://game-ace.com/blog/the-complete-game-ux-guide/)
- [The Dopamine Loop - Bootcamp/Medium](https://medium.com/design-bootcamp/the-dopamine-loop-how-ux-designs-hook-our-brains-bd1a50a9f22e)
- [Gaming Achievement Dopamine Hits - COGconnected](https://cogconnected.com/2025/10/gaming-achievement-dopamine-hits-and-their-real-effects/)

### Round 2
- [Gameplay Grading - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/GameplayGrading)
- [The Near Miss Effect - Psychology of Games](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/)
- [Near-Miss Effect and Almost-Winning Mechanics - Medium](https://medium.com/@milijanakomad/the-near-miss-effect-and-almost-winning-mechanics-378de92f88a8)
- [Near-miss effect - Wikipedia](https://en.wikipedia.org/wiki/Near-miss_effect)
- [Game Design Psychology and Player Retention - iGaming Studies](https://igamingstudies.com/2025/12/17/how-game-design-psychology-influences-player-retention-in-igaming/)

### Round 3
- [Why Wordle Went Viral - Smithsonian Magazine](https://www.smithsonianmag.com/smart-news/heres-why-the-word-game-wordle-went-viral-180979439/)
- [Wordle Viral Marketing - beastoftraal.com](https://beastoftraal.com/2022/01/04/wordles-viral-marketing-tactic-makes-brilliant-use-of-people-as-media/)
- [Wordle Minimalist Design Analysis - Blockchain News](https://blockchain.news/ainews/why-wordle-s-minimalist-ai-design-drives-viral-engagement-analysis-business-insights)
- [Wordle and Social Media Marketing - Crescitaly](https://blog.crescitaly.com/wordles-creator-new-puzzle-game-social-media-marketing-strategy/)

### Round 4
- [Game UX: Reaching the High Score - Pageflows](https://pageflows.com/resources/game-ux-reaching-the-high-score/)
- [Hypercasual Games UI/UX Design Guide - Pixune](https://pixune.com/blog/hypercasual-games-ui-ux-design-guide/)
- [Game UI Design Principles - JustInMind](https://www.justinmind.com/ui-design/game)

### Round 5
- [Progressive Disclosure - Nielsen Norman Group](https://www.nngroup.com/articles/progressive-disclosure/)
- [Progressive Disclosure in UX - LogRocket](https://blog.logrocket.com/ux-design/progressive-disclosure-ux-types-use-cases/)
- [Progressive Disclosure - Shopify](https://www.shopify.com/partners/blog/progressive-disclosure)
- [Progressive Disclosure - IxDF](https://ixdf.org/literature/topics/progressive-disclosure)

### Round 6
- [Increase Competitiveness with Leaderboards - IxDF](https://www.interaction-design.org/literature/article/increase-competitiveness-in-users-with-leader-boards)
- [Designing Effective Leaderboards - Yukai Chou](https://yukaichou.com/advanced-gamification/how-to-design-effective-leaderboards-boosting-motivation-and-engagement/)
- [Building Better Leaderboards - UX Collective](https://uxdesign.cc/building-better-leaderboards-a5013d19cbd7)
- [When To Use Leaderboards - Bootcamp/Medium](https://medium.com/design-bootcamp/gamification-strategy-when-to-use-leaderboards-7bef0cf842e1)

### Round 7
- [Hyper-Casual Retention Best Practices - Supersonic](https://supersonic.com/learn/blog/is-your-hyper-casual-game-fun-best-practices-for-boosting-retention)
- [Casual Game Loops - GDevelop](https://gdevelop.io/blog/casual-game-loops)
- [Hyper Casual Game Psychology - Antier Solutions](https://www.antiersolutions.com/blogs/5-secrets-to-addictive-hypercasual-game-design-rooted-in-player-psychology/)
- [Lifting Retention in Hyper-Casual Games - The Experimentation Group](https://www.theexperimentation.group/our-work/lifting-retention-in-hyper-casual-games)

### Round 8
- [Game Feel Tutorial - GameDev Academy](https://gamedevacademy.org/game-feel-tutorial/)
- [Making a Game Feel Juicy - Medium](https://gamedev4u.medium.com/when-you-play-a-great-game-it-feels-good-d23761b6eccf)
- [Confetti Particle Effect - Defold](https://defold.com/examples/particles/confetti/)
- [Flutter Confetti with Lottie - Medium](https://medium.com/easy-flutter/flutter-confetti-with-lottie-bf47cb38d2cd)
- [confetti | Flutter package](https://pub.dev/packages/confetti)

### Round 9
- [Lottie Flutter Package - pub.dev](https://pub.dev/packages/lottie)
- [Flutter Countup - DHiWise](https://www.dhiwise.com/post/mastering-flutter-countup-build-animated-counter-texts)
- [Lottie Animations in Flutter - Dianapps](https://dianapps.com/blog/lottie-animations-in-flutter-learn-easy-integration-strategies)

### Round 10
- [Variable Ratio Reinforcement in Gaming - PSU](https://www.psu.com/news/the-slot-machine-psyche-how-variable-ratio-reinforcement-drives-modern-gaming-engagement/)
- [Psychology of Reward Cycles - good2gorecruiter](https://good2gorecruiter.com/the-psychology-of-reward-cycles-in-modern-games/)
- [Gaming Psychology Triggers 2025 - ShadowlandsWoW](https://shadowlandswow.com/player-motivation/)
- [Game Design and Player Retention - Badge Unlock](https://www.badgeunlock.com/2025/12/03/how-game-design-impacts-player-engagement-and-drives-long-term-retention/)
- [Daily Rewards, Streaks, and Battle Passes - DesignTheGame](https://www.designthegame.com/learning/tutorial/daily-rewards-streaks-battle-passes-player-retention)
