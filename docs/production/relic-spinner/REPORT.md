# Relic Spinner implementation and acceptance

Started 2026-10-04; completed 2026-10-05. Follow-up to frozen Phase 4C QA `0664e4eb298d8de33e1d89b003c5a180e71d5e5b`; branch `codex/relic-spinner-followup`. Spinner implementation: `1a372732bc015a68cd60685778e433d696dd0dd2`, with [source hashes](source-checkpoint.json). Phase 4C implementation `6ebf74d81ac1eab5b9a5a9f083043e4da869a0dc`, final native correction `64b3c8ce33b0f0da8b2ab5f658ea80b173b22353`, and QA remain separate and remotely backed up.

## Delivered behavior

An original fantasy three-reel engine replaces the fixed 0.85-second cycling icon. A cubic ease slows fast passing seals into the final alignment, followed by a rarity-dependent anticipation hold and result lock. Grey/blue Common, green Uncommon, blue Rare, purple Epic, gold Legendary and red Crownroot have progressively stronger accents, punch, rings/streaks and bounded bursts (0/6/10/16/22/26 strokes). Legendary uses a longer hold and larger seal punch; RED adds crackle, restrained two-unit shake, a red premium card and a composed stinger. This is local 2D drawing without new raster art, particle-node forests or shaders/bloom dependencies. Existing canonical frame/resource icons are reused; the staff icon is existing BETA art, not newly authored RED art.

The background dims, wallet updates immediately, the large spin button disables during payment/reveal, and the reward appears in a readable card. Pool & Odds is an optional full-size sheet. It discloses probabilities, conversion and decorative passing symbols: their passage is flourish, not a claimed near-win or evidence of reward odds. Results are selected/saved at payment; animation and Skip do not reroll.

First paid spins use full timing. Subsequent Common/Uncommon/Rare reels take 0.75 seconds plus their short hold/reveal and can be skipped. Epic/Legendary/RED always retain full timing: approximately 3.32/3.82/4.45 seconds total. Back cannot bypass a premium reveal. Reduced Motion suppresses punch/shake and limits burst strokes while retaining the result/timing. Normal Skip advances the existing result, never payment. After a RED-ready paid spin, the result card stays unobstructed; the forge action is available on reopening the engine or through Modes. A mode forge returns to Modes, a run reveal to Results.

Existing 24-fragment Gravebloom forge and actual secured 1% RED drops both use this full special presentation. Ordinary small pickups do not use the engine. No cash purchase, unlimited repeat spending, new currency, generic gear gambling or extra confirmations were introduced.

## Fairness, save contract and measured change

Every paid spin adds one persistent spark. Twelve sparks convert to one Crownroot fragment; 24 fragments still forge the existing RED item. This adds a slow deterministic side path (288 paid spins from zero if used alone, minimum 96 fully funded eligible runs at the unchanged three-spin cap), alongside existing dungeon/Siege fragments and their unchanged 1% complete drop. Low rolls give useful progression and also advance this path. No fragments expire and the forge remains a deliberate action.

Costs remain 140/230/360 (730 total), three spins per eligible run, leftover currency only and no boss seals. Material/mastery/recipe category probabilities remain 50/35/15%. Material results now include larger Epic/Legendary bundles:

| Tier | Probability | Actual progression reward |
|---|---:|---|
| Common | 42% | 2 local materials |
| Uncommon | 35% | 6 mastery for each selected actor and weapon |
| Rare | 15% | 1 regional recipe clue; 2 materials if recipes complete |
| Epic | 6% | 5 local materials |
| Legendary | 2% | 8 local materials |
| RED | Guaranteed forge, not a random paid spin | Gravebloom Staff for 24 fragments |

Rarity here describes the reward bundle/reveal, not a claim that materials became Legendary equipment. The pool names the exact amount/type. This deliberately bounded material increase provides substantive jackpot value without altering combat stats, item rarities/affixes or difficulty.

Frozen baseline was measured before edits (`spinner-before-6c923efbf0`, original 9,000-spin totals material 8,932 / mastery 19,122 / clues 1,347). A paired 10,000-seed comparison then measures 3-spin distributions using the frozen original roll rule and actual new catalog, with one RNG draw per spin. [Full distributions](distributions.json), [accepted logs/results](qa-results.json).

| Three-spin output | Before mean; p10 / median / p90 | After mean; p10 / median / p90 |
|---|---|---|
| Materials | 2.9888; 0 / 2 / 6 | 3.8988; 0 / 4 / 8 |
| Mastery | 6.3282; 0 / 6 / 12 | 6.3486; 0 / 6 / 12 |
| Recipe clues | 0.4509; 0 / 0 / 1 | 0.4488; 0 / 0 / 1 |

Material zero-runs remain 1,283/10,000; these receive other progression rewards. Mastery/clue variation reflects finite sampling; their population probabilities and amounts are unchanged. Material expectation rises from 3 to 3.9 (+30%); measured maximum rises from 6 to 21. Every run still spends at most 730; combat DPS/TTK/HP, shops and encounter difficulty are unchanged. The change is retained as the explicitly requested useful high-tier bundle, with long-term physical play/economy acceptance still open.

Debit, pending receipt and spark/fragment increment share one endgame snapshot. Save failure rolls back all three. Existing cross-store receipts make material/mastery/clue/item recovery idempotent, including interrupted delivery, completed-recipe conversion and full-stash reservation. Old version-1 saves missing `spin_sparks` load with zero sparks and retain all prior progress. Run resets clear wallet/count, not chase progress. Tests exercise four fresh funded runs to the first fragment, reload, write failure, duplicate taps, all five paid tiers, RED forge, secured-drop routing and mode origin. Player saves were not touched.

## Native review and audio

Actual Godot windows at phone 1080×2316 and tablet 1600×2560 were rendered and supplied with deliberate touch input. All six tiers, passing reels, hold, bursts/cards, pool, repeat Fast/Skip, immediate paid wallet, no duplicate debit/combat leak, full RED forge/drop and Reduced Motion were reviewed. [Phone cards](1080x2316-result-review.webp), [bursts](1080x2316-burst-review.webp), [tablet cards](1600x2560-result-review.webp), [bursts](1600x2560-burst-review.webp); full-size pool/rolling/Skip/RED frames are alongside these. Final focused captures also verify the RED-ready card/forge row cannot overlap. These are inspected native captures, not mockups. QA funds/tiers are isolated fixtures, not claims about a normal player's six consecutive wins.

Rolling desktop medians are ~16.67 ms, p95 ~16.67–16.72 ms on RTX 4080 SUPER; settled frames ~16.67 ms, 87/95 draw calls at the two viewports. Screenshot encoding is excluded from rolling samples. These do not certify S23 frame pacing, PSS, thermals or speaker balance.

Signals expose `chest_windup`, slowing `equip` ticks, `chest_land`, tier-specific resource/rarity/rare/epic/legendary cues, and RED `core_awaken` + `legendary_reveal`. Native tests verify the cues reached the live manager. All existing 329 licensed/designed PCM assets and source/license documents remain unchanged. RED's unique combination is implemented using existing clips; dedicated final stinger composition and device listening acceptance remain audio debt. No new anonymous stock or AI final art/audio was used.

Initial failed synthetic contacts hit the 180 ms transition guard; tests now wait for deliberate contact timing. A combined cross-size Windows window reposition also disrupted a synthetic touch; separate fresh native processes/save namespaces for each viewport resolve this. Those failed investigations are excluded from acceptance logs. The Phase 4C Skip fixture now seeds a low tier explicitly, because premium results intentionally cannot skip. No difficulty was reduced to satisfy tests.

Current [Godot Control documentation](https://docs.godotengine.org/en/stable/classes/class_control.html) informed passive reel/meter input handling and clipping; [AudioStreamPlayer documentation](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) informed bounded existing cue reuse. The established release-owned touch path and lifecycle adapter are preserved.

## Build, checkpoint and owner test

New APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-relic-spinner-debug.apk`, version **11 / 0.4.2-relic-spinner**, same package/key. ARM64, signed, 16 KB aligned, no requested permissions; [build verification](android-build.json) contains the exact SHA256/bytes. The original Phase 4C APK remains preserved. Source pushes back up source/evidence, not the ignored local APK. Final commit SHAs and remote comparisons are supplied in the delivery response; a commit cannot contain its own hash.

Install over the current S23 app, keeping data. After a 10+ kill run with 140+ leftover currency, inspect Pool & Odds, run one full reveal and repeated low-tier Fast/Skip; background/resume once and reopen to verify saves/progress. Forge only if already holding 24 fragments; do not grind a jackpot for QA. Report faults with screen/action plus screenshot/clip. Physical sound/motion comfort, finger readability, process kill/recovery, loading/PSS/thermals and long-term economy acceptance remain required. Existing authored roster/support/left poses, unique boss bodies/animation, final RED item identity and final audio remain commercial blockers.

## Multidisciplinary sign-off

PASS is scoped to this implementation or unchanged contracts; it is not commercial approval.

| Discipline | Status |
|---|---|
| DESIGN | PASS — original bounded reward presentation with clear progression |
| BALANCE | PASS — combat values/encounters unchanged; retention regressions |
| ECONOMY | ISSUES — measured bounded bundle increase; long-term owner acceptance pending |
| ROSTER | ISSUES — existing authored pose/identity debt preserved |
| ENEMIES | ISSUES — existing final animation/art debt preserved |
| BOSSES | ISSUES — existing unique boss bodies/animation debt preserved |
| RNG | PASS — disclosed catalog, one draw, deterministic chase, no Skip reroll |
| UI/UX | ISSUES — inspected native layouts/interactions pass; physical acceptance pending |
| NARRATIVE | ISSUES — established fantasy terminology retained; broader canon acceptance open |
| AUDIO | ISSUES — live cues/license regressions pass; final stinger/device listening pending |
| MOBILE | ISSUES — build/native layouts pass; S23 performance/lifecycle acceptance pending |
| QA | ISSUES — isolated distribution/save/touch/native coverage passes; device gate open |
| PRODUCTION | ISSUES — separated safe checkpoints; commercial art/audio/device gates open |

**GO FOR S23 OWNER TEST. HOLD FOR COMMERCIAL RELEASE.**
