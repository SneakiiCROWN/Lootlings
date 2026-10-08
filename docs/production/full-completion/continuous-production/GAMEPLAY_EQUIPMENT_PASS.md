# Gameplay and equipment pass — 0.4.35

Implemented in the live project C:/Users/Snkii/Documents/lootlings. main.tscn remains the existing scene; no replacement project was created.

## Actual game improvements

- HUD: explicit XP/current requirement/next level, separate Ward meter, outlined readable health numbers, steady low-health cue. Player, solo enemy, enemy pack and boss meters share the clearer damage-loss trail.
- Finds/perks/merchant: consistent restrained rarity cards with visibly distinct selected and focused states.
- Stash/comparison: dedicated armour art, icon-safe text spacing, selected row stays highlighted, old selection clears and closing clears it. Native QA caught and corrected a missing nine-patch texture during style duplication.
- Shrine: existing canonical character grounded by the measured opaque feet baseline and a contact shadow; subtle breathing remains, reduced motion respected.
- Shop: canonical Patch presented as an intentional framed service plaque; duplicate cart/visitor overlap removed from this panel. Existing Hub station and all services retained.
- Drops: longer labels fit their available width; reduced motion prevents item bobbing.

## Installed art and rejected corrections

Twelve Armour inventory IDs have dedicated runtime icons instead of a shared generic shield: Mossguard Harness, Ironpaw Plate, Ruinweave Coat, Dragon-Scale Patch, Patchplate Vest, Coin-Stitch Coat, Thorn Receipt, Last Page, Second Skin, Warden Warranty, Scarlet Margin and Keeper Coat.

Counts: 12 static inventory art cells; 24 PNG/sidecar artist files; 2 retained authored source sheets. Two initial cells (Dragon-Scale Patch and Second Skin) were rejected and corrected before installation. Zero new body/outfit/pose cells; zero frozen master contracts closed. New playable/Wanderer/enemy/boss/NPC/companion/Home art cells in this pass: zero. Previously accepted artwork remains installed.

The approved gear compendium supplied equipment style; dedicated character/companion/logo authorities remain unchanged. Every accepted icon has provenance, dimensions, real RGBA, source region/hash and authority hash. Native galleries checked all twelve at full and 40-unit size on three viewports.

## Changed files

Runtime: lootling.gd, lootlings_ui.gd, hideout_ui.gd, pickup_presentation.gd. Build version: export_presets.cfg.

Art: art/production/phase4e/items/armour_inventory_v1/ (12 PNG, 12 JSON sidecars, 12 Godot import descriptors); art/source/continuous_armour/ (two source PNGs, generation/correction prompts and notes). Source authority: art/reference/canonical/phase2_master/lootlings_fantasy_gear_compendium.png.

QA: tests/gameplay_family_native_qa.gd and tests/armour_family_native_qa.gd with their UIDs; this continuous-production evidence folder. Rebuilt derived records: docs/production/CANON_REGISTRY.json, MASTER_INTEGRATION_MANIFEST.csv/.json, MASTER_INTEGRATION_SUMMARY.md, MASTER_RUNTIME_CATALOG_SNAPSHOT.json.

No title music, branding pixels, companion assets, save schema, item IDs, loot probabilities, prices or progression mechanics changed.

## Verification and builds

Native gameplay and artwork fixtures pass at 1080x2340, 1200x1920 and 1920x1080. Touch, rewards and save regression fixtures pass. Canon/integration validation passes. Actual exported Windows PCK passed the gameplay route and existing full owner world route at all three sizes, including menu, profile/settings, eight Hub stations, separate Home, companions, combat, boss cues, perks, loot/comparison, results, upgrades, stash, shop, Forge and Back paths. Result rewards cannot pay twice. Windows shipping executable passed ordinary startup. The native scripted route uses Godot 4.7.2 with the actual compiled PCK because the shipping executable intentionally rejects path/script overrides.

Builds: builds/android/Lootlings-0.4.35-gameplay-equipment-debug.apk (signed arm64, version code 44); builds/windows/Lootlings-0.4.35-gameplay-equipment.exe plus adjacent .pck. Both contain current changes. APK payload checks verify all twelve imported icons and exact sidecars. Exported Android launcher/adaptive/monochrome/splash and Windows icons pass comparisons against the original approved branding. Exact approved title.ogg SHA remains 7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7.

No physical Android device is connected: S23/device launcher, startup, audio and performance testing remains outstanding. These are candidates, not a full-game completion declaration.

## Remaining and next broad pass

Frozen full-completion backlog unchanged: 3,178 contracts / 8,266 required artist files (playable 1,421; Wanderers 855; enemies 323; bosses 368; NPCs 46; support 165). Exact list: EXACT_REMAINING_CONTRACTS.json. Dedicated NPC world bodies, complete enemy/boss/weapon movement, remaining equipment body layers/variants and wider region/combat/creature audio remain unfinished. Twelve Armour inventory IDs are now complete specifically for static inventory presentation.

Next broad pass: coherent enemy/boss/weapon motion and combat-feedback families, followed by remaining equipment variants and mode/reward presentation. Existing accepted Hub/Home, title/music and companion work remains the foundation.
