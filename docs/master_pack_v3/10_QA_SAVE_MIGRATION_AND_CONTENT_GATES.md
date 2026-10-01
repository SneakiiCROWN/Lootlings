# QA, SAVE MIGRATION & CONTENT GATES

## Why this exists
The fastest way to ruin a large content expansion is to make appearance, story and combat share fragile IDs. Keep them separated.

## Additive profile concept
Do not assume exact field names until Codex inspects the current schema.

Planned logical structure:
avatar_kind
selected_lootling_id
selected_humanoid_origin_id
appearance
cosmetic_ownership
equipped_cosmetics

Existing fields are preserved and migrated into the new structure, not destructively renamed in one step.

## Migration defaults
Old profile:
avatar_kind = lootling
selected_lootling_id = existing selected identity or relic_beast fallback
humanoid fields = empty/default
appearance = empty/default
owned existing cosmetics = preserved

Unknown cosmetic ID:
keep ownership data
render safe fallback
do not delete the ID

Missing art for a selected origin:
keep selection data
show explicit fallback/asset-gated presentation
never silently swap the player to a different named character.

## Content gates
state values:
live
beta_live
asset_gated
mechanic_gated
future
deprecated

Every new humanoid origin, outfit family and pose profile should have one gate.
UI should not imply mechanic-gated content works.

## Character creator QA
- all skin tones render without tinting eyes/teeth/clothes;
- hair does not clip ears/hat catastrophically;
- facial hair works across intended face presets;
- makeup/tattoos do not change stats;
- outfit swap preserves equipped power item;
- dye only affects approved mask channels;
- restart preserves exact selections;
- randomise never creates missing-ID references;
- adult-only looks remain on adult humanoid models.

## Weapon fitting QA
Matrix:
actor profile × 12 weapon families × idle/attack/hurt/victory.

Automated:
- socket exists;
- texture path exists if enabled;
- projectile profile matches weapon definition;
- no NaN/invalid transform;
- saved weapon skin resolves after restart.

Visual:
- hand contact;
- face/Core clearance;
- screen bounds;
- correct attack direction;
- projectile launch point;
- no backwards crossbow/bow;
- no weapon through torso.

## Existing protected regression
Always rerun the relevant accepted tests for:
solo expedition
group patrol
loot/rewards
merchant
Stash
Forge
contracts
chests
region unlocks
save migration
economy
deterministic seeds

## Native visual gate
Target 480×854.
Inspect:
Boot/Title
Profile
avatar selection
character creator
Hideout
Wardrobe
Stash
Forge
merchant
contracts
region selector
solo combat
group combat
boss
chest reveal
item review
Results

## Performance gate
New appearance layering must use bounded draw calls/textures.
Avoid equipping dozens of always-live particle emitters.
Phone-scale readability beats microscopic jewellery detail in combat.

## Release honesty
A clean beta cutout may be beta_live.
A concept board is never automatically live.
A named origin with portrait but no combat body can be selectable for preview while remaining combat asset_gated.
Never advertise missing features as complete.
