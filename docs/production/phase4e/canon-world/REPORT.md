# Phase4E canon/world integration — implementation and native acceptance

**GO for scoped S23 owner review; HOLD for full Phase4E/release.** Continue Phase4E, never Phase4F. Preserved source-sync checkpoint: `79fecef956e3c611b0d3613ac647af6e635aff75`. Main implementation: `34939d5748add93b3c6b124263822dcfd2f8f213`. Latest implementation/caption correction: `2d3a8028594f714a7b9b1889233db5d4967c9451`. The separate commit containing this report is the QA checkpoint; its exact SHA and remote verification are supplied in the delivery response.

## Visible integration

- Home, Gear/Stall/Training staging and character memories reuse the seven original canonical neutral exports without tint substitution. This is static neutral staging, not fabricated movement/attacks or opposite-facing art. Working combat rigs and exact-state resolution remain untouched.
- Field Notes becomes an illustrated collection with All/Cast/Trails/Bosses/Gear navigation: seven existing Lootling origins/personality entries, five accepted Wanderer appearances, Patch/Ilex/Sera biographies, unlocked regions, recovered boss accounts, and owned/equipped gear descriptions, actual effects, rarity and Forge paths. Gear variants retain separate stat/affix differences. No purchases, rewards, discovery writes or RNG consumption.
- Memory cards use six existing canonical expression portraits plus accepted actor/NPC/region artwork, with independent readable text beside thumbnails. The established Archive painting now backs Field Notes, Memories and Trophies.
- Seven existing regional boss accounts are wired into the existing replay and lore systems: Lantern Jackal, Belljaw, Drowned Engine, Redactor, The Unchosen, Chainwarden and Hollow Crown. They derive unlocks from existing completed-region data and use actual region paintings where final boss bodies are unavailable. No new save keys, bosses, encounter pauses, lore or proxy-body approval.
- Merchant comparisons scroll inside their panel; native finger swipes expose equipped-vs-new changes and cost without charging or equipping. Existing separate purchase guards remain intact. Region departure sheets now show their actual arena painting with scrollable detail.
- RED equipment drops, chest profiles, item badges and direct/boss reward sound cues no longer fall through to Common or gold. Existing `relic_red` authored sound is reused. Scarlet halo/beam and bounded particles distinguish top-tier drops; ink-backed labels remain readable over combat. Spinner odds, all six spinner tiers, earned free spins and save protections are unchanged.
- Memory actor textures uniformly fit their bounds, fixing stretched tall boss art. This improves the renderer, not the defective Hoard Dragon source tail. Long recovered accounts now use separate authored timed captions rather than overflowing one panel.

## Sources and measured scope

Used current `world_story.gd`, `lootling_catalog.gd`, `wanderer_catalog.gd`, `vignette_catalog.gd`, current campaign/boss-pattern/item catalogs, accepted neutral/portrait exports, established NPC art and region/UI/gear assets. Conflicting historical universe-bible biographies were not copied over current canon. No rejected handoff body/name/region is imported. The five rejected boards remain rejected; no new handoff guidance or body artwork was needed.

New canonical artwork/extractions/crops/masks: **0**. Existing original extracts preserved: **78**. Newly connected neutral body uses: **7 actors across Home/stations and replay**; existing portraits and environments now drive the illustrated Archive. Runtime content routes grow from 6,790 to **6,805** records (LIVE_BETA 2,995 → **3,010**); none are promoted LIVE_FINAL.

| Art measure | Accepted baseline | Current |
|---|---:|---:|
| Exact missing delivery cells | 3,065 | 3,065 |
| Playable missing cells | 2,327 | 2,327 |
| Other missing cells | 738 | 738 |
| Shared body/view bundles | 106 | 106 |
| Full support packages | 165 | 165 |
| Combat TEMP cells closed by this batch | — | 0 |

Neutral Home/replay improvements do not close missing combat states. [Exact state/canvas/alpha/baseline/socket requests](../../NEEDS_NEW_CANON_EXPORT.json), [active replacement register](../polish/CANONICAL_REPLACEMENTS.md) and [preserved later-system queue](LATER_SYSTEM_INTEGRATION.json) remain authoritative. The 11 pre-existing planned records stay outside implemented current canon: three future chest encounters, historical/board-only NPC plans, authored pets/decor and store presentation. This is not authorization to implement new NPCs or systems.

## Native and automated evidence

[106 full-resolution native captures](GALLERY.md): phone 1080×2340 and tablet 1200×1920, including eight before captures. Before captures render the exact accepted `79fecef` Hideout script against current shared data/resources; they are a UI comparison, not a full historical binary. No checkout/reset/revert occurred. Regional-boss replay evidence uses forced completed-region QA discovery, clearly identified in the gallery; no real-player progress was granted.

Native inspection corrected thumbnail/text collisions, two encoding defects, merchant overflow, memory aspect distortion and regional-caption overflow. Every newly wired boss hint/victory caption is checked against the real 105px caption bound on both layouts. Current combat-drop evidence deliberately shows the remaining TEMP Gloomlet rig; it is not visual acceptance of that body.

Nine fresh targeted fixtures pass: field notes/provenance/read-only inventory/discovery; extracted art; direct reuse; 144 weapon combinations/864 samples with zero technical contact faults; gesture safety; earned-spin/save rollback; semantic rune mapping; reward/purchase safety; and six-tier spinner distributions, repeat/skip/RED protection/pity. Eight canonical freeze mutation checks pass (11 frozen sources, five rejected boards, 246 preserved authored pose rows, zero approved replacement boss frames). Follow-up caption/aspect checks and native fixtures pass. [Logs](qa/) retain the sequence; later caption evidence supersedes earlier aspect-only captures. Regressions preserve gameplay difficulty and do not make seeds artificially win.

APK export/signature/alignment/package checks pass. The actual compiled APK catalog is loaded and verified to contain 11 boss accounts, three separate Drowned Engine captions and all five Field Notes categories. This proves shipped code content, not physical Android acceptance.

## Android delivery

- Version **29 / 0.4.20-phase4e-canon-world**.
- Exact Windows path: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-world-debug.apk`.
- **140301297 bytes**, SHA256 `0ff6c189942c9d0990706ff536b9464beeba6bb5b1049876fbcf9c012d3183be`.
- Signed debug arm64, Godot 4.7.2 official template, min SDK24 / target36, 16KB aligned, branded splash, no permissions. Reference/source/test art excluded; all 78 preserved original extracted assets, five accepted Wanderer bodies, two Home props and licensed audio are verified in the package.
- Prior v28 source-sync APK remains available unchanged. Physical device validation is **false**.

## Exact blockers and acceptance gates

Canonical combat actions/views/support layers remain absent for the outstanding queue. In particular: original Moonkip weaponless paws cannot be fabricated from occluded dagger pixels; Gloomlet action/facing exports must preserve the violet furry Assassin; Relic Beast/other TEMP action bodies are not final; Hoard Dragon still needs one continuous canonical source tail; distinct regional enemy/boss/NPC activity packages remain open. Existing neutral/region artwork is not a substitute for those states.

Separate non-art gates: semantic/cross-store/process-death save acceptance; final audio/mastering/perceptual acceptance; physical S23 frame pacing/FPS, memory/rendering, lifecycle/input/safe-area testing; and final player-facing owner visual approval. Desktop captures and clipping-free audio do not close these gates.

Small S23 retest: install v29 over the existing app (keep saves); check Gloomlet/Moonkip Home and Archive Cast/Gear/available Boss accounts; swipe a merchant comparison and return Home without buying; run combat with the dedicated ATTACK control, pause/background/resume and confirm saved progress. Regional accounts only appear for already completed regions. Report any clip, wrong identity, unintended spend/attack or lifecycle loss with its screen/state.

## Multidisciplinary sign-off

This is batch acceptance, not full Phase4E acceptance. No discipline with an open player-facing blocker is marked full PASS.

| Discipline | Status / evidence or gate |
|---|---|
| DESIGN | issues — canonical presentation and owner acceptance remain open |
| BALANCE | pass for preserved scope — no values/timing/difficulty change; full prior measured work retained |
| ECONOMY | pass for preserved scope — read-only Archive and existing reward/purchase protections; no prices/odds changes |
| ROSTER | issues — exact canonical action/facing art incomplete |
| ENEMIES | issues — regional TEMP/proxy replacements remain |
| BOSSES | issues — Dragon source tail and distinct authored states remain |
| RNG | pass for preserved scope — no new random reward consumption; six-tier distribution/pity regressions pass |
| UI/UX | issues — native corrections pass; final owner and physical touch acceptance open |
| NARRATIVE | pass for this integration — current authored canon reused, discovery gated, no board/historical identity override |
| AUDIO | issues — correct RED hook reused; perceptual/mastering acceptance still required |
| MOBILE | issues — export/native layouts pass; physical S23 performance/lifecycle/input not yet accepted |
| QA | issues — targeted tests and native evidence pass; full external acceptance gates remain |
| PRODUCTION | issues — safe separate checkpoints; Phase4E HOLD until art/owner/device gates close |
