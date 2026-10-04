LOOTLINGS — FINAL PRE-DEVICE RELEASE-CANDIDATE AUDIT
CREDIT-EFFICIENT FULL GAME QA / CLEANUP / BALANCE PASS

Continue from the CURRENT CLEAN Phase 3 checkpoints.

This is the final comprehensive pre-device audit before installing on:
- Samsung Galaxy S23 Ultra
- Samsung Galaxy S24 Ultra

IMPORTANT PRODUCTION RULE:
Be thorough, but DO NOT waste Codex/runtime budget repeating evidence that Phase 3 has already established.

Reuse the existing frozen Phase 3 baseline, reports, simulation results and native evidence wherever the underlying system has NOT changed.

Run focused tests after local changes.
Only rerun broad expensive simulations where a changed system could invalidate the previous evidence.
Perform one broad final regression/acceptance pass at the end.

Do NOT restart systems that work.
Do NOT lower difficulty just to improve test results.
Do NOT fake missing authored art.
Do actual implementation/fixes, not documentation only.

==================================================
PROGRESS UPDATES
==================================================

Give concise progress updates at meaningful milestones so I know the task has not stalled.

Examples:
- repository audit complete
- gameplay/content audit complete
- balance/economy audit underway
- UI/mobile review complete
- audio/narrative review complete
- final native playthrough underway
- Android build/verification underway

Do not spam updates every command.

==================================================
1. PRESERVE AND INSPECT
==================================================

First:
- inspect git status/diff
- confirm current branch/checkpoints
- preserve completed Phase 3 work
- read current Phase 3 reports/evidence
- identify known blockers/debt
- create a safe checkpoint if needed

Do not duplicate already-completed work without reason.

==================================================
2. COMPLETE REPOSITORY / CODE / FILE AUDIT
==================================================

Inspect the entire current game project:

- scripts
- scenes
- resources
- autoloads
- assets
- audio
- UI
- save system
- input
- project/export settings
- Android tooling
- QA tooling
- documentation

Find and safely fix:
- actual dead code
- duplicate systems
- stale prototypes
- broken/missing references
- unused/orphaned files proven to be unused
- bad naming/inconsistency
- debug/dev content leaking into production
- unsafe state/null assumptions
- save corruption risks
- test-state contamination
- outdated test fixtures
- temporary files
- obvious performance waste

Do not delete files merely because they look unused.
Preserve licensing/provenance/source records.

==================================================
3. FULL GAME / LEVEL / ROUTE AUDIT
==================================================

Review the complete CURRENT playable game from start to finish.

Check every:
- title flow
- character selection
- hideout/hub
- level
- route
- room
- encounter
- wave
- merchant
- event
- elite
- miniboss
- boss
- chest
- reward
- death flow
- return-to-hideout flow

Check:
- pacing
- repetition
- difficulty
- dead time
- encounter composition
- reward cadence
- progression
- transitions
- visual readability
- RNG combinations
- blockers
- confusing moments

Nothing should look obviously placeholder/broken/pointless unless documented as genuine production art debt.

==================================================
4. ALL PLAYABLE CHARACTERS
==================================================

Review EVERY playable character.

Check:
- identity
- stats
- perks
- DPS/burst
- survivability
- movement
- control
- elemental/status synergy
- starting equipment
- strengths/weaknesses
- active-play performance
- audio identity
- all supported weapon combinations
- left/right facing
- idle/windup/attack/recovery/hit/death
- support-hand fit
- weapon scale/rotation/layering
- projectile origin

Do NOT balance based on idle/no-tap survival alone.

Preserve meaningful differences rather than making everyone statistically identical.

Keep genuine known art blockers explicit:
- Moonkip weaponless body
- missing authored support-hand/paired-weapon poses
- any other truly missing canonical art

==================================================
5. EVERY WEAPON / ITEM / SPELL / BUILD
==================================================

Review every usable:
- melee weapon
- ranged weapon
- bow
- spell
- armour
- jewellery/accessory
- relic
- passive
- affix
- named item
- boss item
- cursed item
- utility item

Audit:
- DPS
- burst
- speed
- range
- AoE
- crowd control
- status
- crit
- elemental synergy
- stacking
- risk/reward
- healing/ward loops
- animation fit
- sound
- projectile/VFX

Find and correct:
- useless choices
- dominant choices
- accidental best-in-slot
- broken combinations
- meaningless filler
- exploitable loops

Rare/earned extreme builds may remain extremely powerful if they are fun and not automatic.

==================================================
6. DAMAGE / DPS / TTK / DEFENCE
==================================================

Use the trustworthy Phase 3 measurement harness.

Reuse frozen evidence when systems are unchanged.

Where relevant systems changed, measure:
- sustained DPS
- burst DPS
- TTK
- boss TTK
- incoming damage
- survivability
- armour
- ward
- healing
- stagger/control
- status damage
- lifesteal
- overkill
- weak/median/strong/lucky builds

Do not turn difficulty into:
- automatic wins
- HP sponges
- unfair one-shots

==================================================
7. ENEMIES / BEASTS / ELITES
==================================================

Review every enemy and creature.

Check:
- role
- behaviour
- HP
- damage
- movement
- telegraphs
- recovery
- audio
- VFX
- death
- reward
- encounter combinations

Enemies should differ mechanically, not merely by sprite + stats.

Audit elite modifier compatibility.

Ensure higher danger produces worthwhile reward.

==================================================
8. MINIBOSSES / BOSSES
==================================================

Review every miniboss and boss.

Check:
- identity
- mechanics
- attacks
- telegraphs
- recovery windows
- phases
- arena interaction
- difficulty
- audio
- VFX
- dialogue
- lore fit
- reward quality
- boss-exclusive loot

Do not call reused regional boss/miniboss visuals finished if they still require unique authored bodies/animations.

==================================================
9. RNG / REPLAYABILITY
==================================================

Audit:
- encounter RNG
- enemy RNG
- elite RNG
- loot
- rarity
- affixes
- named items
- elemental variants
- merchants
- chests
- events
- routes
- minibosses
- bosses
- rare encounters
- secrets

Retain/fix:
- compatibility rules
- duplicate protection
- drought protection
- appropriate pity systems

Test extreme unlucky/lucky seeds where necessary.

Two runs should meaningfully differ.

==================================================
10. HARD RUN-REWARD RULE
==================================================

This is a core intended design rule:

During normal wave/round reward progression, the player should GENERALLY make ONE meaningful item/upgrade/reward choice for that reward beat.

The intended experience is NOT:
“buy or click every upgrade/drop because I have enough money.”

Audit the current entire run reward/shop progression around this.

Where current design violates the intended loop, redesign it carefully.

Normal decision should feel like:

“I want A, but taking A means giving up B.”

Exceptions are allowed only when deliberately designed and clearly communicated.

Do not make every wave an annoying confirmation sequence.

==================================================
11. FULL ECONOMY AUDIT
==================================================

Map all faucets/sources:
- combat
- wave rewards
- elites
- bosses
- chests
- events
- salvage
- quests
- passive sources

Map all sinks:
- shops
- upgrades
- rerolls
- services
- risk/gambling mechanics
- unlocks
- anything consuming currency

Check:
- income
- spending
- savings
- affordability
- reroll value
- purchase frequency
- salvage value
- unused currency
- long-term usefulness

MONEY MUST MATTER.

A good economy should create moments where the player decides:
- spend now
- save
- reroll
- skip
- gamble
- chase something better

Avoid:
- currency becoming worthless
- always being broke
- buying everything
- buying nothing
- one permanently optimal spend

This is IN-GAME currency/economy only.
Do not add real-money monetization.

==================================================
12. NEW PLAYER + VETERAN PLAYER REVIEW
==================================================

Evaluate from BOTH perspectives.

NORMAL/NEW PLAYER:
- does not know hidden systems
- does not min-max
- makes imperfect choices
- expects obvious controls
- reads only important text

Check:
- onboarding
- clarity
- progression
- frustration
- touch mistakes
- understanding rewards

VETERAN/MIN-MAX PLAYER:
- hunts exploits
- stacks synergies
- optimizes economy
- seeks broken DPS
- rerolls efficiently
- hunts rare RNG
- tries to trivialize bosses

Check:
- degenerate strategies
- dominant builds
- economy exploits
- infinite loops
- trivial boss tactics
- bad RNG manipulation

==================================================
13. EVERY UI / HUD / MENU SCREEN
==================================================

Inspect natively:
- title
- character selection
- hub
- combat
- pause
- shop
- inventory
- upgrade/reward choices
- events
- chests
- boss intro/rewards
- settings
- Field Notes
- death
- run summary
- test report

Audit:
- clutter
- hierarchy
- wrapping
- spacing
- safe areas
- font sizes
- scrolling
- touch areas
- contrast
- overflow
- information overload
- accidental combat input
- accidental purchase/equip/upgrade

Aim for Android interactive targets of roughly 48dp minimum where practical.

UI touches must NOT leak into combat attacks.

Scrolling over a button/card must NOT activate it.

Purchase/equip/destructive actions need sensible protection without confirmation spam.

==================================================
14. TEXT / DIALOGUE / NUMBERS
==================================================

Review ALL player-visible strings and numbers.

Audit:
- dialogue
- bosses
- merchants
- events
- tutorials
- descriptions
- item names
- flavour
- tooltips
- buttons
- errors
- confirmations
- notifications
- trophies
- lore
- run summaries

Fix:
- spelling
- grammar
- awkward AI phrasing
- repeated jokes
- forced humour
- unclear instructions
- inconsistent terminology
- lore contradictions
- overflow
- text covering gameplay

Numbers must use sensible rounding and formatting.

Hide internal/debug numbers from normal players when they add no value.

==================================================
15. CANON / CREATIVE IDENTITY
==================================================

Respect established Lootlings canon/world bible/voice bible.

Creative north-star remains ORIGINAL with high-level inspiration from:

- Borderlands 2/3 strongest, 1–4 overall
- Diablo 1/2/3 strongest, 1–4 overall
- Elder Scrolls
- Witcher 3
- LOTR
- D&D
- Overwatch readability/character appeal
- broad transformative pop-culture Easter eggs

Tone:
- cheeky
- smartass
- witty
- occasional fourth-wall
- occasional adult humour

Avoid:
- generic AI jokes
- forced memes
- childish randomness
- every sentence being a joke

Never directly copy protected characters/assets/dialogue/UI/music/lore.

==================================================
16. AUDIO
==================================================

Review:
- playable voices
- creature voices
- enemy voices
- boss audio
- weapons
- bows
- spells
- elemental effects
- impacts
- UI
- shops
- rewards
- chests
- ambience
- music

Check:
- wrong identity
- repetition
- fatigue
- clipping
- mix
- masking
- placeholder/cheap feel
- missing feedback

Keep licensing/provenance intact.

Do not claim final music complete if it remains provisional.

==================================================
17. VISUAL / VFX / PRESENTATION
==================================================

Review:
- characters
- enemies
- bosses
- weapons
- arrows/projectiles
- spells
- effects
- loot
- currency
- chests
- impacts
- rarity feedback
- notifications
- backgrounds
- HUD
- transitions

Remove remaining:
- debug shapes
- obvious placeholders
- broken layering
- backwards weapons
- clipped weapons
- wrong projectile origin
- unreadable VFX soup

Maintain mobile readability.

==================================================
18. SAVE / LOAD / ANDROID LIFECYCLE
==================================================

Test where possible:
- new save
- existing save compatibility
- purchases
- rewards
- hideout save
- background/resume
- close/reopen
- duplicate payout protection
- recovery behaviour

Do not destroy existing player saves.

Clearly document anything only a physical phone can verify.

==================================================
19. PERFORMANCE
==================================================

Check evidence for:
- frame spikes
- allocations
- repeated loads
- excessive audio playback
- VFX overdraw
- leaking nodes/timers
- scene cleanup
- memory growth
- expensive loops
- debug logging
- production test overhead

Optimize only where evidence supports it.

==================================================
20. FINAL QA / RELEASE-CANDIDATE GATE
==================================================

After fixes:

Run focused regressions for changed systems, then ONE comprehensive final acceptance suite including:

- parser/static checks
- combat
- DPS/TTK
- economy
- RNG
- roster
- bosses
- events
- merchants
- rewards
- save/reload
- touch/swipe
- UI overflow
- text/dialogue
- audio
- native visual review
- phone/tablet layouts
- Android ARM64 export
- signing
- 16 KB alignment
- package/resource verification

Do not weaken tests simply to achieve green results.

Fix invalid tests when objectively invalid.
Fix the game when objectively wrong.

==================================================
21. FINAL ACCEPTANCE QUESTIONS
==================================================

Before declaring finished, evaluate:

VETERAN DEVELOPER:
Would I knowingly hand this build to outside testers?

VETERAN GAMER:
Can I break it, exploit it, or solve the economy too easily?

NORMAL GAMER:
Do I understand what I'm doing, and is it actually fun?

MOBILE PLAYER:
Can I tap, swipe, read and play comfortably?

==================================================
22. FINAL DELIVERY
==================================================

Report:

- what was audited
- what was fixed
- what was changed
- code/files cleaned
- balance findings
- DPS/TTK findings
- economy findings/changes
- RNG findings/changes
- roster changes
- enemy/boss changes
- loot/item changes
- UI changes
- text/dialogue/lore changes
- audio changes
- visual/VFX changes
- performance findings
- save/lifecycle findings
- genuine remaining blockers

Provide:
- Git checkpoint(s)
- working-tree clean confirmation
- exact Windows APK path
- exact APK filename
- smallest S23 Ultra test
- smallest S24 Ultra test

Physical S23/S24 testing remains the final acceptance gate for:
- real touch feel
- heat
- frame pacing
- speaker/audio feel
- Android lifecycle/device-specific issues

Do not falsely mark those PASS before the phones are tested.