# Current audio authority —0.4.75 reconciliation

The active music bank is `art/audio/production/music/*.ogg`, selected before production WAV and the old procedural fallback in `audio_manager.gd`. The **owner-approved title theme** is Vitalezzz's **The Ancient Legend**, `art/audio/production/music/title.ogg`; SHA256 `7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7`. This reconciliation does not replace, regenerate, remix or retune that recording.

The prior claim “no external audio files” is historical and no longer describes the installed game. Current provenance authorities are `art/audio/production/LICENSES.txt`, `sources.json`, `score_sources.json`, their retained source files and `ANNOUNCEMENT_AUDIO_PROVENANCE.json`. CC0 classifications below are the existing individual source records, not newly invented permissions. The separately recorded YOU WON announcement has its existing service-rights/source record; it is not labelled CC0 merely because music and recorded SFX are.

| Cue | Recorded creator/title | Installed file | Recorded licence |
|---|---|---|---|
| home | Joth — jrpg-piano | `art/audio/production/music/home.ogg` | CC0-1.0 |
| title | Vitalezzz — the-ancient-legend | `art/audio/production/music/title.ogg` | CC0-1.0 |
| hideout | Vitalezzz — arcanum | `art/audio/production/music/hideout.ogg` | CC0-1.0 |
| outer_ruins | Vitalezzz — adventurers-path | `art/audio/production/music/outer_ruins.ogg` | CC0-1.0 |
| salvage_warrens | Vitalezzz — chasing-memories | `art/audio/production/music/salvage_warrens.ogg` | CC0-1.0 |
| hoard_depths | Vitalezzz — outworld | `art/audio/production/music/hoard_depths.ogg` | CC0-1.0 |
| boss | Vitalezzz — eclipse-legion | `art/audio/production/music/boss.ogg` | CC0-1.0 |
| mossglass_wilds | nene — Beautiful Forest [Orchestra] | `art/audio/production/music/mossglass_wilds.ogg` | CC0-1.0 |
| frostbell_hollows | Karate Studios — Ice Village | `art/audio/production/music/frostbell_hollows.ogg` | CC0-1.0 |
| nullglass_expanse | Vitalezzz — Claimed by the Void | `art/audio/production/music/nullglass_expanse.ogg` | CC0-1.0 |
| sunken_gearworks | Vitalezzz — Inevitable | `art/audio/production/music/sunken_gearworks.ogg` | CC0-1.0 |

All11 score outputs and11 retained score sources match their recorded hashes; all461 production-bank outputs match `sources.json`. That verification establishes identity/integrity, not human mastering or phone-speaker quality. Recorded Kenney/EmoPreben/Darsycho/Kerzoven sources and original ambience/noise layers retain their individual attribution and processing records. No new downloads, licence substitutions or musical identity changes were made in this pass.

Bounded voices, crossfades, category settings, fallback routing, limiter and event-bank validation remain in the existing audio manager. Human listening/mastering, fatigue, loop seams, real device mix/performance and final commercial acceptance remain pending. Earlier signal measurements below are historical observations, not proof of today's audible quality.

## Historical pre-production record — superseded where it describes current assets

> **2026-10-02 audit authority:** [AUDIT_REPORT.md](AUDIT_REPORT.md). Every current WAV is classified BETA procedural placeholder; no new external license was introduced by this audit. Native mix QA is objective signal testing, not human listening/mastering approval. Final production cues must preserve individual creator/license/source records.

# Lootlings Audio Licences

## Current checkpoint

No external audio files are included.

2026-10-02 production preparation: optional imported short PCM WAV banks/per-existing-cue score hooks are ready; none supplied/enabled. Original audio below remains. Delivery paths, complete anti-fatigue banks, pending routing and commercial-safe licensing/output QA: `AUDIO_PRODUCTION_MANIFEST.md`. Native fallback: 221,184 frames, -0.80dBFS peak/-20.71dBFS RMS, limiter active; not screen-recorded Windows output/LUFS.

The Visual / Audio Rescue checkpoint keeps that provenance unchanged. It brings high-value combat, chest, rarity and reward events forward in the existing bounded voice pools, keeps routine UI/ambient events behind them, and adds a real Master-bus limiter with conservative headroom. No third-party samples, copied game sounds, or newly downloaded music were introduced.

All current audio is original project procedural synthesis. Event feedback remains generated once at startup from project-authored tone, harmonic, pseudo-noise, pitch-sweep, envelope, and controlled timbre-variant combinations. The eight location/result score cues are project-generated 48-second A/variation/B/bridge/return phrases prebaked to WAV so entering a location does not synthesize audio on the gameplay thread. They have no third-party creator, source URL, attribution, or external licence dependency and remain production-direction placeholders rather than final mastered signature music.

The character-feel checkpoint adds an original low chest-wind-up cue plus a short player-local Music-player duck/restore envelope for the reward micro-silence. It creates no new external asset or licence dependency, does not alter saved bus volumes/mutes, and restores the active music voice smoothly after the reveal.

| Filename | Purpose | Creator/source | Licence | Date acquired | Status |
|---|---|---|---|---|---|
| Runtime-generated (no file) | Layered UI, four weapon-family, enemy-family, combat, loot, rarity, chest, Core, boss, victory/defeat feedback with bounded non-repeating frequent-event variants | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/title.wav` | 48-second mystery/treasure invitation score | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/hideout.wav` | 48-second warm scavenger-home score | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/outer_ruins.wav` | 48-second magical adventure/discovery score | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/salvage_warrens.wav` | 48-second warm mechanical/scavenger score | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/hoard_depths.wav` | 48-second ancient treasure/deeper mystery score | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/boss.wav` | 48-second related urgent boss motif | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/victory.wav` | 48-second brighter resolving phrase used for result ambience | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |
| `art/audio/music/defeat.wav` | 48-second restrained, cheeky low phrase used for result ambience | Lootlings project procedural synthesis | Original project work | 2026-09-30 | Production-direction placeholder |

Any future audio addition must record filename, creator, direct source, exact commercial-use licence, acquisition date, attribution requirements, modifications, and placeholder/final status before entering the repository.

## Repeatable rescue audio/output QA

The rescue keeps the same original SFX and eight score WAVs. Routine voices are quieter relative to key hit/reward/chest/boss events; the music player has +1 dB body (including duck recovery). A Master limiter uses a -0.8 dB ceiling to contain overlapping transients. All five saved bus levels and mute flags remain authoritative; no player preferences are reset.

Run destructive regression fixtures and visual/audio harnesses with isolated test data, never a player's normal APPDATA. In a fresh PowerShell process from this repository:

```powershell
$env:APPDATA = Join-Path (Get-Location) '.godot_test_data\rescue_audio_profile'
New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null
& 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe' --path . --resolution 480x854 -s res://tests/audio_mix_qa.gd
```

The harness applies shipped defaults in memory only, plays combat/pickup/chest/boss cues against Outer Ruins music, and measures post-Master samples. Final native OpenGL result: 223,232 frames, -0.80 dBFS peak, -20.63 dBFS RMS (repeat captures -20.87 to -20.63 due to controlled timbre/pitch variation), limiter active, no script/runtime errors. This is not integrated LUFS and does not measure Windows/device/recording attenuation.

For actual player-path QA: launch normally, inspect saved Settings/mutes, note Windows device/app-mixer levels, record a representative ordinary combat → merchant → Hoard reveal sequence using the same recorder/output device as the human benchmark, and compare loudness/peaks on that recording. Listen on phone speaker/headphones for fatigue and reward separation. Do not compensate for recorder attenuation by globally raising every game bus. Human listening and Windows loopback/recorded-output mastering remain outstanding; no claim of final mastered audio is made.

## Original 0.4.50 Relic Spinner sound design

Five PCM16 sound masters (`spinner_activate`, `spinner_tick`, `spinner_catch`, `spinner_stop`, `spinner_fanfare`) are original deterministic procedural project audio, authored by `tools/build_spinner_sound_bank.py`. No third-party recordings, voice models, franchise assets or samples are used. Commercial game use is permitted; no third-party attribution is required. Exact file hashes, levels and provenance are recorded in `docs/production/quality-evidence/0.4.50/SPINNER_AUDIO_PROVENANCE.json`. These are musical/Foley cues, not the requested spoken announcement. The approved title track is untouched.

0.4.50 continuation: original YOU WON! voice generated with Runway Pip preset (not a cloned person). Commercial use permitted: https://help.runwayml.com/hc/en-us/articles/21668707517587-Can-I-use-the-content-I-made-in-Runway-for-commercial-purposes . Source retained in voice_sources; task, processing and hashes in ANNOUNCEMENT_AUDIO_PROVENANCE.json. New 1.9s jackpot fanfare is an original procedural project composition. Listening/professional mix acceptance remains pending.
