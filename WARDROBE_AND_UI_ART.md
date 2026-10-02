> **2026-10-02 audit authority:** [AUDIT_REPORT.md](AUDIT_REPORT.md). Fifty wardrobe compatibility contracts are live; modular wardrobe layers remain missing. The six shared painted materials are BETA despite their production folder. Native 480x854 captures and stretch/state checks passed; notification overlap, phone safe areas, scalable text and full remapping/navigation remain unfinished.

# Wardrobe compatibility / painted interface tranche

## Wardrobe foundation

Extend `WandererCatalog`, do not create another avatar or attachment architecture. `wardrobe_contract(actor,stance)` exports the actual body profile, head/hair/back/hand identities, full baked components, explicit non-tint-safe status and painted-hands-over-held occlusion. WeaponFit caches these contracts once per body/group and returns the active stance contract. Fifty five-body/ten-group contracts are exercised by `tests/wardrobe_qa.gd`.

An independent layer must declare: `slot` (existing seventeen-slot vocabulary), `body_profiles`, `stances`, `heads`, `hair_styles`, `back_items`, `hand_sets`, `weapon_occlusion` (behind_body / painted_hands_over_held / foreground_over_held), boolean `tint_safe`, `facing` (right_only / authored_both), and real `asset_path`. `layer_compatibility` rejects incompatible/missing fields, missing runtime art or wrong canvas. Body fixtures in tests prove validators, NOT available costumes.

Adult layer exports must be real transparent 1024×1536 PNGs aligned to the corresponding authored READY/RELEASE body. Suggested per-family paths: `art/sprites/wardrobe/<component_id>/<actor>_<stance>_<phase>_<facing>.png`. Hair/headwear must coexist with the registered face/hair; back/cape layers must clear the held weapon; gloves must fit both registered hands and depth; include genuine foreground pieces only when occlusion requires them. Supply separately authored left exports for asymmetric parts. Palette changes require tint-safe art; the current painted presets are not tint-safe. No gender/pronoun/colour locks. Future styles cover cute, badass, glamorous, rugged, gothic, occult, arcane, knightly, rogue, hunter, berserker, priest, tinker, nature, demonic, casual/adventurer and adult sexy/raunchy direction. No new cosmetic options or gameplay stats were exposed.

## Shared visual material

Six original built-in image-generation outputs are preserved at `art/source/ui_material_v1/`; mechanical alpha-padding trim/resizing in `tools/export_ui_material.gd` creates `art/ui/production/{panel,relic,hud,button_primary,button_secondary,button_destructive}.png`. Panel/relic 512², HUD 960×240, buttons 512×144 RGBA. Existing supplied Phase 1/Wave 2 icons, meter fills/frames, wordmark and input focus remain intact.

The existing shared StyleBox now protects painted nine-patch corners and selects a compact small-panel treatment. Shared menu panels, relic surfaces, HUD header/build ribbon and all existing primary/secondary/destructive buttons use the new gold/purple/cyan navy material. Pressed/disabled/focus states are bounded texture modulation; existing tactile response and callbacks remain. No per-frame texture loading, new UI system, nodes, shaders or continuous animation. Six textures add approximately **3.7 MiB RGBA** before compression/driver overhead; no measured Android FPS/battery claim.

Native OpenGL 480×854 inspected: combat, all five heavy pose sheets, level-up, item decision, Boss Hoard, merchant, Stash, title/profile/settings, Hideout/dialogue/loadout, Archive, Forge, regions/contracts, Field Notes/memories, results and 15 button-state fixtures. Fixed initial transparent HUD padding, ornament/text collisions, overlarge small-panel corners and upgrade footer clearance. Current screen flow, layout/actions, text/stat meanings, currencies, saves and loot are unchanged. This is shared-shell unification, NOT a claim every individual screen/layout, header, input, slider or final bar asset is finished. Resident world-life behaviour was preserved, not expanded in this tranche.

Twenty regression entrypoints passed after replacing obsolete old-filename/cap smoke assertions with explicit new-image dimensions/caps and state contrast checks. Parser/import/native logs clean. Fresh/schema-2 migration/UUID/inventory reload unchanged, 50 wardrobe contracts, 144/864 fit checks, 30 actual authored phase states. Smoke 2/5; deterministic balance 22/96 actual wins. Other campaign, encounter/AoE, route, equipment/evolution, economy, chest, item, resident, dialogue/vignette and audio suites passed.

## Exact generation prompts

Built-in image generation was used, not external stock. Panels/HUD used the approved production board as palette/style reference only, never as a character redesign; buttons were original generation. Original references were preserved. UI beta paintings are replaceable runtime art.

### panel

Use case: stylized-concept. One reusable premium dark fantasy menu PANEL texture for Lootlings. Square 1024x1024 RGBA. Deep midnight navy near-black leather/obsidian inset, tasteful embossed low-contrast texture, warm aged gold beveled trim, intricate restrained filigree ONLY at four corners within 110px, straight repeatable narrow borders on all four edges, purple and cyan tiny gemstone accents. Large central 80% completely calm/dark blank for readable game text. Nine-slice-compatible; no circular arcs or decoration crossing center. Genuine transparent outside rounded corners. No writing, letters, icons, character, UI contents, shadows beyond frame, watermark. Painted high-quality material, original fantasy design consistent with approved board palette. Image is style reference ONLY, do not reproduce content.

### relic

Use case: stylized-concept. One reusable premium dark fantasy RELIC menu PANEL texture for Lootlings. Square 1024x1024 RGBA. Deep midnight navy near-black obsidian inset, faint restrained purple etched texture, warm aged gold beveled trim, fine arcane filigree ONLY at four corners within 110px, straight repeatable narrow borders, small violet/cyan gem accents. Central 80% completely calm blank dark for readable text. Nine-slice-compatible, no circular arcs or pattern crossing center. Genuine transparent outside rounded corners. No writing/letters/icons/characters/UI contents/watermark. Original premium painted fantasy material.

### hud

Use case: stylized-concept. One reusable horizontal premium fantasy HUD backing frame, 1536x512 RGBA. Dark midnight navy inset with extremely subtle leather/obsidian texture, gold beveled thin borders and small symmetrical filigree corners, tiny purple/cyan corner gems. Keep corner caps within 100px; straight repeatable border stretches cleanly as nine-slice. Central 85% calm near-black blank area for game bars and readable text. No decoration crossing the text area, no central crest, no letters/icons/writing/characters. Genuine transparent outside neatly beveled corners. Restrained high-quality original painted mobile Lootlings gold purple cyan material. Reference for palette/style only, not copied UI content.

### button_primary

Use case: stylized-concept. Asset: one original production Lootlings fantasy UI button backing, 1024x320 horizontal RGBA transparent outside clipped rounded corners. warm aged gold/brass beveled frame with deep bronze-to-dark-navy calm inset. Premium painted material, tiny geometric purple/cyan gems ONLY at far end caps, clean straight stretchable borders; center 80% entirely quiet blank for text. Nine-slice-ready, end decorations within 70 pixels. Tight transparent padding 4px maximum. Strong readable silhouette, tasteful gold purple cyan fantasy treasure language. No curved arcs across center, no writing, labels, icons, watermark, objects, characters, outer glow or long drop shadow.

### button_secondary

Use case: stylized-concept. Asset: one original production Lootlings fantasy UI button backing, 1024x320 horizontal RGBA transparent outside clipped rounded corners. warm gold thin beveled frame, subtle cyan rim highlight, midnight navy calm inset. Premium painted material, tiny geometric purple/cyan gems ONLY at far end caps, clean straight stretchable borders; center 80% entirely quiet blank for text. Nine-slice-ready, end decorations within 70 pixels. Tight transparent padding 4px maximum. Strong readable silhouette, tasteful gold purple cyan fantasy treasure language. No curved arcs across center, no writing, labels, icons, watermark, objects, characters, outer glow or long drop shadow.

### button_destructive

Use case: stylized-concept. Asset: one original production Lootlings fantasy UI button backing, 1024x320 horizontal RGBA transparent outside clipped rounded corners. warm gold thin beveled frame, muted garnet red calm inset. Premium painted material, tiny geometric purple/cyan gems ONLY at far end caps, clean straight stretchable borders; center 80% entirely quiet blank for text. Nine-slice-ready, end decorations within 70 pixels. Tight transparent padding 4px maximum. Strong readable silhouette, tasteful gold purple cyan fantasy treasure language. No curved arcs across center, no writing, labels, icons, watermark, objects, characters, outer glow or long drop shadow.
