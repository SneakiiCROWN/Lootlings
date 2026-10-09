# Lootlings 0.4.39: connected player-route polish

Continued the live project from `30a0bd2` on `codex/phase4e-gamefeel`. This is a playable polish milestone, not completion of the entire game. Existing owner references, uncommitted project settings, saves, stats, economy, title music, branding and canonical identities were preserved.

## What changed for players

- **Hub → Shop:** the whole visible merchant cart is a comfortable Shop target. Service captions identify Sera/Upgrades, Patch/Shop and Ilex/Archive. Existing dialogue remains separately accessible. No extra directory or duplicate service dock was introduced.
- **Shop → Stash → upgrades:** three wide offer rows replace cramped columns. Item pictures, rarity, cost and selected state are clearer. The comparison panel leads with effects and equipped comparison, with lore available by scrolling. The selected gold frame now survives style duplication. Repeated refreshes remove old item-picture nodes immediately instead of accumulating overlapping icons. Stash names have more room, and owned gear explicitly says it is free to equip.
- **Affordability and rewards:** Buy and upgrade controls explain missing Scrap, Gold or shards, full storage and pending delivery. Increased incoming damage correctly appears as a drawback. Equipping into an empty slot no longer falsely describes every effect as a gain. Named approved rune art takes priority over generic elemental symbols.
- **Relic Engine restored for desktop mouse:** the world-blocking dimmer was later in the scene tree than the visible controls, intercepting ordinary clicks. Moving it behind the machine restores Spin and return clicks while preserving modal input blocking. Earned spins debit once and do not charge currency. An empty Hub bank explains how to earn spins instead of presenting a misleading paid-spin cost.
- **Return flow and text:** public service screens return to **Hub**, not the separate personal Home. Result text also identifies the Hub as the place for stored spins. Existing private Home, furnishing, companion and customization routes were preserved.
- **Combat/world presentation:** removed a visible cyan ground-guide line. Missing character-body fallbacks use an intentional framed portrait with readable character and weapon labels; production/debug labels are hidden unless the developer UI is explicitly enabled. These portraits remain fallbacks, not completed body art.

The existing HP, Ward and XP layout was inspected in native captures and retained. This pass does not claim a new HUD redesign, new Home furnishing art, or new NPC body installation.

## Exact implementation files

- `hideout_ui.gd`: Shop layout, descriptions, affordability, Stash text, return labels, thumbnail size and safe refresh.
- `lootlings_ui.gd`: approved rune priority and preservation of script-backed frame fields when duplicating styles.
- `hub_navigation.gd`: cart interaction region and named service captions.
- `retention_runtime.gd`: mouse/modal ordering, earned-bank explanations and correct return labels.
- `lootling.gd`: truthful equipment comparisons and removal of the debug-looking ground line.
- `creature_renderer.gd`: explicit portrait fallback framing and player-readable text.
- `export_presets.cfg`: Android 0.4.39-player-polish/code 48; Windows 0.4.39.0 metadata.

`main.tscn` uses these runtime modules and was not replaced. The preexisting modified `project.godot` is preserved outside this checkpoint.

## Gameplay art integrated before the priority correction

Mossmaw and Glasswing each gained six exact combat states in both directions: idle, role windup, role commit, hurt, recovery and defeat. **24 runtime cells / 48 artist files** are installed and selected in actual Godot combat, replacing missing presentation for those states. Their selectors, attack damage and contact behavior were tested without changing gameplay statistics or random-number selection.

Canon authority was the named panels in `art/reference/phase4e_handoff/chatgpt_generated_candidates/regional_candidates/batch01_verdant_marshes.png`, SHA-256 `01b76b9530c4854da4d44a2978728754c9538a8a170dc2642bb3d2d756737b78`. Two sheets were produced using the built-in ImageGen workflow; source sheets and exact prompts are retained under `art/source/mass_world_combat/enemies/`. Mixed facings in the first sheet were mapped to their real direction, then the complementary sheet supplied the missing cells. No mirrored substitutes or reference-board body crops were installed. Alpha was checked over an opaque Godot background and in native combat; transparent pixels' hidden RGB was not mistaken for a matte defect.

No new asset was rejected in this accepted pair. Existing rejected Dragon candidates remain quarantined. The approved winged, four-legged Hoard Dragon and all six companion identities were unchanged. Dedicated missing locomotion, action variants, grips, bodies and animation contracts remain open.

## Verification and its limits

- Native exported Windows **PCK**, using the matching official Godot 4.7.2 engine: connected Home → Hub → cart Shop → purchase → Stash → Shrine → earned Spinner → combat → perk → loot → results → Hub. Passed at **1080×2340**, **1200×1920** and **1920×1080**.
- Touch checks covered single purchase/payout, cleared old selection, preserved selected frame, repeated icon refresh, missing-funds explanations, modal combat-input isolation and earned-spin reward/return. The approved title track hash was checked in the compiled pack.
- Real mouse-button events passed cart Shop, item inspection, earned Spin and Hub return at desktop resolution. The fixture waits for the normal entry transition before clicking. A separate source-native mouse test also passed after the dimmer fix.
- Transaction and save-recovery checks passed: distribution/pity, all paid tiers, old save compatibility, duplicate delivery recovery, debit failure rollback and lifecycle recovery. Intentionally corrupt test saves remained isolated from owner saves.
- Mossmaw/Glasswing native review passed all 24 states/facings, actual damage/contact and selector preservation at the three sizes. Enemy validation reports 35 accepted exact cells total, zero mirrors and zero board-body substitutes.
- Actual APK resources match the approved launcher, adaptive, monochrome and splash assets. Actual Windows PE icons match the approved icon at 16–256 pixels. Approved installed sources: `art/ui/brand/lootlings_icon.png`, `android_foreground.png`, `android_background.png`, `android_monochrome.png`. Existing full wordmark/title artwork is unchanged.
- APK inspection confirms all 35 enemy imports match local accepted imports, including the 24 new cells. Existing licensed scores and audio records are included. No new soundtrack is claimed. The two previously installed station activity effects are now included in this Android candidate.
- The exact approved title music remains `art/audio/production/music/title.ogg`, SHA-256 `7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7`.

The exported executable started with the expected renderer; automated external-fixture routing used its PCK with the official engine because the GUI executable wrapper ignores `-s`. This is not a physical-device test. **S23 launcher, touch, performance and listening review are still pending.** The APK is a signed debug candidate, not a final store release. Native screenshots are in `player-route-0439/`; evidence logs and actual resource verification are in `player-route-0439-evidence/`.

## Outstanding work and next broad pass

The frozen master specification has **3,131 contracts / 8,172 artist files outstanding**, reduced by 24/48 in this run. Remaining contracts: playable Lootlings 1,421; Wanderers 855; enemies 288; bosses 356; NPCs 46; support packages 165. This count excludes menu polish and retained existing artwork. Current launch-delivery matrix separately records 3,001 missing cells plus 165 support packages; those scopes must not be added to or substituted for the frozen count.

The next connected pass is **Forge → Archive/dialogue → expedition/region selection → reward and inventory variants**, checking actual layouts and input, extending the same item/selection clarity, and restoring any misleading or dead routes encountered. Missing bodies and animations should be authored only where they visibly block those routes. Home/Hub remain open to further world-grounding refinement; no claim that either is commercially finished. Wider audio transitions, physical mobile performance and remaining canonical gameplay families also remain outstanding.

Build hashes, exported-resource checks and isolated QA evidence are retained alongside this report. Checkpoint/push status is reported separately after saving the verified files.
