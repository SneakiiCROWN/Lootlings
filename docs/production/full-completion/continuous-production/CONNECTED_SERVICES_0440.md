# Lootlings 0.4.40: Forge, Archive, dialogue and expeditions

Continued the live project from `9e8eb45`. Existing accepted art, canonical identities, gameplay prices/statistics, saves, title music and branding were preserved. This is a connected service-route polish milestone, not a claim of full-game completion.

## Player-facing improvements

- **Weapon Forge:** owned weapon and recipe selections now visibly highlight the actual inspected entry and clear the previous highlight. Disabled actions explain missing Gold/Scrap, full Stash, completed evolution or unavailable evolution. The established two-step confirmation and all prices remain unchanged.
- **Blueprints and regional bounties:** action labels fit the footer and identify missing fragments/materials/seals, full Stash or remaining bounty progress. A successful craft's delivery message now survives rebuilding the selected recipe. Previously that rebuild replaced the message with the recipe description.
- **Archive:** Mastery and Field discoveries show distinct records instead of repeating the same mixed dump. Discoveries use readable encounter names and sorted entries, without internal colon-separated identifiers. Empty collections explain how to begin. The character record now includes all seven canonical Lootlings alongside the existing Wanderer records. Existing approved mascot and armour artwork replaces generic category symbols. Unavailable crafting controls are removed from this read-only screen.
- **Dialogue and NPC service flow:** Patch's Hub/Shop conversation opens Shop; his Forge conversation retains Forge access. Names, canonical portrait panels and dialogue personalities remain unchanged. A subtle blocking veil prevents mouse clicks from activating the world behind the deliberate dialogue panel, matching the existing touch boundary.
- **Expeditions:** locked tiers show their required rank. Locked region cards can be inspected, explain the preceding region requirement, and keep Depart disabled. Region details claim mouse and touch input; Back/close clears the veil and restores the list. No locked region can be entered and no unlock rule changed.
- **Audio:** Archive selections and Field Notes page navigation use the existing licensed recorded page sample through a new UI-bus alias. They follow UI volume rather than environmental ambience volume. The source sample/licence and existing Hub ambience remain intact. No new music or sound recording is claimed.
- **Inventory return:** tested actual crafted weapons and blueprint gear arriving in Stash after departure/return. Existing reward and comparison presentation from 0.4.39 is retained.

## Exact implementation files

`hideout_ui.gd`, `expedition_progress.gd`, `audio_manager.gd`, `export_presets.cfg`.

The runtime-built controls remain part of the existing `main.tscn` game; that scene was not replaced. Generated integration/registry snapshots were refreshed from the actual modules. New fixtures: `tests/connected_services_native_qa.gd`, `exported_connected_services_fixture.gd` and `exported_connected_mouse_fixture.gd`. The preexisting modified `project.godot` and owner-supplied untracked references are preserved outside this checkpoint.

## Tests and evidence

- Actual compiled Windows PCK, using the matching official Godot 4.7.2 engine, passed the connected service route at **1080×2340**, **1200×1920** and **1920×1080**. Tests covered recipe selection, two-step craft, exact currency debit, blueprint material/seal debit and delivery message, distinct Archive records, all-seven-character lore, UI audio source/bus, Patch's Shop link, locked region inspection, blocked underlying taps, Back, departure and Stash return. All test saves were isolated.
- Actual mouse-button events in the final compiled pack passed dialogue/world blocking, Shop navigation, region/list blocking, Back cleanup and available-region selection at desktop resolution.
- `phase4_qa`, `completion_economy_qa`, `audio_production_qa` and `save_recovery_qa` passed. Master integration and canon registry validation passed. The broader earlier player-loop fixture was run against the new pack to check retained Home/Hub/Shop/Stash/Shrine/Spinner/combat/perk/loot/result return routes.
- Native exported screenshots are retained in `connected-services-0440/`, with logs, build hashes and actual resource checks in `connected-services-0440-evidence/`.
- Actual Windows icon resources and Android launcher/adaptive/monochrome/splash resources match the previously approved installed branding. The title music hash remains `7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7`. Existing licensed audio manifests and accepted art are packaged by the Android builder.

Automated external-script navigation uses the PCK with the official engine; the Windows GUI executable wrapper ignores that script option. Android is a signed arm64 debug candidate, **not physically tested on the S23**. Device listening, sustained performance, launcher behavior and physical touch review remain outstanding.

## Production ledger and remaining scope

This checkpoint installs runtime UI/audio-routing improvements and reuses approved artwork. **Zero new body/pose artist files were generated or accepted; zero missing art contracts were closed.** No off-model substitute or new NPC body was installed. Patch/Ilex station panels remain intentional fallbacks. Home furnishings, companions, combat animations, the winged four-legged Hoard Dragon and approved menu remain preserved.

The frozen master backlog remains **3,131 contracts / 8,172 artist files**: playable Lootlings 1,421; Wanderers 855; enemies 288; bosses 356; NPCs 46; support 165. The separate current-launch matrix remains 3,001 missing delivery cells and 165 support packages. Increased live integration records represent UI/lore/audio hookups, not authored-art completion.

The large canonical body/NPC/animation/equipment/environment production queue was not reduced by this milestone and remains unfinished. Wider soundtrack work and additional living-world grounding also remain open. The next substantial family pass should address missing bodies and animation/contact states that visibly affect combat and world encounters, together with reward/merchant variants and native mobile performance; it must retain these tested service routes. This build is more usable, but the full game is not yet commercially finished.
