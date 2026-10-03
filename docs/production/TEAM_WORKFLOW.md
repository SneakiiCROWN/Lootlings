# Lootlings multidisciplinary production standard

Owner-directed standard, adopted 2026-10-03. Applies to subsequent production changes without restarting completed work. Current implementation, production reports and actual game behavior are the baseline; preserve valid work and meaningful clean checkpoints.

## Decisions and fact-checking

Before a major decision, inspect the affected current implementation and source-of-truth documentation, then reproduce the relevant behavior. Verify engine/platform claims against current official Godot documentation for the applicable engine version. When an external design practice informs a decision, cite a reputable primary game-development reference, developer postmortem or GDC-style source and explain its relevance. Separate observed facts, source-backed claims, hypotheses and unresolved acceptance gates. Do not invent industry rules or borrow another game's exact values, systems, protected content or designs.

Review changes through game design, systems/economy design, narrative, UX/UI, combat/encounters, art/animation, audio, engineering, QA and production perspectives. These are review responsibilities; automated fixtures are not substitutes for those judgments.

## Major balance/content change record

For each major change, retain:

1. Concrete player problem and reproduction.
2. Baseline evidence, including relevant current values/distributions, seed/save/build identity and native captures or play observations.
3. Proposed change, expected player benefit, tradeoffs and success/failure criteria.
4. Implementation within authorized scope, preserving good architecture/art.
5. Automated regression and simulation results.
6. Native visual/play review and mobile checks relevant to the change.
7. Before/after comparison against the baseline and criteria.
8. Evidence-based keep/revert decision and remaining limitations.

Passing tests alone cannot establish visual, mechanical, narrative, economic, mobile or real-player quality. Use automated simulation for breadth and native play review for feel. Explicitly distinguish controlled captures/synthetic input, actual native play observations and physical-device observations. Never imply subjective listening or physical handset acceptance from routing checks, desktop captures or exports.

## Discipline-specific review

- **Design/systems/balance/economy/RNG:** combat roles, DPS/TTK, progression, loot tables/rarity/affixes, currencies, shop/upgrade decisions, rewards, sources/sinks, build diversity, encounter pacing and counterplay. Use tables and simulation for tuning; compare distributions and weak/median/strong/lucky runs, preserving meaningful decisions. Bot win rate is a QA observation with an explicit policy/isolation contract, not a difficulty target.
- **Roster/art/animation:** every relevant actor/weapon/state/facing, primary grips and support hands, scale/rotation/layering, silhouette, effects, pickups and consistent visual identity. Record missing approved authored art as a blocker; do not fake anatomy or accept fit math as completed art. No AI-generated final art.
- **Narrative/content/UI/UX:** canon, species/personality, lore/voice/humour, meaningful item/enemy/boss differences and all affected player-visible strings/screens. Review touch targets, scrolling, tap/drag separation, clear system status, numbers/wrapping, menu hierarchy and cognitive load. Remove internal/debug terminology; expose deep detail on request. Quantity/reskins do not demonstrate gameplay depth.
- **Audio:** species/size/personality and attack/pain/death identity, weapons/boss feedback, repetition/fatigue and mix. Preserve source/licensing documentation; capture actual hooks and obtain subjective listening evidence.
- **Engineering/QA/mobile:** architecture, determinism, save integrity/reload, edge cases, economy exploits, duplicate rewards, combinations, overflow/touch mistakes, loading/rendering, frame pacing/FPS, memory/thermals, Android pause/resume/process death and regression safety. Record exact build and device qualifications.
- **Production:** fix high-impact player problems first, distinguish immediate fixes from content debt, keep scope commercially realistic, preserve useful checkpoints and avoid unnecessary rewrites or repeated audits.

## Completion sign-off

Every major delivery report and completion response includes **DESIGN, BALANCE, ECONOMY, ROSTER, ENEMIES, BOSSES, RNG, UI/UX, NARRATIVE, AUDIO, MOBILE, QA, PRODUCTION** as **pass / issues**, with concise supporting evidence or remaining gates. Engineering findings inform QA/mobile/production and are documented explicitly when material.

Define the reviewed scope. Mark **issues** when known player-facing blockers or required acceptance gates remain in that discipline. A scoped fixture pass must not become a discipline-wide PASS. Keep/revert decisions, untested behavior and art/device dependencies remain visible to the owner.
