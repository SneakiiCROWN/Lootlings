# Lootlings — AI Continuity / Start Here

Purpose: make Lootlings recoverable across new ChatGPT chats, Codex sessions, context compaction, device changes, and long development gaps without relying on conversational memory.

## Golden rule

The repository is the durable source of truth. Chat memory is helpful context, but it must never be the only record of project decisions.

Future ChatGPT/Codex sessions should recover state from this repository before asking the user to repeat history.

## Startup procedure for any new AI session

1. Identify the live/default development branch and inspect the latest pushed commits.
2. Read the current live:
   - `PROJECT_STATE.md`
   - `MASTER_ROADMAP.md`
   - `CONTENT_IMPLEMENTATION_STATUS.md`
   - `DESIGN_BIBLE.md`
   - `LOOTLINGS_WORLD_BIBLE.md`
   - `ART_REFERENCE_INDEX.md`
   - `BETA_ART_PROVENANCE.md`
   - `ASSET_PROVENANCE.md`
3. Read this production pack in `docs/master_pack_v3/`, especially:
   - the core master production/spec documents
   - `18_CINEMATICS_STAGE_INTROS_AND_REPLAY.md`
   - `19_CHARACTER_STORY_PREVIEWS_AND_VIGNETTES.md`\n   - `20_ANIME_GOTH_EMO_METALCORE_FASHION_DIRECTION.md`
4. Inspect only the latest relevant git diff / recent commits needed to understand unfinished work. Do not re-audit the entire repository unless a genuine inconsistency requires it.
5. Treat newer tested runtime implementation as authoritative when stale documentation conflicts with it, then reconcile the docs.
6. Preserve working gameplay, save compatibility, economy, combat and progression unless a deliberate tested migration is required.
7. Continue from the latest safe pushed checkpoint. Do not restart the project from an old chat summary.

## Required continuity updates at each meaningful checkpoint

Codex should keep these current whenever a substantial tranche is completed:

- `PROJECT_STATE.md`: what is currently playable and the latest safe checkpoint.
- `MASTER_ROADMAP.md`: completed / active / deferred work.
- `CONTENT_IMPLEMENTATION_STATUS.md`: exact content/runtime status.
- Asset provenance docs: accepted/beta/final/missing asset state.
- This file only when the recovery procedure itself changes.

A checkpoint report should state:
- commit SHA;
- what shipped;
- what was tested;
- save/migration implications;
- known limitations;
- next recommended tranche;
- whether the working tree is clean and synchronized.

## Core creative identity that must survive context loss

Lootlings is an original fantasy action/loot game with deliberate contrast:

- cute, expressive collectible Lootlings and companions;
- adult human/humanoid Wanderers with broad appearance/customisation freedom;
- attractive/glamorous/raunchy adult cosmetic options alongside practical, rugged and heavily armoured ones;\n- a deliberate anime-influenced goth / emo / alt / metal / metalcore fashion lane for adult Wanderers and selected NPCs, including sexy, elegant, cute, brutal and infernal variants across varied genders, body presentations and skin tones;
- badass weapons, relic gear and strong silhouettes;
- frightening infernal/devilish/demonic monsters and bosses;
- beautiful magical/crystalline/nature environments;
- dark fantasy, mystery, environmental storytelling and collectible lore;
- physical-feeling loot/reward presentation;
- gold / purple / cyan UI identity;
- premium painterly/chunky presentation with readable silhouettes.

Inspirational design principles may evoke dark fantasy ARPGs, monster-hunting RPGs, personality-rich loot games and aggressive infernal shooters, but never copy protected characters, artwork, dialogue, maps, logos, music or exact designs.

## Player identity contract

The game should support both:

1. canonical Lootlings / Relic Beast identities; and
2. adult human/humanoid Wanderers with modular appearance and cosmetic customisation.

Missing final artwork must not remove an already-working playable identity. Use documented temporary fallbacks where necessary.

Weapons require data-driven pose/socket/anchor contracts rather than pasted-over portrait art.

## Narrative / discovery contract

The world should work at several depths:
- obvious campaign story;
- optional NPC dialogue and Archive material;
- environmental props and item descriptions;
- cross-region clues and contradictions;
- rare/hidden mysteries and community-theory fuel.

Basic story comprehension must not require external lore videos, while obsessive players should still have mysteries worth investigating.

## Cinematic contract

Use short, skippable, replayable first-time moments rather than repetitive interruption:
- region arrivals;
- character introductions;
- boss entrances;
- major loot/relic reveals;
- Echo/memory sequences;
- selected campaign events.

Character pages may include PLAY buttons for origin scenes, memories, relationship scenes, pose/outfit previews and other unlocked vignettes.

Prefer reusable layered illustrated / living-painting scenes before expensive full frame-by-frame animation.

## Asset contract

Every production asset should have, where applicable:
- stable ID;
- filename;
- destination;
- associated content ID;
- dimensions/aspect;
- transparency requirement;
- safe margins;
- pivot/anchor;
- pose/layer requirements;
- fallback;
- provenance;
- status: MISSING / BETA / ACCEPTED / FINAL.

Reference boards are not automatically final production assets.

## Working style

The user wants visible progress, not repeated planning loops.

AI collaborators should:
- work in substantial tested tranches;
- checkpoint/push regularly;
- avoid repeatedly asking for approval for ordinary reversible work;
- avoid duplicate systems;
- fix regressions as they appear;
- preserve validated fallbacks;
- make progress visible in the playable build;
- keep instructions and user actions simple.

## Current recovery note

At the time this continuity file was added, the recent live work had reached pushed Forge/weapon-evolution and combat-fix checkpoints, with multi-enemy encounters and seeded route work already implemented/tested in preceding tranches. Future sessions MUST verify the latest live branch rather than assuming this sentence remains current.

The master production pack is intentionally ahead of implementation. It defines destinations/contracts for character customisation, lore, NPCs, cinematics, vignettes, living environments, UI/HUD, audio, equipment and production assets so later implementation can proceed without recreating design decisions from chat history.
