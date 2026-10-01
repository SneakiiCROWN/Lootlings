# Lore, Mysteries, Collectibles and Easter-Egg Architecture

This document expands story discovery without forcing exposition. Everything here is **planned** unless already present in live world/story files.

## Design goal

Players should be able to finish the game while understanding the surface story, but curious players should discover deeper truths through:
- environmental clues;
- collectible fragments;
- NPC contradictions;
- item lore;
- repeated symbols;
- hidden rooms;
- optional boss details;
- unusual prop placement;
- route-event variants;
- rare dialogue;
- visual motifs that only make sense later.

The game should support "lore video" speculation without becoming incomprehensible.

## Information layers

### Layer 1 — obvious story
Shown through boss intros, residents, campaign entries and major Field Notes.
Players learn:
- the Crown is broken;
- the world has old promises/guardianship systems;
- relic ownership became abusive;
- regions were shaped by different failed promises;
- the player is uncovering why the First Hoard mattered.

### Layer 2 — discoverable truth
Found through optional notes, item descriptions, shrines, props and rare dialogue.
Topics:
- not every "Unwritten" creature was created by the same cause;
- some guardians chose corruption to preserve people;
- Relic Cores remember intent more strongly than commands;
- the Hollow Court copied older protection rites and changed their meaning;
- several named NPCs know more about the First Hoard than they initially admit.

### Layer 3 — hidden developer-truth / theory fuel
Never stated in one normal dialogue scene. Spread across mutually reinforcing clues.
Potential long-term mysteries:
1. **The Missing Eighth Name** — seven canonical Lootlings are publicly recorded, but old iconography repeatedly leaves room for an eighth mark. Do not confirm what it means yet.
2. **The Crown Was Not a Person** — clues imply the "Hollow Crown" may be a role, system, ritual or repeating contract rather than one monarch.
3. **The First Hoard May Be a Promise, Not a Place** — some records describe geography; others describe an agreement.
4. **Gloomlet Remembers the Wrong Moon** — rare Gloomlet lines and Moonfen props imply a timeline mismatch.
5. **Patch's Impossible Tools** — several Forge tools use alloys from regions Patch claims never to have visited.
6. **Ilex's Redacted Handwriting** — some redacted notes are written in Ilex's own script.
7. **Sera's Core Hymn** — shrine tones repeat a melody heard in Nullglass, but in reverse.
8. **Merrow's Routes** — his maps include doors that do not exist until later regions are unlocked.
9. **The Relic Beast's Core** — the neutral mascot reacts to First Hoard motifs before the story explains them.
10. **The Broken Bell Count** — Frostbell scenery repeatedly contains one fewer bell than local inscriptions describe.

These should remain flexible. Do not write a final answer into the game until later production intentionally resolves one.

## Collectible systems

### Field Notes
Existing Archive-compatible lore delivery. Expand by region and speaker.

Recommended categories:
- REGION
- PERSON
- CREATURE
- RELIC
- COURT
- UNWRITTEN
- FIRST HOARD
- UNKNOWN

### Echo Fragments
Short visual/audio memory snippets unlocked by interacting with suspicious props. They should be 5–20 seconds, text-first if audio is unavailable.

### Relic Inscriptions
One- or two-line inscriptions on statues, weapons, vaults and shrine objects. Some are incomplete.

### Merchant Rumours
Rare shop dialogue with unreliable testimony. Mark as rumours internally, not as objective lore truth.

### Boss Remnants
Optional post-boss interactables that reveal what the boss was protecting, not merely how evil it was.

### Map Anomalies
Tiny symbols on route maps that later correspond to optional rooms, NPCs or hidden entrances.

## Environmental clue rules

Clues should use repetition. One weird prop is decoration; three related clues across regions become a theory.

Examples:
- the same crown-shaped crack in unrelated ruins;
- seven sockets surrounding an empty eighth recess;
- a childlike drawing of a purple moon in a place with no visible moon;
- Patch's maker mark on equipment in a sealed pre-Patch ruin;
- Ilex's handwriting under an older archival layer;
- a Hollow Court chain motif appearing on an allegedly pre-Court statue.

## Easter eggs

Two categories:

### Internal Lootlings easter eggs
Preferred. Reward attentive players without dating the game.
Examples:
- treasure mimic pretending badly to be furniture;
- recurring tiny rat carrying progressively better equipment;
- a "definitely safe lever" that only changes background props;
- a hidden shrine to an unknown Lootling;
- NPCs arguing about whether a sword is actually a large knife;
- duplicate-looking chests where one quietly watches the player.

### External inspiration nods
Use **broad genre homage only**. Never copy logos, named characters, famous lines, exact props, map layouts or copyrighted symbols from Witcher/Diablo/Doom/Borderlands/Baldur's Gate/Treyarch Zombies.

Good homage:
- ritual-board puzzle structure;
- environmental number sequences;
- chained-door mystery;
- loot-beam colour language;
- metal/gothic hellscape mood;
- dry monster-hunter banter.

Bad homage:
- recognisable copied icon;
- direct quote;
- recreated weapon/monster;
- named reference that risks trademark/copyright confusion.

## Puzzle chain framework

Long-form hidden quest chains should be solvable without datamining but can reward deep community collaboration.

Example framework:
1. notice repeated symbol;
2. find three region variants;
3. compare ordering;
4. use order on a non-obvious prop;
5. unlock an Echo Fragment;
6. fragment points to optional route room;
7. room contains a cosmetic/lore reward, not mandatory power.

## Developer-only truth file

Future production may add a PRIVATE development-only document outside runtime export containing:
- intended answers;
- false trails;
- unresolved mysteries;
- planned reveal timing.

Do not ship that file in the game package if it contains unrevealed answers.
