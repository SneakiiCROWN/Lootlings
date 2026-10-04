# Lootlings Design Bible

## Normal run reward decisions

Normal wave progression offers one meaningful acquisition per reward beat. Multiple wave finds are alternatives: select one, then equip/stash/scrap it; other finds are forfeited. A merchant stop permits one purchase, with optional paid rerolls beforehand. Earned XP levels, events and boss hoards are separately labelled choose-one beats. Persistent Hideout services and paid shopping/cache transactions remain independent deliberate purchases. Do not restock a run merchant so a wealthy player can buy every offer. Rerolls escalate by 18 Scrip from `18 + wave*3`; gear prices/income/rarity remain unchanged. [Pre-device decision record](docs/production/predevice/BASELINE.md) and [current delivery](docs/production/predevice/REPORT.md) own this correction.

## Current canonical world / beta authority

Phase 3 supersedes equal-cosmetic actor mechanics: all twelve playable identities have explicit run-only perks, starter kits and HP/movement tradeoffs, while every weapon remains usable. `character_traits.gd` is the mechanics authority; `LOOTLINGS_WORLD_BIBLE.md` remains narrative authority. Twelve named equipment variants, four source-exclusive boss identities, eight optional consequence-bearing events, four merchant styles, compatible elite weights and regional boss recovery loops extend existing systems. Shared control/ward/target-serial bounds protect counterplay and released-hit ownership. Base weapon cadence, enemy HP curves, permanent prices and save formats stay intact. [Phase 3 measured decisions and limits](docs/production/phase3/REPORT.md) govern acceptance; new mechanics do not imply completed regional art, human play-feel or physical mobile validation.

Optional owned-weapon evolution adds deterministic family-specific hooks at the existing two Forge stages, alongside the original additive +4% damage. Hooks derive from saved type/stage, with no extra gameplay RNG or hidden rarity scaling. Costs/caps/acquisition rules are unchanged; stage-zero combat remains the reference baseline. Fatal attacks stay bound to their released target except explicit AoE. Results is terminal: no status siphon/evolution healing after defeat, and wins are measured by the actual outcome rather than remaining HP.

Relic Route is an optional eight-stop seeded expedition unlocked after Act I. Choices change encounter roles/resources: Combat, Elite, Treasure, Merchant, Shrine, Risk, Rest and final Boss. It reuses existing combat and reward contracts, with explicit short-mode special scaling. Shrine upgrades are run-only; route victory does not advance campaign unlocks. Permanent reward caps scale with actual kills; entering/abandoning an empty route pays nothing. Final Boss retains the physical Hoard Chest and choose-one-from-three Epic+ contract. Route maps are session-only; ordinary campaign saves and solo balance remain unchanged.

Group patrols are optional Expedition encounters, max three simultaneously active foes. They replace scheduled solo members rather than adding free rewards. Each actor owns HP/status/clock/serial; selection never redirects a released shot. Mage/heavy/strong-Fire attacks may splash other living actors. The validated solo path remains the default and unchanged; bosses retain their established chest contract. No horde spawning or shared HP pool.

The latest owner-approved world/art/story overhaul permits clean individual beta exports from approved boards, superseding earlier reference-only/no-crop instructions. Canonical identity remains protected, especially the unchanged neutral Relic Beast. `LOOTLINGS_WORLD_BIBLE.md` defines the original world and cast; `BETA_ART_PROVENANCE.md` records accepted mechanical exports and limitations. Missing/poor exports remain gated, not invented as final characters. No balance, economy, rarity, combat or save contract changes are implied by artwork/lore.

## Core Visual Identity

Lootlings should be instantly readable, cute first, and badass second.

The visual hook is:
**tiny adorable mythical/relic creatures + oversized equipment + visible progression + strong silhouettes.**

The game should feel collectible and character-driven rather than like a generic idle RPG.

## Main Mascot Direction

The preferred main Lootling is an original neutral relic-beast mascot.

Core traits:
- Small chunky body.
- Approximately 2 to 2.5 heads tall.
- Huge expressive ears.
- Tiny horns.
- One visible fang.
- Massive curled tail.
- Large, readable eyes and facial expression.
- Strong silhouette that still reads clearly on a phone screen.
- Small pieces of scavenger-style armour rather than full-body armour.
- Loot satchel / scavenger gear details.
- A glowing chest Relic Core as a major identifying feature.

The base creature should feel friendly, curious, slightly mischievous, and highly collectible.

It must be an original character and must not closely copy Capybara Go or another existing game's mascot.

## Equipment Language

Equipment should look oversized compared with the Lootling.

Rules:
- Weapons are intentionally huge and visually funny/cool against the tiny body.
- Armour covers roughly 30–50% of the creature so the creature itself remains visible.
- Gear should look worn, handmade, scavenged, patched, or relic-like rather than pristine generic fantasy armour.
- Weapons should remain interchangeable instead of being permanently fused to one character design.
- The creature silhouette must still be recognizable even when heavily equipped.

For character sheets / class templates, the Lootling can be shown weaponless when useful so the body, armour, pose, and class identity are clearly readable.

## Progression / Transformation Language

Progression should be visible on the character, not only represented by numbers.

The neutral mascot should be able to support build transformations such as:
- Fire
- Frost
- Void
- Poison
- Lightning
- Holy

These transformations should modify effects, Relic Core glow, armour details, particles, markings, and other readable visual cues without destroying the original mascot identity.

Gear, equipment, and mutations should visibly evolve as the player becomes stronger.

## Character / Class Design Rules

Future Lootlings and classes should follow the same visual template:

- Short, chunky proportions.
- Strong phone-scale silhouette.
- Clear creature traits.
- Expressive face.
- Cute base form with a slightly ridiculous badass contrast.
- Partial armour rather than hiding the whole body.
- One or two memorable class-specific visual features.
- Room for interchangeable oversized weapons and equipment.
- Easy to recolor / reskin / evolve for cosmetics and progression.
- Designed to work as collectible characters.

Different characters/classes should feel related as part of the same world, but not like simple recolors of one body.

## Gameplay Presentation

Portrait mobile presentation.

The player character should remain visually prominent during combat.

Combat should emphasize:
- readable attack anticipation
- squash / stretch
- recoil
- impact
- enemy reaction
- clear crit feedback
- visible Run Scrip / XP rewards
- restrained screen shake
- satisfying but readable particles

The game should stay enjoyable to watch during auto-combat while active tapping provides additional impact and feedback.

## UI Direction

UI should feel polished, playful, readable, and mobile-first.

Avoid:
- debug-looking text
- overly dense information
- tiny labels
- visually identical upgrade choices

Upgrade choices should be large and easy to understand, with:
- icon / symbol
- short name
- concise effect
- readable hierarchy
- satisfying selection feedback

Bosses, minibosses, victory, defeat, rare upgrades, and major rewards should have stronger presentation than ordinary gameplay moments.

## Character Feel / Variety Contracts

- Combat animation is pose-driven: anticipation, attack/release, impact, recovery, hurt and reward reaction use bounded root/body/weapon transforms. Presentation must never silently change validated damage or attack cadence.
- Actor separation uses a thin local edge on player/enemy sprites only. Bosses may receive a slightly stronger edge; backgrounds, particles and interface elements remain unoutlined.
- Regular variants must be data-driven, deterministic from gameplay RNG, visibly named/cued and uncommon. Wave 1 and bosses are protected. Visual/dialogue randomness must never consume gameplay rolls.
- Rarity may add curated compatible affixes. Legendary equipment should prefer a behavior hook over pure scalar inflation. Existing equipment IDs and old save dictionaries remain valid.
- Achievement progress is local-first and offline-safe. Secrets conceal their description until unlocked; future platform provider IDs map onto stable internal IDs rather than replacing them.
- Starter selection must be honest: a Lootling appears as playable only when a clean canonical runtime sprite exists. Character-sheet crops and spawning a different identity after selection are prohibited.
- Major chest reveals follow restrained hierarchy: wind-up, a short quiet beat, eruption, visible reward arcs/settling and then the existing decision flow. Common rewards remain brisk; Hoard rewards earn the strongest reveal.

## Art Production Rule

Current procedural art is placeholder only.

Do not spend large amounts of development time polishing placeholder shapes once proper character assets become available.

Gameplay architecture should allow final sprites / animations / effects to replace procedural visuals without rewriting the underlying combat and progression systems.

## Brand Test

At a glance, a screenshot or icon should communicate:

**"What is that adorable little creature, and why is it carrying something enormous?"**

That contrast is central to Lootlings.
