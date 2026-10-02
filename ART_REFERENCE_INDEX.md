# Canonical Art Reference Index

2026-10-02 runtime note: five authored adult presets and Patch/Sera/Ilex full bodies are mapped in `WANDERER_BETA_ART.md` / `NPC_BETA_ART.md`. They do not replace canonical creature references or edit approved source boards. Baked hair/outfit/jewellery content is visible; independent modular layers are not claimed.

## Current beta authority

Latest CANONICAL WORLD / ART / STORY / CONTENT OVERHAUL supersedes older reference-only restrictions below. Original sources remain untouched. Five named canonical turnarounds, three biomes plus market/floor, three held weapons and two regional bosses are individually exported/integrated. See `BETA_ART_PROVENANCE.md` for paths/crops/limits and the subsequent shared UI/resident bust integration. Neutral remains exact; Gloomlet stays selectable with its clearly documented prior temporary stand-in. Beta extracts do not replace final production delivery requirements in `ASSET_NEEDED_PHASE2.md`.

The unchanged images in `art/reference/canonical/characters/` are the playable identity source of truth. Established presentation boards now live in `art/reference/source/established_presentation_boards/`; broad supplied boards/crops are reference-only, never substitute character designs. See `art/reference/docs/REFERENCE_ORGANIZATION.md` and its hash audit for consolidation/recovery.

## Runtime UI — Foundation UI v1

The user-supplied `art/ui/brand/` and `art/ui/skins/` batch contains exactly 34 PNGs, listed in root `manifest.json` and documented in `README_PHASE1_FOUNDATION_UI.md`. All source PNGs are unchanged. The wordmark, five panel skins, primary/secondary/destructive button states, inputs, HUD shells, separate meter frames/fills and three dividers are integrated. Source-space nine-slicing protects 32px panel corners and 24px button/input caps, rendered at half scale for the portrait UI; protected corners/caps remain intact while safe center/edge regions stretch. Meter source caps are half their respective texture height. No canonical character, weapon, enemy, environment or chest image was changed. The delivered Wave 2 icon batch is recorded below and in `ASSET_NEEDED_PHASE1.md`.

## Runtime UI — Wave 2 iconography

The 55 user-supplied PNGs in `art/ui/icons/`, `art/ui/icons/upgrades/`, `art/ui/trophies/` and `art/ui/results/` are listed in `manifest_wave2.json` and documented in `README_PHASE1_WAVE2_ICONOGRAPHY.md`. All are integrated without source edits: four currencies, five Cores, two statuses, eight variants, eighteen upgrades, three gear categories, four rarities, eight Trophy categories, one locked Trophy and two Results crests. Existing weapon and canonical character sprites are unchanged. Icons are aspect-fitted and cached; information labels, rarity names and status counters remain supplementary.

## Phase 2 approved master references

All 15 newly supplied PNGs were inspected; 14 unique images remain in `art/reference/phase2_master/`. `REFERENCE_INDEX.md` records descriptive names, original names, visual contents and full SHA-256 hashes, including the one removed exact duplicate. The four master boards and ten subject sheets are approved style/content references, not runtime-ready sprites. They do not supersede canonical neutral Relic Beast or the six named identity sheets. Broader adult heroes, companions, demons and world names remain reference-only until actual content contracts exist. Production requirements are deduplicated in root `ASSET_NEEDED_PHASE2.md`; no sheet crops are shipped.

## Shared Lootling Language

- Tiny, chunky bodies around 2–2.5 heads tall with very large eyes and ears.
- Cute, readable expression first; dangerous class fantasy second.
- Partial, asymmetric scavenged armour with leather, buckles, relic metal, and visible fur/skin.
- Bright chest Relic Core or class gem as a central identity marker.
- Large tail and ear shapes remain readable at phone scale.
- Gear and effects exaggerate with rarity without hiding the creature.

## Canonical Files

### Neutral Main Mascot / RelicBeast — Base playable Lootling

- `Lootlings_Main_Mascot_RelicBeast_Canonical.png`
- This image—not Emberhorn—is the primary source for the neutral player silhouette, base fur/palette, ears, horns, tail, scavenger gear, satchel, chest Relic Core, and default identity.
- Visual cues: warm neutral beige/cream fur, brown ear/tail tips, dark rock horns with subtle gold relic seams, amber eyes, one fang, huge curled fluffy tail, red neck cloth, brown/gold scavenger gear and satchel, glowing amber chest core.
- Personality: friendly, curious, slightly mischievous and collectible; cute before badass.

### Shared class template

- `Lootlings_ClassTemplate_Reference_Canonical.png`
- Use for common proportions, phone-scale silhouettes, expression treatment, equipment coverage, and progression consistency across the cast. It does not redefine the neutral mascot.

### Emberhorn — Separate fire character

- `Emberhorn_CharacterSheet_Canonical.png`
- Visual cues: stronger orange/red flame palette, ember horns and tail, aggressive fire effects, red/brown scavenger armour, energetic forward attacks.
- Emberhorn is a distinct established Lootling, not the default mascot. Fire effects may borrow this class language without replacing the neutral mascot's underlying identity.

### Mosskin — Guardian / nature

- `Mosskin_CharacterSheet_Canonical.png`
- Visual cues: mossy olive/cream palette, branch antlers, leaves/flowers, bark-and-bronze armour, large round wooden shield, grounded sturdy stance.
- Presentation influence: defensive/Poison-nature builds, shields, regeneration, rooted impacts, leaf shapes.

### Moonkip — Rogue / moon

- `Moonkip_CharacterSheet_Canonical.png`
- Visual cues: cream fur, enormous moon-marked ears, indigo hood/leathers, crescent twin daggers, blue-violet trails, low nimble stance.
- Presentation influence: fast/Lightning builds, multihit, crescent motifs, sharp blue-violet arcs.

### Pebblewyrm — Bruiser

- `Pebblewyrm_CharacterSheet_Canonical.png`
- Visual cues: squat dragon body, charcoal stone scales, crystal/ember back spikes, heavy gauntlets, broad chest plate, orange impact debris.
- Presentation influence: Physical builds, armour, heavy rhythm hits, rock shards, oversized blunt weapons.

### Glimmerfin — Mage / tide

- `Glimmerfin_CharacterSheet_Canonical.png`
- Visual cues: pale aquatic body, pink/cyan frilled ears, luminous water tail, blue crystal core, ornate staff, ranged wave casting.
- Reserved influence: future mage/tide identity and ranged magical presentation. No tide system is implemented yet.

### Gloomlet — Assassin / shadow

- `Gloomlet_CharacterSheet_Canonical.png`
- Visual cues: black-purple fur, magenta ear interiors, violet eyes/core, clawed partial armour, shadow trails, airborne pounce.
- Reserved influence: future shadow/assassin identity. Current Lantern Hexer may borrow dark-purple enemy readability without representing Gloomlet itself.

## Current Prototype Mapping

- Base playable mascot: neutral Main Mascot RelicBeast silhouette, palette, gear, and personality.
- Fire Relic build: neutral mascot plus Emberhorn-inspired ember/fire effects; it does not become Emberhorn.
- Lightning Relic build: Moonkip-inspired speed, crescent, and blue-violet attack language.
- Poison Relic build: Mosskin-inspired nature, growth, sustain, and shield language.
- Physical Relic build: Pebblewyrm-inspired rock, armour, and heavy-impact language.
- Glimmerfin and Gloomlet remain canonical future class references; they are not implemented as playable systems in this pass.

## Runtime Presentation Assets

- `art/sprites/relic_beast_base.png` is the transparent runtime cutout of the canonical neutral mascot artwork. It preserves the source character rather than repainting it.
- `art/sprites/enemies/razor_imp.png` is the first-pass Scrapper/skirmisher cutout: charcoal ruin scavenger, red crystal spikes, and oversized improvised club.
- `art/sprites/enemies/mossback_brute.png` is the first-pass tank cutout: broad mossy ruin beast with a battered wooden shield. It is an enemy species, not Mosskin.
- `art/sprites/enemies/lantern_hexer.png` is the first-pass ranged cutout: narrow floating hooded spirit with a lantern staff and violet hex. It is not Gloomlet or another playable Lootling.
- `art/sprites/enemies/grump_knight.png` is the wave 8 elite Treasure Guardian cutout: a crowned stone-fur brute with relic-crystal armour and an oversized locked-chest hammer.
- `art/sprites/enemies/hoard_dragon.png` is the current wave 15 Ancient Hoarder temporary cutout. Its malformed anatomy remains an explicit ART_BLOCKER; a clean transparent single-body Dragon replacement is still required. It was not regenerated in the rescue continuation.
- `art/backgrounds/treasure_ruins_arena.png` is the layered portrait arena backdrop derived from the gameplay/polish boards: moonlit ruins, lanterns, crystals, treasure, and a readable stone combat platform.
- `art/backgrounds/salvage_warrens_arena.png` is the non-canonical runtime arena for the Salvage Warrens/Emberworks: bronze forge ruins, chains, scrap, furnaces, and a clean warm combat platform.
- `art/backgrounds/hoard_depths_arena.png` is the non-canonical runtime arena for the Hoard Depths: a monumental sealed vault, dark stone, deliberate gold and violet accents, and a clean final-region combat platform.
- `art/sprites/enemies/emberworks_enemies.png` is a replacement-ready transparent three-cell atlas for Cinder Gnawer, Scrap Golem, and Kiln Wisp. They reuse skirmisher/tank/caster mechanics without representing canonical playable Lootlings.
- `art/sprites/enemies/hoard_depths_enemies.png` is a replacement-ready transparent three-cell atlas for Gemfang Wyrmling, Vaultbound Sentinel, and Shardseer. Each has a distinct readable body plan and role silhouette at 480x854.
- `art/sprites/weapons/` contains transparent painterly cutouts for the four implemented equipment families: oversized Vanguard relic hammer, Ranger relic bow, Mage relic staff, and paired Rogue relic daggers. They follow the weapon-family board while remaining neutral interchangeable gear rather than character-specific signature weapons.
- The enemy and arena files are replacement-ready production assets informed by the reference boards. They are not additional canonical character sheets and must not redefine the playable cast.

## Systems / Equipment Reference

- `57b7aeaf-2dbf-4d29-8ae8-35455e05bc19.png`
- Canonical overview of the neutral Relic Beast plus the six separate characters, class roles, weapon examples, weapon evolution, armour sets, cosmetic skins, jewellery/charms, automatic spells, companions, internal-to-themed rarity language, and oddity items.
- Current-system cues adopted from this sheet: weapon families remain interchangeable; weapons may later evolve; equipment and automatic runes are separate slots; internal Common/Rare/Epic/Legendary tiers can later display as Lootlings-themed names; oddity items should carry playful names and unusual effects.
- This overview does not merge the neutral mascot with Emberhorn or any other class character.

## Gameplay / Polish Target References

- `0cc45861-dbca-4f15-9802-4cff35b9f689.png` - between-wave merchant target: one Weapon, one Armour, one Charm, and one Utility lane with strong rarity framing.
- `119513c5-b4ac-4cb1-b390-b2760552e46d.png` - enemy-role and progression target: grunt, ranged hexer, charger, elite miniboss, and boss silhouettes with deliberate milestone spikes.
- `2ee15214-2655-4c9f-8396-f26278b508d1.png` - special reward target: choose one of three high-value rewards rather than receiving all three.
- `416738a3-c30b-4897-9931-7972ab39384b.png` - broad gameplay presentation overview covering combat readability, loot popups, exploration framing, and cast separation.
- `63c5675b-9b06-4a60-9fc5-ef9128e4b025.png` - game-loop/shop-flow reference; reinforces temporary Run Scrip for shops and limited meaningful reward choices.
- `d38459e5-a06f-436e-acd2-45de17beaf4c.png` - 2D polish target for sprite/cutout characters, readable item beams, layered arena depth, and distinct enemy silhouettes.
- `e5ec5e8a-75b2-4f36-958b-309440b69cbe.png` - weapon-family and rarity-language sheet for Vanguard, Ranger, Mage, and Rogue. The hash-identical `(1)` copy was removed.
- `f83b7cd9-f1f4-4a45-8e3a-42788ff54760.png` - consolidated north-star handoff for reward, shop, enemy scale, and visual priorities. The hash-identical `(1)` copy was removed.
- These sheets are presentation/system targets, not replacements for `Lootlings_Main_Mascot_RelicBeast_Canonical.png`, which remains the immutable base-player character source.

## Runtime art still required for roster unlocks

Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin and Gloomlet are catalogued but intentionally unavailable in the player-facing selector. To enable any one of them, supply:

- one clean transparent standalone idle/neutral PNG, isolated from the canonical design without repainting, redesign or sheet debris;
- consistent phone-readable framing and scale with `art/sprites/relic_beast_base.png`, including complete ears/horns/tail/gear/Core and safe transparent margins;
- preserved canonical face, proportions, palette, clothing, weapon/class cues and personality;
- ideally separate clean anticipation/attack, hurt and victory/reward cutouts later, though the pose layer can safely ship an identity from one high-quality idle cutout first.

Do not automatically remove backgrounds from the existing character sheets, crop a single panel containing labels/effects, or use the neutral Relic Beast as a combat substitute after another identity is selected.
