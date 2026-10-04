# Phase 4B delivery

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4b-debug.apk`.

Version 9 / `0.4.0-phase4b`; update package `com.sneakiicrown.lootlings`, existing local debug key, ARM64, offline/no requested permissions. SHA256 and export/signature/alignment/asset details are in [android-build.json](android-build.json). Prior Phase 4A APK is retained. Debug signing does not certify store release or physical installation.

GO for physical S23 acceptance; HOLD for commercial release and Phase 4C implementation. No physical handset is claimed tested in this pass.

1. Install this APK over the existing Lootlings app. Keep app data; do not uninstall or wipe saves.
2. Home → Begin Expedition → Modes → Relic Siege. At round 10 try Continue or Extract; after an eligible run make one spinner purchase. Check that touches do not attack or charge twice. A death is a valid test outcome.
3. If Act I is cleared, run Rootglass Vault once and inspect tracked Gravebloom/Archive progress. Background/resume once; close/reopen at Home and check gear, mastery, fragments and highest round remain. Report only faults, rough clear duration and obvious stutter/audio/readability problems.

No forced unlock or new-save requirement. Rootglass is correctly locked before Mossglass unlocks. A failed Siege loses only its unsecured checkpoint bundle. Leftover spinner currency expires when the next run starts.

Implementation checkpoint: **bb875227b7e82d442ce68bba7b27c542b4066441**. Its working tree was verified clean, push to `origin/codex/phase2-vertical-slice` succeeded, and `git ls-remote` returned that exact SHA. The post-checkpoint consolidated QA and actual rare-drop/overflow/veil-guard checks are a separate documentation/acceptance checkpoint. APKs remain local ignored build artifacts; GitHub source backup does not distribute the APK.
