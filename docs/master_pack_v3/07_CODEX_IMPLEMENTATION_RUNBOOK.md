# CODEX IMPLEMENTATION RUNBOOK

## Current handoff
Main is confirmed through group-combat checkpoint:
11964ee — Add bounded group patrol targeting and AoE through existing combat.

Codex is currently building the seeded route/room tranche after that checkpoint.
DO NOT interrupt that working tree with this pack.

## When to use this pack
After Codex pushes the current route checkpoint:
1. stay in the same Codex Lootlings conversation;
2. fetch/read branch chatgpt/master-production-pack-v3-2026-10-02;
3. treat live repo code/tests as authority;
4. integrate this pack in coherent tranches;
5. do not replace working systems just because this pack proposes a prettier abstraction.

## Priority A — Avatar architecture
Goal: selectable Lootling OR adult humanoid without changing combat balance.

Add an avatar-kind layer above the existing character identity:
- lootling
- humanoid

Preserve all seven existing Lootling IDs.
Add humanoid origin IDs from 06_CONTENT_ID_MANIFEST.json.
Keep appearance cosmetic.

Do not delete or rename the existing selected Lootling/profile fields. Migrate additively.

## Priority B — Humanoid beta selection/playability
Use owner-approved boards for deliberate BETA extraction only when the cutout is clean.
Do not invent a different human design to replace a named origin.
If a full-body beta cutout is unsuitable, use its portrait in selection/profile while keeping that origin gated from combat until an honest body exists.

Target first playable humanoids:
Aurelia Voss
Kaien Rook
Selene Veyra
Rex Calder

Then story-unlock:
Nessa Vale
Corvin Ash
Vesper Thread
Juno Brass
Custom Wanderer

## Priority C — Weapon fitting system
Implement shared actor sockets + weapon pose contracts from 04_WEAPONS_POSES_AND_EQUIPMENT.md.
Do not hand-place every actor×weapon with unrelated magic numbers when a reusable profile works.
Keep current combat timings and damage.
Validate 480×854 screenshots.

## Priority D — Character creator
First ship data/save/UI with honest beta previews:
- adult body frame
- skin tone
- face preset
- eyes
- hair
- facial hair
- scars/tattoos/warpaint
- makeup
- outfit family
- dyes
- jewellery/accessories
- portrait/title/banner
- pose/emote

No gender-locked outfit rules.
No stat changes from appearance.

## Priority E — Wardrobe Hideout services
Add Mira Threadlock, Oren Valeglass and Talli Nock as presentation/service NPCs only after the underlying screens exist.
Reuse Patch/Ilex/Sera/Merrow instead of creating duplicate power vendors.

## Priority F — Story and dialogue
Keep LOOTLINGS_WORLD_BIBLE.md as story authority.
Use 09_DIALOGUE_QUEST_AND_BANTER_BANK.md as additive writing.
Do not turn flavour lines into unimplemented powers.

## Priority G — Cosmetics/transmog
Separate visible appearance from equipped power.
Owned cosmetic IDs persist even if an asset is temporarily missing.
Preview is free.
Monetisation remains future-only.

## Priority H — Final art replacement
Beta crops are replaceable.
Use 08_ART_PRODUCTION_MANIFEST.md exact paths/contracts.
Do not regress to giant runtime sheets.

## Checkpoint loop
For each tranche:
IMPLEMENT
→ focused tests
→ parser/import
→ native 480×854 capture
→ visual inspection
→ fix
→ save/migration tests
→ git diff --check
→ commit
→ push
→ continue

## Credit/time rules
- no broad repository re-audit;
- no duplicate architecture;
- inspect only touched/current dependency files;
- batch related UI/data/tests;
- reuse existing renderers/catalogs;
- do documentation reconciliation after implementation, not before;
- preserve a clean pushed fallback before risky runtime changes.

## Hard protected contracts
Unless a dedicated task explicitly changes them:
- existing save IDs
- current economy
- rarity probabilities
- drop odds
- run/campaign reward rules
- accepted solo balance path
- existing group-combat deterministic tests
- current region progression
- current chest claim semantics
- current weapon damage/timing

## Definition of done for the first humanoid milestone
- at least 4 adult humanoid origins visible in selector/profile;
- at least 2 honestly playable in combat with weaponless actor bodies;
- all 12 weapon families either fitted or explicitly asset-gated;
- appearance selections persist across restart;
- no appearance option alters power;
- original seven Lootlings remain selectable;
- Gloomlet remains available via documented temporary fallback until clean art exists;
- 480×854 QA has no clipped face, weapon, panel or text;
- save migration and existing combat/economy tests pass.
