# Phase4E locked canonical extraction and integration — 2026-10-06

Implementation: `7803667b94ee6f0d16f29c995e0f8baa2131e57b`, continuing pushed `60c760c` on `codex/phase4e-gamefeel`. GO for scoped S23 owner review; full Phase4E remains HOLD. No Phase4F or new canon. Separate evidence/status commit follows this report; its exact SHA is reported after commit rather than embedded recursively.

## Delivered

| Measure | Before | After |
|---|---:|---:|
| New locked-source exports | 0 | 73 |
| Exports with shipping runtime routes | 0 | 73 |
| New transparent combat body/view frames | 0 | 10 |
| New exact combat state/facing/family coverage | 0 | 28 |
| Missing playable state/facing/family cells | 2,387 | 2,359 |
| Missing regional/boss/current NPC/merchant cells | 738 | 738 |
| Total missing state/facing/family delivery cells | 3,125 | 3,097 |
| Whole support-family art packages | 165 | 165 (82 right / 83 left) |

The 28 cells comprise 23 right idle-family cells, four genuine left idle-family cells and one Gloomlet right claw anticipation. These cells no longer use TEMP bodies in those exact phases. No complete actor or support-family package is falsely closed by partial idles. The expanded 3,097 count is a different, explicit unit from the old 165 whole-family count; it is not a demand for 3,097 unique illustrations. Compatible frames can serve several validated families/states. Existing 205 supported state cells and 246 original manifest rows are preserved.

Production assets: [source inventory and restrictions](../../../../art/production/phase4e/README.md), `art/production/phase4e/{lootlings,weapons,ui/expressions,hud}`. [Exact source crops/hashes](../../../../art/production/phase4e/extraction_manifest.json), [actual phase/palm/view routing](../../../../art/production/phase4e/runtime_manifest.json), [remaining delivery manifest](MISSING_ART_MANIFEST.json), [native gallery](GALLERY.md).

Source crops retain original RGB and silhouettes. Only alpha changes, plus uniform body fitting into 512×512 canvases. Six actors have eight original expression portraits each; painted portrait backgrounds remain intentionally opaque. Twelve original weapon-family icons replace inventory/merchant icons, while actual held/projectile art is preserved. Fire/Lightning/Rune glyphs use the compatible approved bible elements. One original dagger icon lost its second disconnected blade during an early candidate mask; final extraction retains both blades and native Gear evidence verifies the pair.

Body eligibility is phase/view/family-specific and existing good authored heavy/bow/staff poses take precedence. Moonkip's original blades are preserved and duplicated held daggers suppressed only in that baked idle. Other weapons still use existing sockets. Left Emberhorn/Mosskin art is the actual source side view, not a mirror. Right body idles support wand/orb and paired families only where visible hands permit; Mosskin's existing shield restricts pairing. No source idle is substituted for a missing draw/fire/hurt/movement state. Gloomlet uses its original violet Assassin, including the actual crouched anticipation illustration, never the rejected mushroom body.

Native review caught two substantive rendering problems: inherited creature squash distorted extracted proportions, and the crouched texture's local resource reference expired before canvas drawing. New exports render uniformly; the resolver retains textures across frames. The latter follows Godot's [RefCounted resource lifetime](https://docs.godotengine.org/en/stable/classes/class_refcounted.html) and [RenderingServer RID contract](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html): a drawing handle does not retain its Resource. A WeakRef regression and final native screenshots verify the fix.

## Validation and evidence

168 full-resolution native captures at 1080×2340 and 1200×1920, plus 18 navigation contact sheets. Final body session: `phase4e-extraction-retained-native-4e6cced2b6`, 127.32 seconds, exit 0 / zero errors. Additional twelve-family Gear scroll/merchant session: `phase4e-extraction-icons-7a8964605e`, 8.01 seconds, exit 0 / zero errors. Earlier superseded candidate left-TEMP images are excluded from this package, not deleted from raw QA history. Every final screenshot remains linked at full size, JPEG quality94 with chroma subsampling disabled.

Reviewed all seven source-backed right idles, both available left bodies, Gloomlet's claw wind-up and weapon attachment combinations beside current enemies/environment; phone and tablet bounds, seven original selectors, and twelve-family Gear/merchant icons. Captures intentionally include existing TEMP attack/opposite-view fallback states, rather than hiding missing art. Left targets are staged in the native fixture, with forced-facing disabled; this is not an organic full-run or physical S23 validation. Extreme left fixture staging can crop part of an enemy at the viewport edge; it does not establish approval of live lane crossing. Previous broader staging/boss/Wanderer galleries remain preserved.

Focused final regression session `phase4e-extraction-acceptance-2ff245dbd1`: authored poses, canonical integration, 1,152 staging samples, extracted art, mobile gestures, visible UI/reward safety and 144 actor/weapon combinations across 864 facing/phase samples all exit0 / zero errors. Final texture lifetime session `phase4e-extraction-lifetime-final-306822af0b` separately passes. Eight canonical guard tests pass. Frozen-source validator preserves eleven sources, five rejected-board statuses, 246 original pose rows and zero newly approved boss frames. No combat balance, damage, RNG, save schema, reward odds or encounter timing changes.

## Exact remaining blockers

The active replacement queue remains authoritative; [MISSING_ART_MANIFEST.json](MISSING_ART_MANIFEST.json) subtracts actual reusable old/new source coverage. Each remaining cell identifies game ID, requested state/view/family, delivery canvas/RGBA, baseline/pivot contract, support requirement, scale restrictions and canonical identity. Known existing rig READY targets are included. Actual missing source palm/pivot pixels remain OPEN/null: no one can truthfully measure an image which does not exist. Phase-specific source coordinates must accompany the exact authored export; these are not fabricated from concept-board anatomy.

- Moonkip: actual weaponless original hooded rogue, 512×512 RGBA, both views and missing action/support states; no erasure that invents paws.
- Gloomlet and other playable actors: exact remaining release/recovery/hurt/movement/left/support states matching the locked sheets. Idle-to-TEMP action art discontinuity remains visible and is not final quality acceptance.
- Hoard Dragon: existing wingless/coiled purple/obsidian/gold body needs actual continuous-tail redraw, full silhouette, 2048×2048 RGBA both views and named boss states. Current source tail remains REPLACE. Winged handoff bodies are rejected; no crop/squash/FX concealment.
- Wanderers, regional enemies, other bosses and current NPC/merchant activity: no new clean state frames exist in the specified sheets. Retain prior good authored heavy poses and Patch/Ilex/Sera idles, request only missing packages from established identities.
- Separate non-art gates: semantic/cross-store/process-death save acceptance; final perceptual audio/mastering; physical S23 FPS/frame pacing/memory/lifecycle/touch; final owner visual acceptance. Desktop still-frame review does not close these.

All listed sheets were inspected. The class template duplicates Emberhorn source content and is not counted twice. Remaining occluded turnaround hands, baked weapons/VFX, unmapped outfit variants, conflicting Dragon/Moonkip/Gloomlet boards and art-bible labels cannot safely produce missing combat anatomy or new canon. Two newly present raw handoff ZIPs were preserved unopened locally and explicitly ignored; no unapproved archive payload was used.

## Android and S23 retest

Version25 / `0.4.16-phase4e-extracted-canon`, `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-extracted-canon-debug.apk`. Successful export: **139,795,567 bytes**, SHA256 `cc61b64c10a952a5e6501ce1de027c3f059a4833a1e93024d5982863d49151b5`. The receipt is [android-build.json](android-build.json). Signature, arm64, no requested permissions, branded splash, 16KiB alignment, audio license/PCM manifests and byte equality of all 73 extracted imported assets are checked. Device validation remains false. Ten retained 512×512 body textures add roughly 10MiB of uncompressed RGBA backing before engine overhead; only S23 testing can accept actual frame pacing/memory behaviour.

Install over the current debug app without uninstalling or clearing data. Check Relic Beast wand/orb and Gloomlet claws where owned: idle, wind-up, attack, hurt and return; remaining TEMP action transitions are known art debt. Open Gear, scroll the weapon icons, enter/leave merchant and return to Hideout. Background/resume and confirm equipment/save persistence. Report any new white rectangle, distorted body, misplaced weapon or accidental attack/purchase. No manual QA setup or save erasure required.

## Multidisciplinary sign-off

| Discipline | Status | Scope / remaining issue |
|---|---|---|
| DESIGN | issues | Complete presentation remains blocked by action art |
| BALANCE | pass for change scope | No tuning; RNG/cadence preserved, not a new balance audit |
| ECONOMY | pass for change scope | No price/reward/save changes; existing optional flows preserved |
| ROSTER | issues | Seven original Lootlings partially integrated; missing states and Wanderer bodies remain |
| ENEMIES | issues | Canonical regional state packages still missing |
| BOSSES | issues | Hoard Dragon tail and articulated states remain open |
| RNG | pass for change scope | Source/render sampling verified RNG-neutral; no odds changed |
| UI/UX | issues | Native icons/scroll/layout reviewed; physical phone acceptance outstanding |
| NARRATIVE | pass for change scope | Established identities/text preserved; no board-label canon promotion |
| AUDIO | issues | Prior implementation retained; final perceptual/mastering acceptance outstanding |
| MOBILE | issues | Native portrait/tablet and APK pass; physical S23 performance/lifecycle remains |
| QA | issues | Focused native/regressions pass; full owner/device acceptance remains |
| PRODUCTION | issues | Safe separate checkpoints, precise queue; full Phase4E HOLD |
