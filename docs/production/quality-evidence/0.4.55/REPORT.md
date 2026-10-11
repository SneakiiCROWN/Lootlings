# 0.4.55 connected combat, merchant and equipment readability

Installed and verified in the live project. Source milestone 5792f50 is pushed; final corrected Windows and regular/owner Android candidates are exported and verified. Five fixtures pass against the exact final compiled game pack. The actual Windows executable started successfully using isolated saves.

Combat receipts now label normal/critical/heavy and elemental hits, burn/poison ticks, actual capped attack lifesteal and poison siphon, Ward absorption, armour mitigation and HP damage. Repeated same-kind hits within 0.26 seconds aggregate; numbers retain target serials, have at most three slots per actor/eight overall and appear below faces/nameplates. This is presentation only: original damage, hitboxes, RNG, loot and economy are preserved. The final fade is brief and reduced-motion disables drift. This does not yet cover every special-proc or healing source.

XP uses compact large totals and fitted text beside the Ward lane. Pack Peddler uses the existing canonical body keyframes with 0.18-second transitions and a brief inspection reaction. These are transitions between keyframes, not a fluid animation family. Native review found a cramped comparison panel. Its larger view uses shorter offer rows while keeping item art readable and actions away from the former Attack area. Initial geometry failed the touch regression and was corrected before accepting any export.

Shared item descriptions in shops, stash, Forge and reward details retain fractional bonuses and omit zero-effect entries. Attack-delay comparison describes the actual delay modifier rather than claiming a made-up attack-rate change. Dialogue instructions now name Lootcoins and Loot Diamonds correctly, direct players to the Shop station and separate Crownroot/Relic Engine from Gravebloom/Forge. Distinct existing voices and lore remain; this is not the whole-game writing completion.

New generated art: 0. New accepted runtime artwork: 0; existing approved Pack Peddler assets reused. Exact art closures: 0. Remaining contracts: 2757. The 55 sampled player pose fallbacks, complete animation continuity and professional artistic acceptance remain open. Original title music, branding, companions, owner reference packs, owner project.godot edits and saves are preserved.

Targeted accounting, spinner, free-supply/migration and economy tests pass. Native combat/merchant screenshots cover 1080x2340, 1600x2560 and 1920x1080. Full physical S23 gameplay remains deferred. Perk balance remains unaccepted; this pass makes no new balance claim.

During development, a string arithmetic grouping error was fixed before acceptance, a fractional-format fixture caught signed values still rounding to zero, and the old feedback fixture expected six spinner tiers instead of the existing seven. The fixture now checks the actual tier count without changing spinner behavior. Earlier failed logs remain recoverable in .godot_test_data; only final evidence grants acceptance.

Changed gameplay/presentation files: combat_numbers.gd (new), lootling.gd, item_catalog.gd, travelling_merchant_view.gd, dialogue_director.gd and contextual_dialogue.gd. Export presets and targeted tests accompany the existing master dashboard. No canonical source image was edited.

Outstanding next connected work: verify additional special-proc/heal receipts and enemy/boss warnings, expand Forge/Stash/shared-dialogue UX, improve spinner audiovisual review, finish missing exact weapon-contact/animation families and expand deterministic late-game balance cohorts. No broad re-audit or accepted-art regeneration is needed.

## Final delivery

Windows: builds/windows/Lootlings-0.4.55-readability-candidate.exe and adjacent .pck. File/product version 0.4.55.0. Actual PE icons at all six exported sizes are pixel-identical to corresponding original approved ICO frames. Executable startup passed; route fixtures use the exact PCK in the desktop Godot engine, as the export template does not permit external script overrides.

Regular Android: builds/android/Lootlings-0.4.55-normal-candidate-debug.apk, com.sneakiicrown.lootlings. Owner: builds/android/Lootlings-0.4.55-owner-test-debug.apk, com.sneakiicrown.lootlings.owner. Both version code 66, signed debug arm64, 16-KB aligned, offline permission checks, original imported branding and licensed audio verified. Owner feature excluded from regular app; distinct app storage and existing no-PIN owner sandbox remain. Android-device gameplay is not tested.

Compiled fixtures: damage/mitigation/healing accounting and notice independence; native combat/merchant review at three sizes; touch-transition ownership; no-PIN secret access and save isolation; equipment feedback and actor contact routes. See COMPILED_NATIVE_RESULTS.json, native-compiled/ and native-routes/. No new whole-game balance or professional acceptance claim. Final notice correction prevents existing guard/proc messages being suppressed by new typed receipts.

Title music remains byte-identical. Owner project.godot remains 4 additions/11 deletions, unstaged. Owner references and unrelated local changes are preserved. DELIVERY.json records exact build sizes, hashes, source fingerprints and package evidence.
