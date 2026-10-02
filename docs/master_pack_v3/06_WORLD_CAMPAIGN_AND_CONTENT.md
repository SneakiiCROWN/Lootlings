> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# World, Campaign and Content Expansion

The existing ten-entry campaign order remains stable. This document expands presentation and side-content around it.

## Region presentation checklist

Every region should eventually have:
- full background
- combat platform / foreground grounding
- ambient particles
- enemy set
- miniboss
- boss
- entrance card
- route-node art
- chest/reward flavour
- 3–5 NPC/Field Note hooks
- shop variation where appropriate
- region music stem set
- victory transition
- map icon
- palette/material guide

## Current regions

### Act I — Treasure Ruins
Purpose: teach treasure hunting, chests, Forge/Stash loop, Hollow Court presence.
Mood: moonlit ruins, furnace amber, broken vault gold.
Key enemies: existing Act I pool.
Bosses: Grump Knight / Hoard Dragon remain established.

### Mossglass Wilds
Promise theme: guardianship.
Palette: jade, cyan glass, soft gold.
Boss: Verdant Mirror.
Side-content: watchstones, stolen spring, Mosskin affinity dialogue.

### Moonfen
Promise theme: safe passage.
Palette: indigo, cyan, silver.
Boss: Lantern Jackal.
Side-content: false lanterns, lost couriers, Nessa Vale introduction.

### Frostbell Hollows
Promise theme: warning / remembrance.
Palette: ice blue, white, navy.
Boss: Belljaw.
Side-content: frozen chimes, abandoned rescue bells.

### Sunken Gearworks
Promise theme: work / duty.
Palette: oxidised teal, brass, dark water.
Boss: Drowned Engine.
Side-content: machinery, Tamsin Coil, projectile/tech loot.

### Cinder Crown
Promise theme: warmth turned tribute.
Palette: obsidian, crimson, ember, brass.
Boss: Furnace Regent.
Side-content: Ashmarked survivors, Corvin Ash, infernal armour.

### Starfall Archive
Promise theme: record / truth.
Palette: midnight, parchment, gold, violet.
Boss: Redactor.
Side-content: Ilex history, censored pages, arcane items.

### Nullglass Expanse
Promise theme: identity / abandoned possibility.
Palette: black glass, violet, cyan.
Boss: Unchosen.
Side-content: Vesper Thread, Gloomlet, reflection dialogue.

### Skyhook Bastion
Promise theme: access / toll.
Palette: sky blue, white, brass.
Boss: Chainwarden.
Side-content: aerial routes, couriers, long-range weapons.

### The First Hoard
Promise theme: ownership versus shared trust.
Palette: ancient gold, obsidian, white Core light.
Boss: Hollow Crown.
Side-content: culmination of Field Notes and faction conflict.

## Seeded route mode — active Codex continuation

The owner screenshot shows the route-mode implementation beginning after checkpoint `11964ee`.

Desired structure:
- fight node
- choice
- optional merchant
- treasure/chest
- shrine/recovery
- elite
- story/Field Note
- boss approach

Reuse existing combat/merchant/loot systems. Do not make route mode accidentally unlock campaign regions without the intended completion contract.

## Future room types
Planned, not necessarily immediate:
- Ambush
- Locked Vault
- Relic Puzzle
- Cursed Bargain
- Rescue
- Hunter Camp
- Mimic Risk
- Forge Anvil
- Archive Fragment
- Hidden Merchant
- Rest Fire
- Elite Contract
- Treasure Escape

Every room should answer: choice, risk, reward, runtime systems reused.

## Difficulty identity

Do not merely multiply HP by huge numbers. Later regions should combine:
- enemy-role composition
- attack cadence
- status pressure
- target priority
- elites
- route risk
- boss mechanics
- reward desirability

Maintain readable phone-scale encounters.
