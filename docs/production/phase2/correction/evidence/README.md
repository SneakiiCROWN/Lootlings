# Native correction evidence — 2026-10-03

These are actual Godot native renderer captures, packaged as WebP without changing pose or layout. Reviewed all 24 actor sheets and all ten phone/tablet montage pages. Full PNGs remain in `.godot_test_data/correction_matrix` and `.godot_test_data/correction_screens/{1080x2316,1200x1600}`. The document subtree is excluded from game import/export by `docs/.gdignore`.

## Actor × weapon × pose

Each sheet has twelve weapon rows (greatsword, greataxe, maul, spear, daggers, claws, bow, crossbow, sling, staff, wand, orb) and nine columns (idle, ready, movement, windup, strike, impact, recovery, hurt, defeat). These are 2,592 sampled render states, not full playthroughs. Impact includes a large enemy's lunge; defeat is a zero-HP body, not a separate authored death sprite. Left-facing states are previews, not current Act I gameplay.

| Actor | Right | Left |
| --- | --- | --- |
| Relic Beast | [Sheet](relic_beast_right.webp) | [Sheet](relic_beast_left.webp) |
| Emberhorn | [Sheet](emberhorn_right.webp) | [Sheet](emberhorn_left.webp) |
| Mosskin | [Sheet](mosskin_right.webp) | [Sheet](mosskin_left.webp) |
| Moonkip | [Sheet](moonkip_right.webp) | [Sheet](moonkip_left.webp) |
| Pebblewyrm | [Sheet](pebblewyrm_right.webp) | [Sheet](pebblewyrm_left.webp) |
| Glimmerfin | [Sheet](glimmerfin_right.webp) | [Sheet](glimmerfin_left.webp) |
| Gloomlet | [Sheet](gloomlet_right.webp) | [Sheet](gloomlet_left.webp) |
| Vault Runner | [Sheet](vault_runner_right.webp) | [Sheet](vault_runner_left.webp) |
| Ashtrail Hunter | [Sheet](ashtrail_hunter_right.webp) | [Sheet](ashtrail_hunter_left.webp) |
| Velvet Astrologer | [Sheet](velvet_astrologer_right.webp) | [Sheet](velvet_astrologer_left.webp) |
| Ruin Warden | [Sheet](ruin_warden_right.webp) | [Sheet](ruin_warden_left.webp) |
| Nightstage Drifter | [Sheet](nightstage_drifter_right.webp) | [Sheet](nightstage_drifter_left.webp) |

[Per-cell status](matrix-report.json) retains explicit support-hand/paired-pose debt: **82 right / 83 left combinations**. Socket transforms do not prove anatomical completion. Moonkip's baked daggers remain visible with other equipped weapons and require approved weaponless art. Gloomlet uses its approved turnaround export; Glimmerfin's current body is already weaponless.

## Main screens

Each layout contains 49 screens, sorted by capture filename and labelled. The last page contains the remaining status-feedback screen. Requested native window dimensions were asserted after window creation.

| Layout | Pages |
| --- | --- |
| S23 proportion, 1080×2316 | [1](screens-1080x2316-1.webp), [2](screens-1080x2316-2.webp), [3](screens-1080x2316-3.webp), [4](screens-1080x2316-4.webp), [5](screens-1080x2316-5.webp) |
| Tablet, 1200×1600 | [1](screens-1200x1600-1.webp), [2](screens-1200x1600-2.webp), [3](screens-1200x1600-3.webp), [4](screens-1200x1600-4.webp), [5](screens-1200x1600-5.webp) |

Some screen fixtures deliberately inject boundary values, mixed build identities, sold offers and long item names. Those captures test presentation; they do not certify those values as a natural run. Every selector, boot/title/profile/settings, hub submenu, normal/miniboss/boss combat, merchant/reward, Pause and result state is included.

Native safe-area overview: [480×854](aspect-480x854.webp), [480×960](aspect-480x960.webp), [480×1040](aspect-480x1040.webp), [480×1066](aspect-480x1066.webp), [1080×2316](aspect-1080x2316.webp), [800×1280](aspect-800x1280.webp), [1200×1600](aspect-1200x1600.webp), [1200×1920](aspect-1200x1920.webp). The layout fixture additionally validates 22 size/cutout cases and ScreenTouch routing.

## Build and fixture provenance

- [Accepted fixture records](../accepted-qa-results.json) include run IDs, durations, native/headless mode and expected corrupt-save diagnostics. Superseded failures are separately explained.
- [Actual APK branding](actual-apk-branding.png), [pixel comparisons](../android-branding-results.json), [compiled navy theme values](../android-splash-resource-check.json), [canonical Gloomlet byte comparison](../android-canonical-resource-check.json), [APK identity](../android-build-report.json).
- Final source fixtures: `tests/presentation_matrix_qa.gd`, `tests/visual_qa_capture.gd`, `tests/mobile_layout_qa.gd`; runner `tools/run_qa.py`; packager `tools/package_correction_evidence.py`.
- Example reproduction: `python tools/run_qa.py --native --only visual_qa_capture --size 1080x2316 --label correction-owner-repeat`; substitute `1200x1600` for tablet. Saves are isolated by the runner.
- Native audio preview remains `.godot_test_data/mobileux-native-audio-mix.wav`. The mix fixture exercises twelve weapon hooks and thirty sound families; waveform checks do not replace subjective device listening.

Physical Android FPS, thermals, driver/cutout behavior, gesture feel and speaker/headphone acceptance remain pending. See [production report](../REPORT.md) for the smallest owner test and current art/release limitations.
