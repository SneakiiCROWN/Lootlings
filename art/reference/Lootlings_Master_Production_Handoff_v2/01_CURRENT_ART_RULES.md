# Lootlings — Current Art / Asset Rules

## Runtime source of truth

The current clean runtime neutral mascot is:

`art/sprites/relic_beast_base.png`

Keep it intact.

The canonical design references remain in:

`art/reference/canonical/`

The existing `ART_REFERENCE_INDEX.md` and `DESIGN_BIBLE.md` in the project remain authoritative.

## Named Lootlings

Canonical identities:

- Emberhorn — fire fox-dragon / energetic forward attacker
- Mosskin — Guardian / nature / defensive
- Moonkip — Rogue / moon / nimble
- Pebblewyrm — Bruiser / physical / heavy impact
- Glimmerfin — Mage / tide / ranged magic
- Gloomlet — Assassin / shadow / pounce

Their canonical character sheets are references, not safe runtime cutouts.

Do not unlock a named Lootling merely by cropping its character sheet.
A named Lootling becomes runtime-ready only when it has a clean transparent
standalone sprite with complete ears/horns/tail/gear/Core, safe margins and
phone-readable framing.

## Concept boards

All big generated boards in `Lootlings_Art_Production_Pack_v1` are design
references only. They may inspire systems, effects, poses, items and UI, but
must not be imported as runtime sprites.

## Existing runtime asset categories

The project already has:
- neutral Relic Beast runtime art
- current enemy runtime assets / atlases
- current weapon-family assets
- current arena / zone backgrounds
- chest/reward presentation code
- outline/readability systems
- starter-selector architecture
- enemy-variant architecture
- affix / Signature Loot architecture
- achievement / Trophy Archive architecture
- debug QA tooling

The next pass should EXPAND content and presentation around those systems,
rather than replacing stable foundations.

## Generated-art limitation

Do not spend implementation time attempting to auto-create final character
sprite art from large reference sheets.

Use asset-ready detection / locked entries and replacement-ready paths instead.
