> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# UI, HUD, Text, Numbers and Presentation Contract

## Goal

Make the game read as a finished dark-fantasy loot RPG at phone scale, not a prototype dashboard.

## Global visual language

- dark charcoal / blackened steel foundations;
- gold structure;
- purple relic/mystery emphasis;
- cyan Core/arcane information;
- red danger;
- green nature/recovery;
- orange/fire;
- readable white/cream primary text;
- avoid rainbow noise unless representing deliberate rarity/element systems.

## HUD hierarchy

Top:
- character portrait
- name / level
- HP
- secondary resource if a real mechanic uses one
- compact status row

Enemy:
- name
- HP
- target marker
- elite/boss crest
- status icons
- phase marker only when mechanics exist

Lower combat:
- weapon family icon
- current build/Core identity
- contextual tap action
- ability/rune indicators only for real usable mechanics
- optional compact damage summary

Do not display meaningless bars just because the concept board had them.

## HP bars

Player:
- strong red fill
- dark frame
- numeric HP optional in accessibility/settings
- low-health pulse restrained

Boss:
- larger named bar
- phase notches if true phase mechanics exist
- boss subtitle on intro, not permanently

Grouped enemies:
- narrow lanes with distinct target highlight
- no overlapping labels
- frontmost target readable in <1 second

## XP / progression

If the current build uses run-level XP, show:
- current level
- thin progress strip
- "LEVEL UP" burst
- choice-card transition

Permanent/meta progress uses separate screens; do not combine every currency into combat HUD.

## Damage numbers

Default:
- normal damage: compact white/cream
- crit: larger gold
- fire: orange/red accent
- poison: green
- magic/arcane: purple/cyan based on actual effect
- heal: green/cyan
- blocked/guarded: grey/blue
- boss special: text cue rather than giant spam

Settings:
- full numbers
- compact
- off

Prevent number clouds from obscuring tiny characters.

## Typography

Use three roles:
1. Display/title serif or carved-fantasy face.
2. UI sans/serif hybrid with excellent small-size readability.
3. Numeric face with tabular digits for currency/stats.

Never use ornate display font for 11px body text.

## Text rules

Buttons use verbs:
- CONTINUE
- EXPEDITION
- EQUIP
- SALVAGE
- EVOLVE
- CLAIM
- TRAVEL
- FORGE
- SOCKET
- INSPECT

Avoid:
- "OK" when a specific action is possible;
- long paragraph buttons;
- programmer labels in release UI.

## Item cards

Always prioritize:
1. name
2. rarity
3. slot/family
4. major stat/effect
5. comparison
6. flavour/lore

Rare/Legendary/Signature cards may use stronger ornament and reveal animation.

## Character select

Two top-level tabs when Wanderer architecture lands:
- LOOTLINGS
- WANDERER

Lootling card:
portrait, personality, playstyle flavour, lore snippet, selected cosmetic preview.

Wanderer:
large avatar preview, appearance summary, current outfit/weapon, edit button.

## Wardrobe

Desktop-like dense grids are wrong for 480×854.
Use:
- preview upper area
- category strip
- scrollable choices
- colour picker/presets
- randomise category
- save look

## Menus to unify visually

- Title
- Profile
- Character Select
- Hideout
- Expeditions
- Route Map
- Shop
- Stash
- Forge
- Shrine
- Archive
- Contracts
- Results
- Boss Hoard
- Wardrobe
- Settings

All should share the same material/render helpers rather than bespoke rectangles.

## Accessibility
- scalable text;
- damage-number toggle;
- motion reduction;
- screen shake reduction;
- colour-blind-safe status icon shapes;
- high-contrast HP mode;
- hold/tap alternatives where practical;
- captions/subtitles for voiced material;
- music/SFX/voice sliders.
