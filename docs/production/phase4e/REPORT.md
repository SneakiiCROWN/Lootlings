# Phase 4E implementation and acceptance record

2026-10-05. Continued from preserved Phase 4D QA `a0b99a6` and Phase 4E implementation `0e57b26`; no reset, revert, main merge, player-save mutation or Phase 4F work. Target-facing correction checkpoint: `78a6df48fe15099c0bc2e33f60afbed70f7f818f`. Final art/UI implementation checkpoint: `117d9f0a1185c9f098a9685b146ee4448b5ea948`.

**Owner-test candidate; full Phase 4E visual acceptance HOLD.** Implementation and measurable validation have advanced. Missing authored anatomy, final regional/NPC/boss bodies, motion quality and physical/audio acceptance prevent claiming the entire brief complete.

## Implemented

- Target position owns player facing during active combat; enemy bodies face the player. Attacks, hurt, recoil and recovery cannot permanently override direction. Weapon roots and ranged targets use the same resolver. Enemy lunge/recoil, telegraph placement, impact position, loot launch and HUD placement follow stage position. Normal run entry clears isolated forced-facing state. Forced previews require `LOOTLINGS_QA=1` and are labelled separately.
- Stronger body-led anticipation, commitment and settle; good Relic Beast greatsword and Wanderer authored heavy poses retained. Twelve held families retain their socket architecture. Daggers and claws draw one weapon at each hand socket, with alternating leading hands; no extra overlapping strike blade. This does not certify missing authored hand anatomy.
- All 27 live later-region enemy names have explicit body/material/species mappings. Original BETA hound, bat, toad, crab, beetle, wyrm and shard sprites replace mismatched generic name/body assignments. Native review rejected straight-sided organic bodies; six were refined with curved anatomy and material details. They remain BETA, not final canonical art.
- Enemies now coil/commit by role; hovering bodies dive, tanks brace, casters gather/release. Verdant Mirror uses the same tree/root/crystal/water guardian as its introduction. Its held texture fixes the native flat-rectangle failure. Root Sweep, Thorn Cast, Mirror Charge and recovery have distinct bounded effects and body cues. These transforms do not equal an authored articulated attack set.
- Material contacts and elemental impacts use bounded directional particles, chips, fire tongues, frost shards, lightning branches and poison droplets. Smaller core effects, bounded pickups, less ordinary screen shake and compact HUD improve clarity. No damage, enemy pressure, rarity odds or prices were retuned. Secondary button disabled/pressed/focus states now have distinct value and border treatments.
- 95 new source-documented CC0-derived sounds: 48 weapon variants, 28 material variants, 16 Verdant action variants and RED/bow-draw/staff-charge cues. Seven material routes and species voice routes remain distinct. Existing licensed banks and music retained. Music ducking supports premium and boss events; no blind global gain increase.
- Spinner symbols live in a clipped child aperture. COMMON, UNCOMMON, RARE, EPIC, LEGENDARY and RED have captures and audio paths. Fast/skip is restricted to low three tiers; premium holds remain. Legendary uses gold emphasis; RED adds red crackle, Crownroot caption and a stronger card treatment. Motion/colour improvement is implemented; final BIG OOF feel requires listening and owner review.
- Home residents have deterministic repair/read/inspect/walk/sit/talk schedules; workstation cues now respond to the actual `repair`/`read` states. Existing portrait/body identity retained. Shop/Jobs world hotspots replace redundant navigation. Gear slots are informational, with one functional filter row and signed comparisons. Touch and economy protections preserved.
- 139 authored contextual lines cover twelve selectable voices, residents, victory/defeat, region consequences, weapons and loot. Independent presentation RNG and recent-line memory preserve gameplay RNG. Eligible category weights are 50 context / 25 banter / 15 gameplay / 7 Easter egg / 3 secret, renormalized for available categories. Rare lines have real-time and call cooldowns; secrets need an actual discovery trigger. NPC portrait/action routing is validated with the correct speaker. Canon follows purpose and recorded promises rather than treating Cores as souls.

## Measurement and validation limits

Focused isolated regressions cover Phase 4B/4C/4D, reward/save integrity, touch gestures, audio bank integrity, authored socket contracts and Relic greatsword transitions. Final per-fixture results and native logs are retained in `qa/`; source images and capture checksums are indexed in the evidence manifest.

Native phone: 1080×2340. Native tablet: 1600×2560. Twelve actors × twelve weapons × two facings × six states = 1,728 native matrix samples, on 24 **FORCED FACING TEST** sheets. These sheets expose art debt; they are not real combat staging. Separate target-facing captures advance the normal game process with QA-staged left/right and side crossings, melee/ranged, windup, hit and recovery, with forced-facing override zero. Current gameplay is lane-based and offers no free lateral crossing control; staged crossings test the normal resolver/render path, not a new movement feature or a human S23 recording.

Frozen before evidence used 1080×2316 on `a0b99a6`; after phone is 1080×2340. Both are desktop GPU/vsync samples of 90 frames, not a controlled same-size performance benchmark or S23 FPS acceptance. Before Home p95 16.685 ms, texture 286,170,721 B; after Home p95 16.682 ms, texture 297,617,481 B. Before bow p95 16.690 ms, texture 286,695,009 B; after bow p95 16.686 ms, texture 297,617,481 B. Texture residency grew roughly 11 MB for new imported bodies/effects; no claim of an FPS gain. The frozen native fixture finished, but its process reported a sandbox certificate-store error; qualified baseline logs are retained.

Native Master capture includes 29 examples: twelve weapon, seven material, four Verdant actions and all six spinner tiers. No dropped capture frames or full-scale clipping in the accepted capture. Headroom alone is not quality acceptance. Weight, material distinction, elemental/boss identity, repetition fatigue and Legendary/RED oomph still need direct listening and S23 speakers/headphones approval. Internal RMS is not integrated LUFS or Windows loopback.

Rejected runs are not hidden: initial native target fixture leaked its temporary SceneTree helper on exit; it was freed explicitly and rerun. A later fixture had a missing toast helper. Earlier sampled rare dialogue consumed a later preview cooldown; a fresh isolated director per category fixes evidence without changing gameplay cooldowns. Android verification originally assumed a fixed audio count, then missed Windows path separators; verification now compares exact normalized source-manifest paths and 424 imported PCM assets byte-for-byte. Smoke also contained obsolete painted-secondary-button and `Left` result-label assertions; the current compact secondary style and `At finish` label are now tested without removing economic/combat assertions. A UI capture initially left the Gear overlay open; actual spinner capture replaced that misleading evidence. Frozen boss impact captures also incorrectly displayed the next telegraph because the fixture kept the attack clock low after execution; replacement captures advance the normal game effect clock and prove predicted/executed ROOT SWEEP, MIRROR CHARGE, THORN CAST and RECOVER agreement at 0/0.15/0.30/0.45 seconds. These failures were validation defects, not reasons to weaken game difficulty or reset saves.

Original 2 wins / 5 smoke runs are historical, not a balance target. The pre-device report established the reused-state/seed harness was invalid and superseded it with fresh isolated distributions. Phase 4E does not retune DPS/TTK/economy to turn smoke seeds into wins. See `docs/production/phase2/COMBAT_SEED_DIAGNOSTICS.md` for the independently seeded 3/5 correction and policy interpretation, and `docs/production/predevice/REPORT.md` for later paired cohorts. Final Phase 4E fresh smoke produced 4/5 with unchanged combat assertions; this remains a tiny policy sample, not a population win-rate claim.

## Native visual judgement and remaining blockers

Verdant introduction and body now agree. Spinner symbols remain inside the aperture in inspected motion/stop/reveal samples. Dialogue has legible wrapping and correct resident routing. Gear uses one filter hierarchy. Organic regional shapes gained anatomy, but remain a visibly different BETA sprite treatment against painterly backgrounds; they require art-direction approval and further authored animation.

A mirrored target-facing root does not transform a front-facing portrait into a complete combat pose. The existing exact support contracts still show 82 actor/weapon combinations pending on the right and 83 on the left. Bow/crossbow draw hands, paired grip anatomy, sling release, creature heavy/staff/spear support and some left-facing bodies remain genuine canonical-art blockers. Moonkip baked props and Mosskin shield/support conflicts remain. Patch/Sera/Ilex bodies agree with their current portraits, but use provisional reused hero art and lack articulated resident work/talk poses. Other regional bosses still use BETA proxy identities. No fake arms, smeared sprites or AI-generated final art were introduced to disguise these gaps. Exact records: `evidence/weapon-matrix.json`.

Physical S23 cutout/insets, frame pacing/thermal behaviour, long-session memory, final speaker mix, pause/resume and save persistence remain unaccepted: ADB reported no attached device. Desktop native and isolated lifecycle/save tests provide regression evidence, not physical-device sign-off.

## Fact checking

[Godot Control input and clipping](https://docs.godotengine.org/en/stable/classes/class_control.html) supports the clipped decorative child with ignored touch input; native and gesture fixtures check actual behaviour. [Godot Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) informs package/export validation; APK signing/alignment/import checks provide local evidence. [Audio limiter documentation](https://docs.godotengine.org/en/4.7/classes/class_audioeffectlimiter.html) describes peak control, not pleasant sound or device mastering. No copied outside-game values or unsupported industry-practice claims were used.

## Multidisciplinary sign-off

| Discipline | Status | Evidence / unresolved acceptance |
|---|---|---|
| DESIGN | issues | Presentation improves; complete body/weapon feel still blocked. |
| BALANCE | pass (regression scope) | No balance tuning; combat/socket and reward regressions preserved. Not a new full balance certification. |
| ECONOMY | pass (regression scope) | Prices/odds/receipt/pity unchanged; isolated reward/save tests pass. |
| ROSTER | issues | All twelve captured; missing anatomy and baked-prop conflicts remain. |
| ENEMIES | issues | Explicit species and motion improved; regional BETA art/animation approval open. |
| BOSSES | issues | Verdant identity repaired; articulated actions/other final regional bodies open. |
| RNG | pass (regression scope) | Independent cosmetic/dialogue RNG; rare eligibility/cooldowns and gameplay RNG isolation checked. |
| UI/UX | issues | Native readability/gesture regressions pass; S23 owner/cutout acceptance open. |
| NARRATIVE | issues | Contextual bank and canon checks implemented; complete player-path owner approval open. |
| AUDIO | issues | Licensed variants/routing/capture pass; perceptual mastering/device listening open. |
| MOBILE | issues | Verified APK and native layouts; physical device absent. |
| QA | issues | Accepted focused tests/native evidence; art/audio/device acceptance cannot be automated away. |
| PRODUCTION | issues | Separate implementation and QA checkpoints; Phase 4E visual HOLD, no Phase 4F. |
