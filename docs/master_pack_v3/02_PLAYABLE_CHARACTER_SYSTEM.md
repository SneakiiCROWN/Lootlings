> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# Playable Character System — Planned Expansion

This document defines the **planned humanoid player branch** alongside the already-live Lootlings. It is not yet a shipped runtime contract.

## Top-level character choice

The New Game / Character screen should present two equally legitimate paths:

### A. Lootling
Choose one of the seven canonical identities. Their personality, origin and species silhouette are fixed; cosmetics alter appearance without erasing identity.

### B. Wanderer
Create an adult human/humanoid adventurer. Appearance is highly customisable while combat capability is determined primarily by equipment/build rather than gender, skin colour or body shape.

The two paths share:
- campaign;
- weapons;
- item drops;
- stash;
- Forge;
- contracts;
- regions;
- bosses;
- currencies;
- world story;
- rewards.

They may have different animation/pose renderers and different cosmetic slots.

## Wanderer creation model

All Wanderers are adults. No mechanical stat is derived from sex, gender presentation, skin tone, face or body shape.

### Identity fields
- display name
- pronouns: she/her, he/him, they/them, custom text fallback
- voice set / text-bark set
- title
- origin preset (cosmetic/story flavour, not mandatory combat class)
- favourite weapon
- banner/icon

### Body presentation
Planned body frames should be authored as neutral rig categories rather than "male/female stat classes":
- Light
- Athletic
- Curvy
- Broad
- Heavy
- Muscular

Each frame needs compatible armour anchor metadata. These labels are production categories only; UI can present friendly previews rather than measurements.

### Appearance controls
- skin tone palette spanning very light to very dark and fantasy-tinted optional variants
- face presets
- jaw / nose / eye / brow variants if feasible in 2D modular art
- hair style
- hair colour
- facial hair
- eyebrow style
- eye colour
- scars
- freckles
- makeup / war paint
- tattoos / runic marks
- horns
- ear style
- optional tail for fantasy-humanoid presets
- Core/crystal ornament style
- jewellery
- piercings
- gloves
- boots
- cape/scarf
- idle stance
- victory stance

If fully granular morphing is impractical in the current 2D pipeline, ship curated presets with swappable hair/skin/marking layers first.

## Adult fantasy lineages — cosmetic, not power races

Use original Lootlings terminology. These are appearance/lore presets, not required stat systems.

- **Reachborn** — ordinary humans from surviving Aurel settlements.
- **Ashmarked** — horned or ember-marked humanoids touched by Cinder corruption but not inherently evil.
- **Veilborn** — shadow/Nullglass-touched adults with unusual eyes, dark markings or spectral accents.
- **Starbound** — adults marked by crystal/star relic exposure; luminous irises, crystal jewellery, arcane scars.
- **Greenwoken** — adults with nature motifs, leaf/wood jewellery, subtle bark-like markings.

Any lineage may use any supported skin tone, gender presentation, body frame or weapon family.

## Origin presets / starter fantasy

These are flavour presets that provide starter outfit styling and dialogue tags. They should not permanently lock weapon classes.

1. **Vault Hunter** — relic-seeking melee/ranged adventurer; battered leather, scarf, practical belts.
2. **Moonfen Rogue** — hooded scout; fitted leathers, knives, bows, crossbows.
3. **Cinder Exile** — infernal survivor; blackened armour, red cloth, exposed-skin variants optional.
4. **Starfall Witch** — arcane scholar; robes, fitted bodices, jewellery, staves/wands/orbs.
5. **Lantern Warden** — knight/protector; plate, cloaks, shields if later added.
6. **Wilds Ranger** — hunter; layered hides, green cloth, bows/spears.
7. **Gearworks Tinker** — brass/teal tech scavenger; goggles, tools, crossbows/slings.
8. **Relic Priest** — ceremonial healer/support aesthetic; white/gold/crystal pieces.

## Sexy / raunchy styling contract

Allowed for adult humanoids:
- cleavage
- midriff
- fitted leather/plate
- high slits
- shorts
- thigh-high boots
- harness details
- bare arms/shoulders
- shirtless masculine variants
- open coats
- corset-like fantasy armour
- glamorous robes
- demonic/occult fashion
- rugged scars and body markings

Rules:
- all bodies are adults;
- every major outfit family should have practical, modest and revealing variants where art budget permits;
- revealing options are not gender-locked;
- no gameplay advantage for sexualised clothing;
- armour readability and weapon clearance still matter;
- never force a revealing default on the player.

## Save-facing planned IDs

Do not implement until a migration is designed, but reserve the shape:

```
avatar_mode = "lootling" | "wanderer"
avatar_id = existing lootling id OR "wanderer"
body_frame = "light"|"athletic"|"curvy"|"broad"|"heavy"|"muscular"
lineage = "reachborn"|"ashmarked"|"veilborn"|"starbound"|"greenwoken"
pronouns = ...
skin_tone = ...
face_id = ...
hair_id = ...
hair_colour = ...
markings = [...]
outfit_cosmetic_id = ...
head_cosmetic_id = ...
cape_cosmetic_id = ...
jewellery_ids = [...]
idle_pose_id = ...
victory_pose_id = ...
```

Build the renderer from data. Do not hard-code one "sexy girl" or one "warrior guy" as the only humanoid option.
