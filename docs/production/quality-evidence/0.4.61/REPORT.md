# Lootlings 0.4.61 — Issue 6 connected production

Continued the live 0.4.60 project without reset or separate checkout. Preserved owner changes, canonical files, saves, previous builds, branding, all gameplay calculations and the approved title theme. Batch A checkpoint 71f8a74 is pushed; this checkpoint additionally corrects font weight rendering and pack/owner-tab defects discovered in native review.

## Installed, functionally tested and visually reviewed
- Shared locally licensed Nunito Sans body/UI, Cinzel substantial headers and Noto Sans Symbols 2 fallback. Header fitting and full enemy-name wrapping replace lost names. Numeric OpenType axis tags ensure the intended 600/800/650 weights actually render; documented String aliases were ignored by the engine ([upstream report](https://github.com/godotengine/godot/issues/123541)).
- Existing combat emitter upgraded rather than duplicated: resolved amounts, labelled semantic colours, separate gold elemental CRIT accent, target identity aggregation, actor-relative positions, priority replacement, eight recycled receipts / four separated pack lanes. Off/Minimal/Standard/Expressive, Small/Normal/Large, crit emphasis, aggregation and reduced-motion controls are saved and survive restart.
- Quieter gear rows across shared item surfaces; rarity accents, selected gold border/check and distinct keyboard focus remain. Shop/Stash detail frames are restrained and Shop/Forge text is larger. Full comparison/economy logic preserved.
- Canonical HUD portrait masked at render time; no source-art changes. HP text larger, Ward/XP separated, existing health trail preserved.
- START-only title foreground; original accepted ensemble/wordmark unchanged. Profile/character/settings remain in the established Hub/Home/profile flows. Exact approved title theme remains unchanged.
- Extended the same four-tab owner panel: ten real bounded fields, Set/Add/Remove, synchronised numeric input/slider, current values, God ON/OFF, safe item search/no-match and tab scroll reset. No duplicate cheat menu, PIN or networking.
- Optional saved audio mix presets. Opening Settings preserves existing channel values/mutes. Manual adjustment returns to Custom. Attack retains weapon feedback and omits the routine menu click. No music/SFX files replaced.

## Evidence and limits
Seven principal layouts 360×640 through 2560×1440; eight presentation layouts including 3440×1440. Tests cover 30 actual resolved elemental hits per layout, 200 synthetic five-target emitter impacts per layout, real three-enemy combat, all semantic feedback types, saved settings/restart, nested Back and backdrop touch fencing. Existing encounter architecture remains capped at three enemies. Simulated phone cutout is tested.

Existing front-of-house and all four-slot gear/economy regressions passed earlier; final owner regression passed three layouts including real touch commands, original unlock/SHH/sandbox reload and byte-identical normal save stores. FINAL_SOURCE_QA.json records the final changed-code checks. Representative PNGs were actually inspected. Runtime defects found and corrected: ignored font weight axes, critical-accent collisions, incoming text across faces, packed-hit crowding, atlas portrait mask coordinates and retained owner-tab scroll.

Desktop warmed 120-frame three-enemy samples follow 120 warmup frames. See BATCH_D1_NATIVE.json for measured per-layout process/frame timing. Desktop FPS is not Android performance acceptance. Physical S23 is deferred, without blocking production. Professional artistic/full-player-experience acceptance remains open; no entire screen/game is declared finished merely because tests pass.

## Exact remaining work
- Batch A: owner/professional reading acceptance, broader long-name/localisation extremes and global adjustable UI legibility scaling; actual five-enemy scenes are not implemented by this existing three-enemy game architecture.
- Batch B: full merchant/dialogue/NPC counter composition, finer empty/disabled states, exhaustive screen/content/device visual acceptance and existing world/animation defects.
- Batch C: additional precise owner progression fields (e.g. Sigils/XP/wave), broader slider/search touch journeys and title artistic acceptance. Existing preset wave/Sigil/XP commands remain working.
- Batch D1: global graphics/FX and UI text-scaling options, haptic preference/device validation and professional mix/listening acceptance.
- Batch D2: saved contextual onboarding across all real player routes.
- Batch D3: offline backup/import/export and expanded migrations, fault injection, restart/economy matrices beyond the retained 0.4.60 recovery coverage.
- Batch D4: whole campaign/ending/postgame tests and any missing production content. Wider Issue 5 animation/canon/world backlog remains active.

Art contracts: 0 new closures; 517 / 3,274 installed, 2,757 outstanding. Artist requirements remain separate: 1,317 / 8,495 installed; 7,178 outstanding. Three new licensed font files are not character-frame contracts. No new sprite art or audio recordings; no rejected artwork installed. Whole-game professional status remains HOLD.

Build packaging and exact exported-code evidence are added after the source checkpoint. 0.4.60 rollback binaries are never overwritten. Source project.godot owner patch remains uncommitted and is preserved alongside delivery evidence.
