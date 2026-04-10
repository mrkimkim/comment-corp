# Comment Corporation -- Sound/Audio Design Feedback Report

> 10 Round Research & Discussion | Game Sound Design Expert
> Date: 2026-04-09

---

## Game Context Summary

Comment Corporation is a **swipe-based casual mobile game** (Flutter, 120 seconds per round) where the player acts as a "comment moderator" for celebrities, swiping left to block toxic comments and right to approve positive ones. Key mechanics include:

- **5 Phase system** (P1~P5): difficulty escalates over 120 seconds (interval 2.0s -> 0.5s, toxic ratio 30% -> 60%)
- **Combo system**: streak-based multiplier, 20 combo triggers **Fever Mode** (8 seconds)
- **Mental (HP) system**: starts at 100, damaged by approving toxic comments, heals on correct positive swipes
- **4 Items**: Detector (reveal), Freeze (pause timer), Boost (3x score), Skip (pass)
- **5 Celebrity types**: idol(easy), actor/youtuber/sports(normal), politician(hard)
- **Current audio state**: audioplayers ^6.6.0 installed, asset folders declared (`assets/audio/bgm/`, `assets/audio/sfx/`), but **zero audio files or code exist**

---

## Round 1: Mobile Game Sound Design Fundamentals

### Research
- **Source**: Somatone, GameDeveloper, GameAnalytics best practice guides
- Casual mobile game audio must be simultaneously **melodic and engaging** without being **distracting or fatiguing** on loop
- All SFX should be normalized to **-3dB** for volume consistency
- UX sounds help players understand gameplay experience -- indicating performance and reflecting player state
- If two sounds overlap in frequency, they become muddy; **EQ carving** is essential
- Most mobile players play with **sound off** (up to 80% in some studies), so audio must be a bonus layer, not a requirement

### Discussion
Comment Corporation is a fast-paced judgment game where the player makes binary decisions every 0.5~2.0 seconds. This means:
1. **SFX must be ultra-short** (under 300ms for swipes) to not pile up
2. **BGM must loop seamlessly** without fatigue over 2-minute sessions
3. **Visual feedback already exists** (color flash overlays) -- audio reinforces, not replaces
4. The game's identity (social media / comment culture) suggests a **modern, digital, slightly playful** sonic palette

### Score: Importance of Audio in This Game
| Aspect | Score (1-10) | Rationale |
|---|---|---|
| BGM | 8 | Sets mood, drives pacing, phase transition |
| Swipe SFX | 9 | Core mechanic -- every 0.5-2s, must feel satisfying |
| Combo SFX | 8 | Reward escalation is key dopamine driver |
| Fever SFX | 7 | Short duration (8s) but high emotional peak |
| Mental crisis SFX | 7 | Urgency signal, but must not annoy |
| Game over SFX | 6 | One-shot emotional punctuation |
| Item SFX | 7 | Confirms action, differentiates items |
| UI SFX | 5 | Menu/transitions -- lower priority but adds polish |

### Open Questions for Next Round
- What swipe sound character fits a "social media comment" theme?
- How to differentiate correct vs. incorrect swipes sonically?

---

## Round 2: Combo Streak Sound & Fever Mode Audio

### Research
- **Pitch escalation**: Successively increasing pitch on chained actions reinforces chain length and satisfaction (GameDeveloper: "The Power of Pitch Shifting")
- **Candy Crush model**: vibrant stingers and musical cues for effective plays encourage longer combos
- **Randomization**: Slight random pitch/volume variation on each hit prevents repetitive fatigue
- **Adaptive music / Vertical remixing**: Add/subtract instrument layers seamlessly based on game state
- **Horizontal re-sequencing**: Loopable sections that can transition to any other section
- **Transition matrix**: custom transitions between music cues for dramatic yet natural motion

### Discussion
For Comment Corporation's combo system:

**Combo Sound Escalation Design:**
- Base swipe sound: constant
- Combo 1-4: same pitch, slight variation
- Combo 5-9 (1.5x): pitch up +2 semitones, add a "sparkle" layer
- Combo 10-19 (2x): pitch up +4 semitones, add "bell" overtone
- Combo 20+ (Fever): **separate jingle triggers**, BGM transforms

**Fever Mode Audio Strategy:**
- BGM shifts via **vertical remixing**: add a synth bass layer + percussion layer + high-energy melody layer
- A distinct "Fever activation" stinger (1.5 seconds, ascending arpeggio)
- During Fever: pitch of all swipe SFX raised, reverb/echo added for "euphoric" feel
- Fever ending: descending chime, layers strip back to normal BGM

### Score Update
| Aspect | Score (1-10) | Change |
|---|---|---|
| Combo SFX | 9 (+1) | Pitch escalation is critical for "one more try" psychology |
| Fever SFX | 8 (+1) | BGM layer shift creates memorable peak moments |

### Open Questions
- Should Fever BGM be a completely separate track or layered on top?
- How fast should pitch escalation be to avoid sounding absurd at combo 30+?

---

## Round 3: Tension/Stress Audio & Game Over Sound

### Research
- **Low health heartbeat**: Classic pattern (Zelda, Psychonauts, Axiom Verge) -- pulsing sound synced to urgency
- **Critical Annoyance problem**: Warning sounds that are too persistent drive players to frustration, not careful play
- **Modern solution**: Play warning a few times, then quiet down; or use subtle environmental changes instead of blaring alarms
- **Axiom Verge approach**: Heart monitor beep **synchronized to the music** -- tension without annoyance
- **Game Over jingles**: Powerful psychological markers; players recognize them instantly (Metal Gear "Fission Mailed" proves this)
- **Positive reinforcement**: Pleasing sounds on success increase action repetition; satisfying audio acts as dopamine trigger

### Discussion
For Comment Corporation's mental system:

**Mental Crisis Audio (Mental <= 30%):**
- **NOT a constant beep** -- that would be unbearable in a 120-second game
- Instead: **subtle heartbeat-like bass pulse** layered under BGM (60 BPM pulse)
- As mental drops further (below 15%): heartbeat accelerates to 90 BPM, slight filter on BGM (muffled/lo-fi feel)
- **Visual sync**: Already has red border flashing (600ms) -- audio pulse should sync to this exact timing
- Play heartbeat for 3-4 pulses when mental first drops below 30%, then reduce to ambient level

**Game Over Sound:**
- **Mental Break (HP=0)**: "Shatter" sound -- glass breaking + descending dissonant chord + brief silence before result screen
- **Time Up (120s)**: Alarm clock / buzzer sound -- less negative, more "time's up!" feel + ascending resolution chord
- Both should be **1.5-2 seconds**, clearly distinct from each other
- The emotional difference matters: Mental Break = failure/loss, Time Up = completion/survival

### Score Update
| Aspect | Score (1-10) | Change |
|---|---|---|
| Mental crisis SFX | 8 (+1) | Sync with visual + subtle heartbeat avoids annoyance |
| Game over SFX | 7 (+1) | Two distinct endings need two distinct sounds |

### Open Questions
- Should BGM fully stop before game over stinger, or cross-fade?
- Can heartbeat audio double as haptic feedback pattern?

---

## Round 4: BPM, Phase-Based Music & Item Sounds

### Research
- **Tempo and tension**: Increasing BPM creates suspense; players perceive difficulty through tempo changes
- **Practical approach**: Combat music at 170 BPM "mathematically doubled" from 85 BPM exploration, maintaining pulse structure
- **Phase design**: Rest periods 90-110 BPM, intense segments 140-160 BPM
- **Transition timing**: If transitions happen every 4th beat at 120 BPM, maximum delay between transitions = 2 seconds
- **Power-up sounds**: Must be immediately recognizable and differentiated per item type; "bright, crisp, energetic"

### Discussion

**BGM Phase Design (120 seconds, 5 phases):**

| Phase | Time | BPM | Musical Character | Layers |
|---|---|---|---|---|
| P1 | 0-30s | 100 | Chill lo-fi, simple melody + soft beat | Piano/keys + light drums |
| P2 | 30-60s | 112 | Energy rising, bass enters | + Bass synth + hi-hats |
| P3 | 60-90s | 124 | Full groove, urgency building | + Synth melody + full percussion |
| P4 | 90-110s | 136 | High intensity, driving | + Distorted bass + rapid arpeggios |
| P5 | 110-120s | 148 | Maximum chaos, "final countdown" | + Alarm tones + all layers at peak |

**Key decisions:**
- Single track with **5 seamless segments** (horizontal re-sequencing), not 5 separate tracks
- Each segment loops internally in case phase transition is delayed by events
- Transition points on beat boundaries (every 4 beats) for clean cross-fades
- Total BGM file: one continuous 2:30 track covering all phases with loop points

**Item Sound Design:**

| Item | Sound Character | Duration | Notes |
|---|---|---|---|
| Detector | "Scan" -- electronic sweep, rising pitch | ~400ms | Futuristic scanner feel |
| Freeze | "Crystal" -- ice cracking + time-stop whoosh | ~500ms | Reverb tail, sense of "world stopping" |
| Boost | "Power-up" -- ascending electric zap + sparkle | ~400ms | Energetic, exciting |
| Skip | "Whoosh" -- quick wind sweep | ~250ms | Fast, casual, like flicking away |

### Score Update
| Aspect | Score (1-10) | Change |
|---|---|---|
| BGM | 9 (+1) | Phase-driven BPM system is the backbone of game feel |
| Item SFX | 8 (+1) | Each item needs a unique sonic identity |

### Open Questions
- Should BGM change per celebrity type, or just per phase?
- How to handle BPM transition when Freeze item pauses the timer?

---

## Round 5: UI Sound Design & Haptic-Audio Connection

### Research
- **Multisensory design**: Thoughtful convergence of what user sees, hears, and feels; even micro interactions become satisfying
- **UI sound duration**: 80ms-300ms optimal; taps/clicks instant, transitions slightly longer
- **Apple WWDC "Audio-Haptic Design"**: Harmony = things should feel the way they look and sound
- **Android Haptics principles**: Clear haptics = crisp sensations for discrete events (button press)
- **Positive reinforcement**: Pleasing sounds on completion increase repeated behavior; 22% higher day-one retention in games with clear aural feedback

### Discussion

**UI Sound Map:**

| UI Action | Sound | Duration | Haptic |
|---|---|---|---|
| Menu button tap | Soft "pop" click | ~80ms | Light tap (UIImpactFeedbackGenerator.light) |
| Celebrity select | "Card flip" + subtle chime | ~200ms | Medium tap |
| Game start | Ascending "ready-set-go" arpeggio | ~800ms | Sequence: tap-tap-THUMP |
| Pause toggle | Muted "click" + world volume drops | ~150ms | Light tap |
| Resume | Reverse of pause sound | ~150ms | Light tap |
| Screen transition | Soft "swoosh" | ~300ms | None (too frequent) |
| Result screen reveal | Drum roll + grade reveal stinger | ~1500ms | Grade-dependent impact |

**Swipe-Haptic-Audio Sync:**
- Swipe threshold (80px) = no sound yet, only card movement
- Swipe commit (past threshold): immediate "whoosh" + haptic medium impact
- **Correct swipe**: +200ms later, ascending "ding" (C major chord tone) + haptic success
- **Incorrect swipe**: +200ms later, descending "buzz" (dissonant tone) + haptic error (double-tap pattern)
- The 200ms delay creates a "judgment moment" -- satisfying reveal of right/wrong

### Score Update
| Aspect | Score (1-10) | Change |
|---|---|---|
| UI SFX | 7 (+2) | Haptic sync elevates UI dramatically |
| Swipe SFX | 10 (+1) | Swipe-commit-judgment three-beat pattern is the game's signature |

### Open Questions
- Should haptic intensity scale with combo count?
- How to handle rapid swipes in P5 (0.5s interval) without sound pile-up?

---

## Round 6: Cultural/Thematic Audio Aesthetics & Technical Implementation

### Research
- **K-pop game audio**: Rhythm games (SuperStar series), management sims, collaborate with idol culture
- **Cookie Run x BTS**: Full rhythm integration with K-pop music; themed sound and visual identity
- **audioplayers Flutter**: Separate AudioPlayer instances for BGM and SFX; `.lowLatency` for short SFX
- **AudioPool**: Use for rapid/repetitive/simultaneous SFX -- critical for combo sounds
- **Pre-loading**: First play has delay; must cache all SFX at game init
- **Looping gap issue**: MP3 has gaps; OGG recommended for loop-based BGM

### Discussion

**Celebrity-Themed Audio:**
Rather than 5 completely different BGMs (too much asset weight), use a **color/mood filter system**:

| Celebrity | Audio Modifier | Musical Flavor |
|---|---|---|
| Idol | Brighter EQ, +pop synth layer | Bubbly, K-pop inspired shimmer |
| Actor | Cinematic reverb, +string pad | Dramatic, film-score undertone |
| Youtuber | Lo-fi filter, +vinyl crackle layer | Internet culture, meme-like |
| Sports | Stronger drums, +crowd ambience | Stadium energy |
| Politician | Darker EQ, +news broadcast texture | Serious, tense |

**Implementation:** One base BGM track + 5 audio filter presets OR 5 thin overlay tracks that mix with the base.

**Technical Architecture (audioplayers + Riverpod):**

```
AudioService (Riverpod Provider)
  |-- bgmPlayer (AudioPlayer, mediaPlayer mode, loop)
  |-- sfxPool (AudioPool, lowLatency, for swipe/combo sounds)
  |-- uiPlayer (AudioPlayer, lowLatency, for button clicks)
  |-- ambientPlayer (AudioPlayer, loop, for crisis heartbeat / fever layer)
  |
  |-- preloadAll() -> init on app start
  |-- playBGM(phase, celebrity) -> cross-fade between phases
  |-- playSFX(type, comboCount) -> pitch-shifted based on combo
  |-- setMentalCrisis(bool) -> toggle heartbeat ambient
  |-- setFever(bool) -> add/remove fever layer
  |-- dispose() -> clean up all players
```

### Score Update
| Aspect | Score (1-10) | Rationale |
|---|---|---|
| Celebrity audio differentiation | 7 (new) | Overlay approach is efficient and thematic |
| Technical implementation | 9 (new) | AudioPool + Riverpod pattern is solid |

### Open Questions
- Is 5 overlay tracks per celebrity worth the asset size (~500KB each)?
- Should AudioPool size be limited for memory on low-end devices?

---

## Round 7: BGM Genre & Social Media Sonic Identity

### Research
- **Casual puzzle BGM**: Lo-fi, chill electronic, pop; common BPM 100-120 for relaxed states
- **Pond5 reference**: "Playful Lofi Puzzle Game" at 120 BPM matches the game's tempo needs
- **Lo-fi gaming culture**: Major Spotify playlists (600+ tracks) pairing lo-fi with gaming
- **Social media notification sounds**: "Gentle pop", bright and crisp, sense of connection
- **Sound-Ideas collection**: 400 iconic internet audio moments for social feeds

### Discussion

**BGM Genre Decision: "Digital Lo-fi Pop"**

The BGM should sound like the **intersection of social media culture and casual gaming**:

- **Base genre**: Lo-fi hip-hop / chill-pop hybrid
- **Digital texture**: Occasional glitch effects, notification-like blips woven into melody
- **Comment theme**: Subtle "typing" sounds as percussion elements (keyboard clicks as hi-hats)
- **Overall feel**: Like scrolling through your phone feed -- familiar, slightly addictive, modern

**Sonic Identity / "Earcon" for Comment Corporation:**

The game needs a **signature sound** -- a 1-2 second audio motif that players associate with the game:

Proposal: A **ascending three-note "pop-pop-DING"** motif:
- Note 1 (pop): Like a notification bubble appearing -- C5
- Note 2 (pop): Slightly higher -- E5
- Note 3 (DING): Resolution with shimmer -- G5 (major triad completion)
- This motif plays at: game start, Fever activation, S-grade achievement
- Variations: reversed for game over, minor key for mental break

**Why this works:**
- Three notes = memorable (Intel, NBC, etc. all use 3-5 notes)
- Major triad = universally positive
- "Pop" texture = social media / notification association
- Under 1.5 seconds = won't cause fatigue

### Score Update
| Aspect | Score (1-10) | Rationale |
|---|---|---|
| Sonic identity / earcon | 9 (new) | Critical for brand recognition and retention |
| BGM genre choice | 9 (new) | "Digital lo-fi pop" perfectly matches theme |

### Open Questions
- Should we commission original BGM or use royalty-free initially?
- Can the three-note motif be generated procedurally for variations?

---

## Round 8: Reference Game Analysis & Audio Budget

### Research
- **Balatro**: All 5 themes in 7/4 time signature, same composition with different soundfonts; smooth transitions; slowed 70% in-game for ambient feel
- **Balatro approach**: Single composer (hired on Fiverr), minimalist chamber music style building on simple themes
- **Vampire Survivors**: Collaboration DLC with Balatro -- upbeat remix of existing theme for high-energy mode
- **Hyper-casual games (Color Switch)**: Punchy, repetitive clips under 1.5s; **22% higher D1 retention**
- **Audio branding**: Signature sound of 1-3 seconds; short enough to avoid fatigue, long enough for recognition

### Discussion

**What Comment Corporation Can Learn from Balatro:**
1. **One core melody, many variations**: Balatro uses the same base composition with different soundfonts. Comment Corporation should do the same -- one melodic motif rearranged per phase and celebrity
2. **Slowed-down ambient feel**: Balatro slows BGM 70% for ambient effect. Our P1 could use a similar technique -- then "speed up" (actually play at normal speed) as phases progress
3. **Minimalism works**: Balatro proves you don't need orchestral scores; a few well-chosen synth voices with clear melody create a distinctive identity
4. **Commission strategy**: Balatro hired a single composer on Fiverr. For Comment Corporation, a similar approach would cost $200-500 for a full BGM suite

**Audio Asset Budget Estimate:**

| Category | # Files | Est. Size Each | Total | Source Strategy |
|---|---|---|---|---|
| BGM base (5 phases) | 1 file (segmented) | ~3 MB | ~3 MB | Commission (Fiverr/custom) |
| Celebrity overlays | 5 files | ~500 KB | ~2.5 MB | Commission |
| Fever BGM layer | 1 file | ~1 MB | ~1 MB | Commission |
| Swipe SFX (correct) | 3 variations | ~30 KB | ~90 KB | Generate/Freesound |
| Swipe SFX (incorrect) | 3 variations | ~30 KB | ~90 KB | Generate/Freesound |
| Combo pitch set | 1 base + pitch shift | ~30 KB | ~30 KB | Generate + code pitch-shift |
| Fever stinger | 1 file | ~100 KB | ~100 KB | Commission |
| Item SFX (4 types) | 4 files | ~50 KB | ~200 KB | Generate/Freesound |
| UI SFX (7 types) | 7 files | ~20 KB | ~140 KB | Generate/Freesound |
| Mental crisis heartbeat | 1 file (loop) | ~200 KB | ~200 KB | Generate |
| Game over (2 types) | 2 files | ~150 KB | ~300 KB | Commission |
| Signature motif | 1 file | ~50 KB | ~50 KB | Commission |
| **Total** | **~30 files** | | **~7.7 MB** | |

7.7 MB is well within mobile game acceptable range (most casual games have 10-30 MB audio).

### Score Update
| Aspect | Score (1-10) | Rationale |
|---|---|---|
| Asset budget efficiency | 9 (new) | 30 files / ~8 MB -- lean and effective |
| Commission vs generate | 8 (new) | Hybrid approach maximizes quality/cost ratio |

### Open Questions
- Should we prototype with free/generated sounds first, then commission final versions?
- Is 7/4 time signature too unusual, or does it add character?

---

## Round 9: Accessibility, Volume Control & File Format

### Research
- **Game Accessibility Guidelines**: "Provide separate volume controls or mutes for effects, speech, and background/music"
- **Hearing loss consideration**: Can affect specific frequencies; independent volume control essential
- **MP3 looping gaps**: MP3 has brief silence at loop points; OGG is gap-free for loops
- **OGG vs MP3**: OGG provides better quality at similar bitrates; 75%+ size reduction vs WAV
- **Sample rate**: 22 kHz retains 90% perceived quality for SFX, reduces processing burden
- **BGM format**: OGG Vorbis at 128kbps recommended for mobile BGM loops
- **SFX format**: Short clips can be WAV (immediate playback) or OGG (size savings)

### Discussion

**Audio Settings UI Design:**

```
[Settings Screen]
  Sound
    Master Volume    [====|======] 70%
    BGM Volume       [========|==] 90%
    SFX Volume       [======|====] 80%
    
    [x] Haptic Feedback
    
    [Mute All] toggle
```

**Key decisions:**
- **3 volume sliders** (Master, BGM, SFX) -- not just on/off toggles
- **Haptic toggle** separate from audio (some players want haptics without sound)
- **Remember settings** via Hive (already in project)
- **Respect system mute**: If device is on silent/vibrate, don't play audio
- **First launch**: BGM at 70%, SFX at 80% (not 100% -- respect the player)

**File Format Specification:**

| Type | Format | Sample Rate | Bitrate | Channels |
|---|---|---|---|---|
| BGM (loop) | OGG Vorbis | 44.1 kHz | 128 kbps | Stereo |
| Celebrity overlay | OGG Vorbis | 44.1 kHz | 96 kbps | Stereo |
| SFX (short) | OGG Vorbis | 22 kHz | 96 kbps | Mono |
| UI sounds | OGG Vorbis | 22 kHz | 64 kbps | Mono |
| Heartbeat loop | OGG Vorbis | 44.1 kHz | 96 kbps | Mono |

**Why all OGG (not MP3)?**
1. No looping gaps (critical for BGM)
2. Better quality per bitrate
3. No licensing concerns (MP3 patents expired, but OGG is natively open)
4. audioplayers supports OGG on both iOS and Android

### Score Update
| Aspect | Score (1-10) | Rationale |
|---|---|---|
| Accessibility | 9 (new) | Separate controls + haptic toggle + system mute respect |
| File format choice | 8 (new) | OGG across the board simplifies pipeline |

### Open Questions
- Should the game auto-detect if headphones are connected and adjust spatial audio?
- Is there value in supporting audio-only accessibility mode for visually impaired players?

---

## Round 10: Implementation Architecture & Asset Naming

### Research
- **Singleton AudioCache**: Each instance has independent cache; singleton ensures load time optimization
- **Pre-loading**: First play has delay; cache all SFX at app init via `preload()`
- **Riverpod pattern**: Providers replace singletons/service locators; auto lifecycle management
- **Audio Design Document**: High-level overview including genre, theme, tone, technical requirements
- **Naming convention**: `type_category_subcategory_action_01` (snake_case, searchable)
- **Asset list columns**: subcategory, event name, description, loop flag, priority, status

### Discussion

**Audio Asset Naming Convention:**

```
assets/audio/
  bgm/
    bgm_main_p1.ogg          # Phase 1 BGM segment
    bgm_main_p2.ogg          # Phase 2 BGM segment
    bgm_main_p3.ogg          # Phase 3 BGM segment
    bgm_main_p4.ogg          # Phase 4 BGM segment
    bgm_main_p5.ogg          # Phase 5 BGM segment
    bgm_overlay_idol.ogg     # Celebrity overlay: idol
    bgm_overlay_actor.ogg    # Celebrity overlay: actor
    bgm_overlay_youtuber.ogg # Celebrity overlay: youtuber
    bgm_overlay_sports.ogg   # Celebrity overlay: sports
    bgm_overlay_politician.ogg # Celebrity overlay: politician
    bgm_fever_layer.ogg      # Fever mode additional layer
  sfx/
    sfx_swipe_correct_01.ogg   # Correct swipe variation 1
    sfx_swipe_correct_02.ogg   # Correct swipe variation 2
    sfx_swipe_correct_03.ogg   # Correct swipe variation 3
    sfx_swipe_wrong_01.ogg     # Wrong swipe variation 1
    sfx_swipe_wrong_02.ogg     # Wrong swipe variation 2
    sfx_swipe_wrong_03.ogg     # Wrong swipe variation 3
    sfx_swipe_whoosh.ogg       # Swipe commit whoosh
    sfx_combo_ding.ogg         # Combo increment base (pitch-shifted in code)
    sfx_fever_activate.ogg     # Fever mode activation stinger
    sfx_fever_end.ogg          # Fever mode deactivation
    sfx_item_detector.ogg      # Detector activation
    sfx_item_freeze.ogg        # Freeze activation
    sfx_item_boost.ogg         # Boost activation
    sfx_item_skip.ogg          # Skip activation
    sfx_mental_heartbeat.ogg   # Low mental heartbeat loop
    sfx_gameover_break.ogg     # Mental break game over
    sfx_gameover_timeup.ogg    # Time up game over
    sfx_motif_signature.ogg    # Brand signature motif (pop-pop-DING)
    sfx_grade_reveal.ogg       # Grade reveal on result screen
    sfx_ui_tap.ogg             # Generic UI button tap
    sfx_ui_select.ogg          # Celebrity selection
    sfx_ui_transition.ogg      # Screen transition swoosh
    sfx_ui_pause.ogg           # Pause toggle
    sfx_ui_resume.ogg          # Resume from pause
    sfx_ui_gamestart.ogg       # Game start countdown
    sfx_phase_transition.ogg   # Phase change notification
```

**AudioService Implementation (Riverpod Provider):**

```dart
// lib/services/audio_service.dart

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AudioService {
  // Players
  late final AudioPlayer _bgmPlayer;       // Main BGM
  late final AudioPlayer _overlayPlayer;    // Celebrity overlay
  late final AudioPlayer _feverPlayer;      // Fever layer
  late final AudioPlayer _ambientPlayer;    // Heartbeat loop
  late final AudioPlayer _uiPlayer;         // UI sounds
  
  // Pools for rapid SFX
  late final AudioPool _swipePool;
  late final AudioPool _comboPool;
  
  // Volume settings (persisted via Hive)
  double _masterVolume = 0.7;
  double _bgmVolume = 0.9;
  double _sfxVolume = 0.8;
  bool _hapticEnabled = true;
  
  // State
  int _currentPhase = 1;
  String _currentCelebrity = 'idol';
  bool _isFeverActive = false;
  bool _isMentalCritical = false;

  Future<void> init() async {
    // Initialize all players
    // Pre-load all SFX into AudioPool
    // Load volume settings from Hive
    // Set up BGM player with loop
  }

  Future<void> playBGM({required int phase, required String celebrity}) async {
    // Cross-fade to new phase BGM segment
    // Switch celebrity overlay if changed
  }

  void playSFX(SFXType type, {int comboCount = 0}) {
    // Play from pool with optional pitch shift based on combo
    // Pitch formula: 1.0 + (min(comboCount, 20) * 0.03)
    // At combo 20: pitch = 1.6 (about +8 semitones)
  }

  void setFever(bool active) {
    // Fade in/out fever layer
    // Play activation/deactivation stinger
  }

  void setMentalCrisis(bool critical, {double mentalPercent = 100}) {
    // Toggle heartbeat loop
    // Adjust heartbeat speed based on mentalPercent
  }

  void playGameOver(GameOverType type) {
    // Stop BGM with fade
    // Play appropriate game over stinger
  }

  void dispose() {
    // Release all players and pools
  }
}
```

**Priority Implementation Order:**
1. AudioService skeleton + volume settings UI
2. Swipe SFX (correct/wrong) -- highest impact, core gameplay
3. BGM Phase 1 -- establish mood
4. Combo pitch escalation -- reward system
5. Item SFX -- gameplay clarity
6. Full phase BGM transitions
7. Fever mode audio
8. Mental crisis heartbeat
9. Game over stingers
10. UI sounds + celebrity overlays + signature motif

### Final Score
| Aspect | Score (1-10) | Rationale |
|---|---|---|
| Implementation architecture | 9 | Clean Riverpod pattern, pool-based SFX |
| Asset naming/organization | 9 | Consistent, searchable, scalable |

---

## Final Summary: Top 10 Sound Design Improvements

Ranked by **impact x feasibility** for Comment Corporation:

### 1. Swipe Feedback Sound System (Impact: 10, Feasibility: 9)
**Three-beat swipe pattern**: whoosh (commit) -> ding/buzz (judgment) -> combo tick (reward)
- Correct swipe: ascending major tone (C-E or C-G interval) + light sparkle
- Incorrect swipe: descending minor/dissonant tone + dull thud
- 3 variations each to prevent repetitive fatigue
- Duration: whoosh 100ms, judgment 200ms, combo tick 80ms
- Haptic sync: medium impact on commit, success/error pattern on judgment
- **Why #1**: This is the interaction that happens every 0.5-2 seconds. It IS the game feel.

### 2. Phase-Driven Adaptive BGM (Impact: 9, Feasibility: 7)
**"Digital Lo-fi Pop" BGM with 5 phase segments**:
- P1 (100 BPM): Chill keys + light beat -- "scrolling your feed"
- P2 (112 BPM): Bass enters, energy rising -- "things are getting interesting"
- P3 (124 BPM): Full groove, synth melody -- "you're in the zone"
- P4 (136 BPM): Driving intensity, rapid arpeggios -- "pressure is on"
- P5 (148 BPM): Maximum chaos, alarm tones -- "final countdown"
- Horizontal re-sequencing with beat-synced transitions
- Include subtle "typing" and "notification" textures in the percussion for thematic identity
- **Why #2**: BGM is the emotional backbone; BPM acceleration physically drives urgency.

### 3. Combo Pitch Escalation System (Impact: 9, Feasibility: 9)
**Programmatic pitch shifting on combo SFX**:
- Combo 0-4: base pitch (1.0x), no extra layer
- Combo 5-9: pitch +2 semitones (1.12x), add sparkle layer
- Combo 10-19: pitch +4 semitones (1.26x), add bell overtone
- Combo 20+: pitch +6 semitones (1.41x), trigger Fever
- Slight random variation (+/- 5 cents) per hit to prevent mechanical feel
- Single base SFX file, pitch-shifted in code via AudioPlayer.setPlaybackRate()
- **Why #3**: Escalating pitch = escalating dopamine. Players FEEL the combo building.

### 4. Fever Mode Audio Transformation (Impact: 8, Feasibility: 7)
**Layered audio shift for 8-second Fever window**:
- Activation: "Pop-pop-DING" signature motif (ascending C5-E5-G5)
- BGM: Add synth bass layer + doubled percussion + high-energy melody
- All SFX gain slight reverb/echo for "euphoric" quality
- Swipe sounds pitch-locked at elevated level (no further escalation)
- Deactivation: Descending chime, layers strip back over 1 second
- **Why #4**: Fever is the emotional peak; audio MUST match the visual excitement.

### 5. Signature Sound Motif / Earcon (Impact: 8, Feasibility: 9)
**Three-note "Pop-Pop-DING" brand motif**:
- Notes: C5 (pop) -> E5 (pop) -> G5 (ding with shimmer)
- Duration: 1.2 seconds total
- Texture: Social media notification "pop" sound + bell resolution
- Usage: Game start, Fever activation, S-grade achievement, app launch
- Variations: Reversed for game over, minor key (C-Eb-G) for mental break
- **Why #5**: Creates instant brand recognition; 22% higher D1 retention with clear earcons.

### 6. Mental Crisis Heartbeat System (Impact: 7, Feasibility: 8)
**Subtle, synced tension audio for low mental states**:
- Mental <= 30%: Bass heartbeat pulse at 60 BPM, synced to red border flash (600ms)
- Mental <= 15%: Heartbeat accelerates to 90 BPM, BGM gets subtle lo-fi filter (muffled)
- Mental <= 5%: Heartbeat at 120 BPM, BGM almost inaudible, isolated heartbeat dominance
- Play 3-4 pulses on first trigger, then reduce to subtle ambient level
- NOT a constant annoying beep -- learned from "Critical Annoyance" anti-pattern
- **Why #6**: Creates genuine tension without frustration; players "feel" the danger.

### 7. Item Activation Sound Kit (Impact: 7, Feasibility: 9)
**4 distinct, immediately recognizable item sounds**:
- Detector (scan): Electronic sweep, rising frequency, ~400ms, "scanning" feel
- Freeze (crystal): Ice crack + time-stop whoosh, ~500ms, reverb tail
- Boost (power): Ascending electric zap + sparkle, ~400ms, energetic
- Skip (wind): Quick wind sweep, ~250ms, casual flick gesture
- Each has unique frequency profile to prevent confusion even at low volume
- **Why #7**: Clear audio feedback confirms item activation; prevents "did I tap it?" anxiety.

### 8. Game Over Dual Stingers (Impact: 7, Feasibility: 9)
**Two emotionally distinct endings**:
- Mental Break (failure): Glass shatter + descending dissonant chord (Cm7b5) + 0.5s silence, 1.5s total. Feeling: "crack under pressure"
- Time Up (completion): Alarm clock buzz + ascending resolution chord (Cmaj7) + soft chime, 1.5s total. Feeling: "you survived!"
- BGM fades out over 500ms before stinger plays
- Signature motif variation plays after stinger (reversed/minor for break, normal for time up)
- **Why #8**: Two endings need two moods; players should feel the difference viscerally.

### 9. Audio Settings & Accessibility (Impact: 6, Feasibility: 9)
**Full player control over audio experience**:
- 3 separate sliders: Master Volume, BGM Volume, SFX Volume
- Haptic feedback toggle (independent from audio)
- Settings persisted in Hive (already in project)
- Default: Master 70%, BGM 90%, SFX 80% (respectful defaults)
- Respect system silent mode -- check RingerMode before playing
- Remember last state between sessions
- **Why #9**: Up to 80% of mobile players play muted; those who don't should have control.

### 10. Celebrity Audio Overlays (Impact: 6, Feasibility: 6)
**Thematic audio differentiation per celebrity type**:
- Idol: Bright EQ boost + bubbly pop synth layer (K-pop shimmer)
- Actor: Cinematic reverb + string pad layer (film-score undertone)
- Youtuber: Lo-fi filter + vinyl crackle texture (internet culture)
- Sports: Stronger drums + subtle crowd ambience (stadium energy)
- Politician: Darker EQ + news broadcast texture (serious/tense)
- Implementation: 5 thin overlay OGG files (~500KB each) mixed with base BGM
- **Why #10**: Adds replay variety and thematic depth; each celebrity "feels" different.

---

## Implementation Roadmap

### Phase A: Foundation (Week 1)
- [ ] Create `AudioService` class with Riverpod provider
- [ ] Implement volume settings UI + Hive persistence
- [ ] Set up AudioPool for SFX
- [ ] Source/generate placeholder swipe SFX (correct x3, wrong x3, whoosh)
- [ ] Wire swipe SFX into SwipeStack widget

### Phase B: Core Audio (Week 2)
- [ ] Commission or source BGM (at least P1 + P3 segments for contrast)
- [ ] Implement combo pitch escalation in code
- [ ] Add item activation SFX (4 types)
- [ ] Add game start / game over stingers

### Phase C: Adaptive Systems (Week 3)
- [ ] Full 5-phase BGM with transitions
- [ ] Fever mode audio layer system
- [ ] Mental crisis heartbeat system
- [ ] Phase transition audio cue

### Phase D: Polish (Week 4)
- [ ] Celebrity overlay tracks (5 types)
- [ ] Signature motif creation and placement
- [ ] UI sounds (tap, select, transition, pause, resume)
- [ ] Grade reveal audio on result screen
- [ ] Haptic feedback integration
- [ ] Final mix balancing and normalization

---

## Technical Specifications Summary

| Spec | Value |
|---|---|
| Audio package | audioplayers ^6.6.0 |
| State management | Riverpod (AudioService as Provider) |
| BGM format | OGG Vorbis, 44.1 kHz, 128 kbps, Stereo |
| SFX format | OGG Vorbis, 22 kHz, 96 kbps, Mono |
| UI sound format | OGG Vorbis, 22 kHz, 64 kbps, Mono |
| Total audio assets | ~30 files |
| Total audio size | ~7.7 MB |
| SFX max duration | 500ms (items) |
| BGM loop | Seamless via OGG (no MP3 gap issue) |
| Pitch shift range | 1.0x - 1.6x (combo 0-20) |
| Volume defaults | Master 70%, BGM 90%, SFX 80% |
| Normalization target | -3 dB |
| AudioPool | For swipe + combo SFX (rapid fire) |

---

## Asset Source Strategy

| Priority | Asset | Recommended Source | Est. Cost |
|---|---|---|---|
| 1 | BGM (5 phases) | Commission on Fiverr/custom composer | $200-400 |
| 2 | Signature motif | Same composer as BGM | Included |
| 3 | Fever stinger + layer | Same composer as BGM | Included |
| 4 | Game over stingers (2) | Same composer or generate | $50-100 |
| 5 | Swipe SFX (6 variations) | Freesound.org + post-process | Free |
| 6 | Item SFX (4 types) | Freesound.org + post-process | Free |
| 7 | UI sounds (7 types) | Generate via AI tools or Freesound | Free |
| 8 | Heartbeat loop | Freesound.org + post-process | Free |
| 9 | Celebrity overlays (5) | Commission alongside BGM | $100-200 |
| 10 | Combo base SFX | Freesound.org (pitch-shift in code) | Free |
| **Total** | | | **$350-700** |

---

## References / Sources

- [Somatone - Best Practices for Casual Game Audio](https://somatone.com/best-practices-for-fine-tuning-and-polishing-in-casual-game-audio-implementation/)
- [GameDeveloper - How to Make Casual Mobile Game Audio](https://www.gamedeveloper.com/audio/how-to-make-a-casual-mobile-game---designing-sounds-and-music)
- [GameDeveloper - The Power of Pitch Shifting](https://www.gamedeveloper.com/audio/the-power-of-pitch-shifting)
- [GameDeveloper - Design with Music in Mind: Adaptive Audio](https://www.gamedeveloper.com/audio/design-with-music-in-mind-a-guide-to-adaptive-audio-for-game-designers)
- [Film Music Theory - Tempo and Rhythm in Video Game Music](https://filmmusictheory.com/article/mastering-tempo-and-rhythm-in-video-game-music/)
- [GameAnalytics - 9 Sound Design Tips](https://www.gameanalytics.com/blog/9-sound-design-tips-to-improve-your-games-audio/)
- [CRI Middleware - Implement Combo SFX](https://blog.criware.com/index.php/2016/11/05/implement-combo-sfx-in-a-few-clicks/)
- [TV Tropes - Critical Annoyance](https://tvtropes.org/pmwiki/pmwiki.php/Main/CriticalAnnoyance)
- [SpeeQual Games - Psychology Behind Game Audio Feedback](https://speequalgames.com/the-human-psychology-behind-game-auido-feedback/)
- [Google Design - Sound & Touch: Design Beyond the Screen](https://design.google/library/ux-sound-haptic-material-design)
- [Apple WWDC19 - Designing Audio-Haptic Experiences](https://developer.apple.com/videos/play/wwdc2019/810/)
- [Sonic Minds - Bridge Between Game Audio and Audio Branding](https://sonicmindsagency.com/the-bridge-between-game-audio-and-audio-branding-part-1/)
- [Moldstud - Creating Unique Audio Identity for Mobile Games](https://moldstud.com/articles/p-creating-a-unique-audio-identity-for-your-mobile-game-strategies-and-examples)
- [Balatro Wiki - Music](https://balatrowiki.org/w/Music)
- [Game Accessibility Guidelines - Separate Volume Controls](https://gameaccessibilityguidelines.com/provide-separate-volume-controls-or-mutes-for-effects-speech-and-background-music/)
- [Blips Blog - Game Audio Files Developer Guide](https://blog.blips.fm/articles/game-audio-files-a-quick-developers-guide)
- [Moldstud - Optimizing Audio Assets for Mobile](https://moldstud.com/articles/p-optimizing-audio-assets-for-enhanced-performance-in-mobile-game-development)
- [A Sound Effect - Game Audio Design Document Guide](https://www.asoundeffect.com/game-audio-design-document/)
- [Audiokinetic - Naming Convention Best Practices](https://www.audiokinetic.com/en/blog/naming-convention-best-practices/)
- [audioplayers - Flutter Package](https://pub.dev/packages/audioplayers)
- [Thiago Schiefer - Documentation and Organization in Game Audio](https://thiagoschiefer.com/home/documentation-and-organization-in-game-audio-with-templates/)
