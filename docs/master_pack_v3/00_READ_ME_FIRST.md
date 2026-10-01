# Lootlings Master Production Pack v3

Status: **planning / production handoff**, intentionally isolated on branch `master-production-pack-v3`.

Base checkpoint: `11964ee8b2f52fbb2226c6e014af3580aab2330d` ("Add bounded group patrol targeting and AoE through existing combat").

## Purpose

This pack turns the approved Lootlings direction into an implementation-ready production system so future Codex passes do not need to rediscover names, art rules, weapon handling, character structure, story tone, or asset needs.

It does **not** replace live code, existing IDs, save schemas, combat balance, reward RNG, or the current canonical World Bible. When this pack conflicts with shipped runtime data, shipped runtime data wins until an explicit migration is planned and tested.

## Locked creative DNA

- Cute first, badass second for Lootlings and companions.
- Adult humanoid heroes may be glamorous, sexy, rugged, raunchy, elegant, demonic, arcane, heroic, or intimidating while remaining adult characters with agency and practical silhouettes.
- Visual inspiration may borrow broad mood/pacing principles from dark fantasy ARPGs, monster-hunting fantasy, hellish shooters, loot-heavy shooters and cinematic party RPGs, but Lootlings must remain original in names, silhouettes, worldbuilding, UI, writing and mechanics.
- Interface material language remains gold / purple / cyan over dark leather, blackened steel, rune stone, crystal, wood, bone, cloth and molten-metal accents.
- Rewards should feel physical: land, burst, eject, settle, reveal.
- The world should contain tiny Lootlings, adult humans/humanoids, cute companions, ordinary NPCs, merchants, scholars, hunters, demons, monsters, bosses and strange relic beings.
- No adult humanoid costume is pasted onto tiny Lootling anatomy. Separate body rigs / pose contracts are required.
- Sexy presentation is cosmetic and expressive, not a stat bonus and not gender-locked.

## Authority order

1. Live repository code and stable IDs.
2. `LOOTLINGS_WORLD_BIBLE.md`, current roadmap/state docs and existing art provenance.
3. Owner-approved concept/reference boards already stored under `art/reference/`.
4. This pack for planned expansion and production sequencing.
5. New art generation only when a required clean production asset does not already exist.

## Current parallel work

At the base checkpoint, Codex had just completed bounded group patrol targeting/AoE. The active local continuation shown by the owner is moving into a seeded route mode that chooses rooms between fights while reusing existing encounter, merchant and loot systems. Do not interrupt that work merely to merge planning docs.

## How to use this pack

Codex should finish and checkpoint the current gameplay tranche first. Then merge/cherry-pick this planning branch and execute `10_CODEX_EXECUTION_PLAN.md` in coherent tranches, checkpointing after each validated block.

The player should not have to manually rename dozens of files or repeat design intent. IDs, filenames, pose requirements and implementation order are defined here so production work can be automated and audited.
