# 0.4.55 connected combat, merchant and equipment readability

Installed in the live project. Final exports and compiled acceptance are pending.

Combat receipts now label normal/critical/heavy and elemental hits, burn/poison ticks, actual capped attack lifesteal, Ward absorption, armour mitigation and HP damage. Repeated same-kind hits within 0.26 seconds aggregate; numbers retain target serials, have at most three slots per actor/eight overall and appear below faces/nameplates. This is presentation only: original damage, hitboxes, RNG, loot and economy are preserved. The final fade is brief and reduced-motion disables drift. This does not yet cover every special-proc or healing source.

XP uses compact large totals and fitted text beside the Ward lane. Pack Peddler uses the existing canonical body keyframes with 0.18-second transitions and a brief inspection reaction. These are transitions between keyframes, not a fluid animation family. Native review found a cramped comparison panel. Its larger view uses shorter offer rows while keeping item art readable and actions away from the former Attack area. Initial geometry failed the touch regression and was corrected before accepting any export.

Shared item descriptions in shops, stash, Forge and reward details retain fractional bonuses and omit zero-effect entries. Attack-delay comparison describes the actual delay modifier rather than claiming a made-up attack-rate change. Dialogue instructions now name Lootcoins and Loot Diamonds correctly, direct players to the Shop station and separate Crownroot/Relic Engine from Gravebloom/Forge. Distinct existing voices and lore remain; this is not the whole-game writing completion.

New generated art: 0. New accepted runtime artwork: 0; existing approved Pack Peddler assets reused. Exact art closures: 0. Remaining contracts: 2757. The 55 sampled player pose fallbacks, complete animation continuity and professional artistic acceptance remain open. Original title music, branding, companions, owner reference packs, owner project.godot edits and saves are preserved.

Targeted accounting, spinner, free-supply/migration and economy tests pass. Native combat/merchant screenshots cover 1080x2340, 1600x2560 and 1920x1080. Full physical S23 gameplay remains deferred. Perk balance remains unaccepted; this pass makes no new balance claim.

During development, a string arithmetic grouping error was fixed before acceptance, a fractional-format fixture caught signed values still rounding to zero, and the old feedback fixture expected six spinner tiers instead of the existing seven. The fixture now checks the actual tier count without changing spinner behavior. Earlier failed logs remain recoverable in .godot_test_data; only final evidence grants acceptance.

Changed gameplay/presentation files: combat_numbers.gd (new), lootling.gd, item_catalog.gd, travelling_merchant_view.gd, dialogue_director.gd and contextual_dialogue.gd. Export presets and targeted tests accompany the existing master dashboard. No canonical source image was edited.

Outstanding next connected work: verify additional special-proc/heal receipts and enemy/boss warnings, expand Forge/Stash/shared-dialogue UX, improve spinner audiovisual review, finish missing exact weapon-contact/animation families and expand deterministic late-game balance cohorts. No broad re-audit or accepted-art regeneration is needed.
