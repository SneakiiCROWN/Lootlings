# Human playtest follow-up delivery

Implementation/evidence checkpoint: `0981963` — Polish S23 hub and combat flow with measured premium sinks and audio trims.

Branch: `codex/phase2-vertical-slice`. Started clean at `fccd15b`. Final documentation checkpoint follows this file; obtain its exact identity with `git log -1`. This documentation-only checkpoint does not alter the APK source.

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-humanqa-debug.apk`.

Version: **7 / 0.2.2-humanqa**. Size: **131,821,173 bytes**.

SHA-256: `d93d634e196d96deaea4a8f73ac29abb7d87dbae552522b41bdab0521feafa0b`.

[Package verification](android-build.json): official Godot 4.7.2 debug template, signed arm64, minimum SDK 24, target SDK 36, 16 KiB ZIP alignment, offline/no permissions; current imported pose/bow hashes and all 329 PCM assets/license manifests verified. Existing version-6 APK remains available. Install as an update, not an uninstall, to test persistence.

ADB inventory on delivery: no devices attached. No physical installation, listening, thermals or lifecycle acceptance is claimed. [Report and three-step S23 retest](REPORT.md).

Focused reproduction (guarded disposable saves):

```powershell
python tools/run_qa.py --only human_scrip_runs mobile_gesture_qa rc_reward_qa save_recovery_qa --label humanqa-final
python tools/run_qa.py --native --only human_native_qa mobile_layout_qa --size 1080x2316 --label humanqa-native-final
python tools/run_qa.py --native --only human_pressure_qa --size 1080x2316 --label humanqa-pressure-final
$env:LOOTLINGS_AUDIO_LABEL='final-complete'
python tools/run_qa.py --native --only human_audio_qa --size 1080x2316 --label humanqa-audio-final-complete
python tools/build_android.py --output builds/android/Lootlings-humanqa-debug.apk
```

Use the workspace’s configured Python/Godot executables if they are not on PATH. Audio baseline reconstruction uses label `baseline-complete`; all other labels use shipped gains. The baseline comparison is already frozen; do not overwrite its evidence to save a repeat run. Unchanged matrices/labs are referenced through reuse.json.
