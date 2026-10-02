# Phase 2 S23 Ultra test build — 2026-10-02

This is a signed arm64 **debug APK for device testing**, using the actual Godot 4.7.2 Android template. It is not a store/release candidate. It keeps `com.sneakiicrown.lootlings`, so repeat installs with the retained local debug key preserve this build's device saves. Do not uninstall an existing differently signed installation to bypass a conflict without first preserving its save data.

Final prepared APK: `builds/android/Lootlings-phase2-s23-debug.apk`, **115,605,512 bytes (110.25 MiB)**. SHA256: `225f27b0ed72b9b8a8d9df7c3854c1f2890e73c1531f117009d9f620d523e3fa`.

[Final build report](android-final-build-report.json) records verified signatures, 16KB ZIP alignment, package/architecture/SDK/permission checks and byte-identical final imported ready/strike textures (768 runtime size limit). The APK also contains compiled greatsword motion, safe-area layout and test-monitor modules. [Export](android-final-export.log), [signature](android-final-signature.log), [alignment](android-final-alignment.log), [Android package inspection](android-final-badging.log) and [empty device inventory](android-final-adb-devices.txt) are portable acceptance evidence. Export finished successfully with no errors or warnings; no physical device was available.

## Smallest phone test

1. Copy `builds/android/Lootlings-phase2-s23-debug.apk` to the phone, open it in My Files, allow that installation source if Android asks, and install. Open Lootlings; note roughly how many seconds the first usable screen takes.
2. Play an Act I expedition for about ten minutes. Check tap response, readable windups/strike/hit reactions, HP/text, merchant/upgrade/reward buttons, VFX and screen edges. During combat press Home, return, confirm the Pause screen and resume. After returning to Hideout, close/reopen the app and confirm gear/progression survives. If a boss/reward is not reached, report that device check as pending rather than passed.
3. Open combat Pause → **TEST REPORT** and send a screenshot together with any obvious clipping, lag or touch problem. For complete diagnostics, connect USB with debugging enabled and approve this PC; the PC collector below reads the report without changing phone data.

No phone is attached to adb during build preparation; installation, real touch, device GPU/frame pacing, thermal behaviour and physical lifecycle acceptance remain pending. Native desktop fixtures cover the renderer/layout/input dispatch and persistence contracts, not the phone's driver or OS.

The guarded `mobile_monitor_qa` native fixture passed without errors: actual game integration, 120 combat frames, readable report panel, valid persisted JSON and suspend/resume counters. [Native report panel](android-test-report-native.png), [fixture result](android-monitor-native-results.json) and [desktop telemetry example](android-monitor-desktop-report.json) are preserved. These desktop metrics are explicitly not S23 results.

## Reproduce and collect

From the repository, with Python 3 and the existing Godot 4.7.2 Windows editor (or `GODOT` pointing to it):

```powershell
python tools/build_android.py --prepare
python tools/collect_android.py
```

`--prepare` downloads only verified official Godot, Temurin JDK17 and Google SDK archives into ignored `.godot_test_data/android`. Subsequent builds use those tools, workspace-local editor settings and the same ignored `debug.keystore`. Retain that key to upgrade an installed test APK without losing its save; it is intentionally not a production signing identity. No Android Studio, NDK, Gradle, global SDK installation or physical-device modification is needed for this prebuilt-template export.

`build-report.json` alongside the APK records its SHA256 and checks. Export logs, signature verification, 16KB ZIP alignment and Android package badging are under `.godot_test_data/android/`. Expected package: arm64-v8a, SDK24 minimum, target SDK36, GLES3 compatibility, portrait, debug-enabled, no requested permissions. Actual template SDK36 is authoritative; [Godot 4.7 export instructions](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html) currently list older SDK35 tools, so preparation uses the matching [official Google SDK repository](https://dl.google.com/android/repository/repository2-1.xml).

Collector output is ignored `builds/android/device-report-TIMESTAMP/`: game JSON, Android `dumpsys meminfo`, display properties, frame stats and recent logcat. `run-as` works because this is a debuggable APK. Android `gfxinfo` may omit native GL rendering; the game's frame histogram and a Perfetto trace are the better pacing evidence. Review recent logcat before sharing because it can contain unrelated system/application messages.

## What the report means

The test-only monitor uses bounded 251-bin whole-frame and combat histograms. It records p50/p95/p99, average FPS, worst frame, frames over 33ms, texture/static memory counters, draw calls, screen/safe-area/window/canvas dimensions and the latest sixteen lifecycle/state events. It samples frame intervals without changing combat timing. Focus/pause events reset the frame clock so background time does not inflate pacing. Actual foreground stalls remain counted. Reports are written only on state/lifecycle transitions or opening Test Report, not every frame.

Loading in the report begins at the game's ready node, excluding engine/process start: time cold launch separately. Godot memory counters exclude Android process PSS and some GPU/driver memory: pair them with `memory.txt`. Debug/Perfetto instrumentation can cost performance; a release template is still required for final performance acceptance.

Use a stable 60 FPS as the initial S23 target, with combat p95 near one 60 Hz frame and p99 below 33.4ms after loading. Investigate persistent dips, long foreground stalls, rising process memory across repeated runs, rendering errors, thermal decline or missed taps. These are test targets, not measured phone results. Record brightness, phone resolution/refresh mode and elapsed play time when comparing runs.

Pause/resume must retain the combat Pause screen until explicitly resumed. Permanent progress must survive app relaunch. The game does not yet serialize a live expedition for process-death resumption; killing Android's process during combat is not expected to restore that in-progress expedition. This remains documented release debt.
