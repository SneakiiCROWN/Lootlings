# Phase 4E owner-test delivery

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-gamefeel-debug.apk`

Version 13 / `0.4.4-phase4e`. 134,784,500 bytes (128.54 MiB). SHA-256 `76c353d07917fd3a158d671aa5a9c6007ede7ee661586e92080f0524c71d2791`.

Implementation checkpoints: `0e57b26`, `78a6df4`, final `117d9f0a1185c9f098a9685b146ee4448b5ea948`. Separate QA/report commit is the following branch checkpoint. See git log and remote branch for its final SHA. All existing Phase 4D/4E ancestry preserved; no main merge or Phase 4F work.

**GO for owner regression testing only; HOLD for full Phase 4E visual acceptance and production release.** The APK is verified debug-signed arm64, min SDK 24 / target SDK 36, 16 KB aligned, offline/no Android permissions. All 424 PCM imports compare byte-for-byte with local assets; exact source-manifest SFX coverage, bow, retained greatsword poses and new runtime modules verified. Physical device validation is false. ADB listed no attached device.

Minimal S23 retest:

1. Copy this APK to the S23 and install it over the existing Lootlings build. Keep the existing installation/save; do not uninstall. If Android rejects the update, stop and send the exact error instead of clearing data.
2. Confirm your existing character/gear/currencies, swipe Gear and tap one filter, then visit Patch/Sera/Ilex. Record roughly 30 seconds of bow, paired daggers/claws and heavy/staff combat, including a hit and recovery. Check direction, grips, input leakage and audible weapon/material differences. Visit Verdant Mirror if already unlocked; do not spend to unlock it solely for this test.
3. After a normal run, use the available spinner/reward path. Check clipping, readable card and repeat/skip behaviour. Capture Legendary/RED if naturally available; QA previews cover rare tiers without requiring you to chase RNG. Background/resume once, then close/reopen and confirm save/currencies. Send the short recording and any audio/readability/stutter issue.

Native all-tier previews do not grant rewards or ship as forced outcomes. Device frame pacing, thermal/long-session memory, safe areas and speaker/headphone mastering remain open. Exact art blockers and multidisciplinary sign-off are in REPORT.md.
