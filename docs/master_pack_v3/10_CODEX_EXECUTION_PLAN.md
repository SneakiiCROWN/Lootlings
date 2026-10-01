# Codex Execution Plan — Efficient, Checkpointed, No Re-Audit Loop

## Rule 0

Finish the currently active seeded-route tranche first. Do not stop halfway through local work to merge this planning branch.

After that checkpoint is pushed and clean, merge/cherry-pick `master-production-pack-v3` and proceed.

## Operating rules

- Read only the files relevant to the next tranche.
- Do not perform another broad repository audit unless a real contradiction appears.
- Reuse existing systems instead of building parallel combat/loot/save stacks.
- Checkpoint after each coherent tranche.
- Run focused tests first; full regression at tranche boundaries.
- Native 480×854 visual QA for UI/combat changes.
- Never remove working content because final art is missing.
- Label temporary art honestly in development docs.
- Keep release UI free of "TEMP" labels once production art exists.

## Tranche 1 — Finish route mode
Goal: genuinely playable additional loop.

Implement/finish:
- seeded route graph;
- room choices between fights;
- merchant/chest/shrine/story rooms using existing systems;
- completion contract that cannot accidentally unlock campaign regions;
- save/restore only if intended by current design;
- phone-scale route UI.

Checkpoint only after deterministic route tests + normal solo/group regression.

## Tranche 2 — Humanoid avatar architecture
Do not build all art first.

Add data/model support:
- `avatar_mode`
- Wanderer profile data
- appearance preset IDs
- fallback renderer
- Character Select tab for Lootling vs Wanderer
- save migration
- no stat difference based on appearance

Use simple clearly labelled development silhouettes if needed. The point is to make the system real before the entire wardrobe exists.

## Tranche 3 — Humanoid weapon pose renderer
Implement pose catalog and layered arms/weapon rendering.
Support all 12 families with temporary geometric hand/arm layers if final production pose art is missing.
Validate:
- no face overlap;
- projectile sockets;
- melee facing;
- outfit layers;
- all body frames.

## Tranche 4 — Wardrobe / appearance UI
Add:
- body preset
- skin tone
- face
- hair
- hair colour
- markings
- outfit appearance
- jewellery
- horns/ears
- idle/victory pose

Use data-driven option lists. Save presets. Keep stats separate.

## Tranche 5 — NPC population
Integrate final/current residents first, then planned side cast as content becomes available.
Add:
- NPC catalog
- hub placement
- dialogue tag pools
- basic bark history/cooldown
- route-room appearances where appropriate

## Tranche 6 — Dialogue/story expansion
Move large text pools out of hard-coded UI logic.
Add reactive tags for:
- region
- boss
- character mode
- Lootling identity
- weapon family
- chest rarity
- defeat/return
- contract state

No fake references to content the player has not completed.

## Tranche 7 — Art replacement conveyor
For each approved production asset:
1. verify filename and target ID;
2. import;
3. fit anchor/rect;
4. render native capture;
5. reject if crop/alpha/grip is bad;
6. update provenance;
7. checkpoint.

Do not wait for every asset in the game before integrating good completed batches.

## Tranche 8 — Outfit/weapon visual depth
Add higher-fidelity pose layers, evolution-stage weapon visuals, armour appearance, dyes, VFX.

## Tranche 9 — enemies/bosses/rooms
Expand dedicated bodies and visual mechanics while preserving existing damage contracts unless separately changing combat.

## Tranche 10 — polish/certification
- accessibility
- remapping
- save recovery
- Android lifecycle
- low-end performance
- audio mastering
- text overflow
- all screens at phone scale
- clean release/debug gating

## What NOT to do
- no giant rewrite;
- no 200-file refactor just to "clean architecture";
- no renaming stable IDs for aesthetic reasons;
- no replacing canonical art with unrelated crops;
- no second inventory/economy system;
- no outfit stats tied to sexiness;
- no making humanoids more powerful than Lootlings by default;
- no waiting for perfect final art before testing systems.

## Suggested Codex prompt after route-mode checkpoint

"Read docs/master_pack_v3/00_READ_ME_FIRST.md and 10_CODEX_EXECUTION_PLAN.md, then implement Tranche 2 only. Preserve all stable gameplay/save/economy contracts. Build the humanoid Wanderer avatar architecture and character-select path with honest temporary visuals where production art is missing. Do not re-audit the whole repository. Add migrations/tests, validate at native 480×854, checkpoint and push when clean. Then stop and report exactly what is live vs temporary."
