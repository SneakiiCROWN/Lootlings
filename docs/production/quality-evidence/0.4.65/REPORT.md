# 0.4.65 balance diagnosis and connected perk/Stash clarity

Live 0.4.64 delivery 6fb7e936 continued without resetting owner edits, accepted canon, saves or rollback builds. No combat values, probabilities, item identities or economy rules changed.

FIXED & VERIFIED in source/native: perk-name labels previously had zero visible lines; multiline effects showed only their first line. Larger text rectangles now fit all existing perk names/effects at four viewport sizes. Hidden Button text no longer inflates minimum size. Cards, tooltip and selection comparison use one readonly effect description; crit, execute, leech, delay, armour and other repeated ranks show current/capped gains. Selection is explicit, confirmation and combat touch isolation preserved. Stash has a compact list frame while comparing, a visible selected row and complete identity line; failed-save retry retains gear.

The old core-biased diagnostic used obsolete haste/multihit/chain/firestorm/maxhp IDs. It is retained as historical evidence, not called an expert player. New offensive, defensive and synergy policies use actual IDs, an explicit low-health emergency rule, canonical named starter weapons retained through each run, fixed four taps per second and matched combat/loot/visual seeds. Common/no upgrades and Rare/rank-one runs cover all 12 actors; Epic/rank-three runs cover all ten campaign regions. The 102 observations are in SOURCE_STRATEGIES.json. Offensive 34/34 wins, defensive 34/34, synergy 32/34. Mean damage taken 96.10/306.94/340.81; mean run time 82.42/119.37/116.21 seconds. Aggregate progression strata are deliberately mixed; compare individual matched rows for causal claims. Two synergy losses (Emberhorn Rare and Mosskin Common) reach Act-I wave 15. These are priority-policy failures worth broader testing, not proof that elemental mechanics need buffs.

184 stationary samples measure actual foe HP removed during 30 seconds, separately from encounter clearance HP/s. One actor, Common equipment, fixed half health and no incoming attacks limit that lab. It covers live weapon families, core tags, individual perks and nonweapon equipment. Do not present clearance estimates as true DPS. No blanket balance acceptance.

Source: six guarded formula/save/RNG/economy/DPS fixtures; four connected native route fixtures plus dedicated final perk and Stash checks. Final exact-export results and build hashes are in COMPILED_QA.json and DELIVERY.json. Physical S23 remains DEFERRED.

PARTIALLY TESTED: campaign build diversity, full affix/status/buff interactions, Dungeon/Rift/Siege/endgame battle balance, frame-rate dependence, economy source/sink utility, whole-game art/audio/UX/accessibility and performance. NEEDS OWNER ACCEPTANCE: artistic/player quality of reviewed screens. No new art closures: 2,757 contracts / 7,178 artist requirements remain. Gremlin, seasonal events and canonical animation gaps remain registered, deferred behind foundations.

Further FIXED & VERIFIED: optional GUIDE chip overlapped the Hub Main menu shortcut in actual exported screenshots. It now occupies the clear space below the header; direct station and dock interactions stay unobstructed. Source phone/tablet/desktop Hub/Home/NPC routes pass, including decor Apply/Cancel/reload. The mode fixture was modernised to test earned-only spins, visible Dungeon tab, actual portal and region confirmation; it now passes Siege extraction, target dungeon entry, Archive, Gravebloom forge and normal return. These are functional routes with controlled boss kills, not mode battle-balance acceptance.

The final source wording correction distinguishes inactive heavy attacks from an already-active Physical build: Quake Grip says Unlock heavy every 5 attacks when Physical count is zero. A dedicated assertion verifies the real activation condition. The three policies are scripted priorities, not competent humans: campaign-core assignments are fixed, and mid-progression support gear is held constant across policies, not independently optimised. Real-play and high-rarity/affix/endgame build acceptance remains open.


Final delivery: source checkpoint 0a3c4ba0, Windows candidate and signed arm64 owner Android 0.4.65/code 76. Eighteen checks passed against the final Windows pack. Sixteen independent successes from the first final-pack runner are retained with its console evidence; the mode test initially used instantaneous touch contacts and failed extraction. All its contacts now use the established human-duration helper; the complete mode route passed on rerun. All 36 final compiled combat observations equal their source rows. No inferred Android execution: APK branding/resources/signature/alignment were checked, S23 remains deferred. Actual final Windows EXE startup passes with isolated saves. All 18 earlier rollback artifacts remain unchanged.

| Affected system | Status | Practical limit |
|---|---|---|
| Perk names, effect lines and capped/live comparisons | FIXED & VERIFIED | Four native viewport sizes; all existing card names/effects fit; artistic/player acceptance remains scoped |
| Stash comparison framing, selected row, identity and failed-write retry | FIXED & VERIFIED | Four native sizes; owned gear and wallet preserved |
| Hub help versus Main menu overlap | FIXED & VERIFIED | Native phone/tablet/desktop, real world station and footer taps |
| Hub/Home/NPC/modal/decor/navigation | VERIFIED PASS | Scoped direct routes; full animation/artistic acceptance open |
| Siege extraction, Dungeon entry, Archive, Gravebloom forge and return | VERIFIED PASS | Controlled encounter completion; not victory-rate balance evidence |
| Save/backup/reward/economy/owner transaction and RNG regressions | VERIFIED PASS | Scoped fixtures and simulated failures, not physical power-loss testing |
| Combat-number accounting, Ward, weapon evolution/target-bound hits | VERIFIED PASS | Scoped real formulas and 12 weapon families; not every proc combination |
| Overall campaign/mode/equipment balance | PARTIALLY TESTED | 102 source runs; 36 exact-export replays; 184 separate stationary samples |
| Windows build startup and original icon | VERIFIED PASS | Actual EXE with final pack and disposable saves |
| Owner Android candidate | PARTIALLY TESTED | Signed arm64 package/resources/original branding verified; Android execution not performed |
| Whole-game professional art/audio/UX/accessibility/performance | NEEDS OWNER ACCEPTANCE | Reviewed representative screens; no blanket production approval |
| Physical S23 | NEEDS OWNER ACCEPTANCE | DEFERRED by owner, not a development blocker |

Next connected production: better actor/gear/affix-specific priorities and more matched seeds; Legendary/Red/Mythical and temporary/permanent/relic combinations; real Dungeon/Rift/Siege/endgame battle cohorts; DoT/status/proc caps and timing under stalls; wider reward-source/sink and interrupted-save coverage; remaining readable UI/audio/world continuity. Fix demonstrated defects rather than forcing equal DPS or cosmetic win rates. Heavy canonical art, Gremlin and seasonal additions stay registered below those foundations. No art contracts were closed in this sprint.
