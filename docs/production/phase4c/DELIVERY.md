# Phase 4C delivery and smallest S23 retest

**GO FOR S23 OWNER TEST. HOLD FOR COMMERCIAL RELEASE.**

APK exact Windows path:
`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4c-presentation-debug.apk`

Version code **10**, version name **0.4.1-phase4c**, package `com.sneakiicrown.lootlings`. ARM64 debug APK uses the existing local debug key, has no requested Android permissions, and passes signature verification and 16 KB zip alignment. Actual exported icons/splash match canonical branding; current bow/poses/audio and all three new presentation modules are included. [Build bytes/hash and package checks](android-build.json); [actual branding](actual-apk-branding.png). Source push does not distribute this local ignored APK.

Implementation checkpoint: `6ebf74d81ac1eab5b9a5a9f083043e4da869a0dc`. Native-review follow-up checkpoint updates the paid spinner wallet during wind-up; [source-checkpoint.json](source-checkpoint.json) records the final implementation SHA and runtime hashes. Push/`git ls-remote` verified the implementation branch. Evidence/report is a separate QA commit, whose exact SHA and final remote verification are supplied in the completion message (a commit cannot contain its own hash).

1. Copy this APK to the S23 and install **over the existing Lootlings app**. Keep app data; do not uninstall or clear storage. Confirm the existing character, gear and progression remain.
2. At Home, tap Patch twice, then Patch → Sera → Ilex, empty space and Back. Open both roster tabs, scroll Gear/regions, inspect one item and enter Forge/Archive/Jobs. Check taps/scrolls neither select unintentionally nor attack; Common/Rare salvage should be one deliberate action, protected gear should warn. No forced unlock or destructive item sacrifice is required.
3. Play one bow run (Mossglass/Rootglass if already unlocked), inspect boss direction/HUD/merchant/level-up and one eligible spinner reveal/Skip. Background/resume once, return Home, close/reopen and verify saves. Report only faults: screen/action, screenshot or short clip, obvious stutter/loading/audio jump, and any missing/duplicate reward. A defeat is a valid test outcome; do not grind a win for QA.

Remaining physical tests: real finger comfort/text readability/cutouts, installation/save upgrade, speaker/headphone path balance and fatigue, loading, frame pacing/FPS/PSS/thermal behavior, background/resume/process restart. Desktop native validation cannot certify these. The existing mobile monitor/profiling tools remain available; no new diagnostic workflow is required from the owner before this brief retest.

Authored support/paired and human ranged/left poses, weaponless Moonkip, unique boss bodies/animations, final human art and final music/SFX remain blockers to commercial approval. Verdant is explicitly a clean BETA Mosskin guardian reuse. This pass stops here; no automatic housing/pet/final-art expansion.
