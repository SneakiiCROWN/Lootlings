# 0.4.64 foundation acceptance â€” scoped checkpoint

Baseline: live local and remote branch both44de7194 (0.4.63). Owner project.godot, newline-only relic_chase_meter.gd/tools/run_exported_native.py changes, untracked canon/source packages and rollback builds preserved. No reset, clean, copied checkout or art regeneration. The latest owner foundation directive overrides older Gremlin/seasonal sequencing.

Implemented two connected save-safety repairs. Stash Equip and Salvage now roll back inventory after refused persistence, retain selected gear and show an in-place retry message. Achievements, success feedback and analytics occur after saving. Successful Stash equip records the existing optional equipment tutorial practice. Owner item grants restore stash and RNG on failure; Scrap and Sigil shortcuts reuse existing bounded transaction-aware controls. Save test reports actual persistence failure. Existing F1/SHH access and save scopes remain unchanged.

Native touch review caught a first implementation mistake: refreshing the Stash error closed its detail panel. The error now stays in the selected detail, does not accumulate duplicate messages, and the same Equip button retries. Four phone/tablet/desktop captures were inspected. The initial fixture also pressed during the deliberate180ms opening guard; corrected timing preserves that guard. A headless owner fixture needed an explicit integer annotation. Failed attempts are retained separately, not counted as passes.

Source checks pass: all four equipment slots, failed/successful equip and salvage, reload and invalid indexes; isolated owner failure/success grants and unchanged normal files; four economy-journal boundaries; eleven-store backup recovery; existing economy/reward transaction coverage; spinner guards; all eight Mythical identities and full-stash recovery. These are simulated interruption tests, not physical power-loss or device acceptance.

Before the encounter RNG correction:84 actual seeded source combat routes: the original40 Act I runs now give11/20 expert and13/20 random wins (historical13/20 each). Wider44 routes give12/12 expert and10/12 random actor-family runs, and19/20 regional starter runs. Each actor has only one matched seed; each region has two. COMMON compatible family starters, automatic gear acceptance and fixed0.05s simulation limit generalisation. No god mode or balance/stat changes in these initial samples. Different core/weapon/selection cohorts cannot be compared as equivalent player win rates. Initial enemy HP divided by TTK in the inherited harness is an encounter-clearance proxy, not full damage throughput: healing, overkill, phase and conditional procs preclude an honest whole-game DPS claim. Outcomes/TTK/damage taken and full per-run observations are preserved in the two adjacent JSON records.

| System | Result | Evidence/limit |
|---|---|---|
| Stash equip/salvage persistence | FIXED & VERIFIED | Four slots, save refusal, reload and native touch retry across four layouts |
| Owner grant/Scrap/Sigils/save reporting | FIXED & VERIFIED | Failed writes roll back, successful writes reload; normal files unchanged |
| Backup and reward transaction regressions | VERIFIED PASS | Existing scoped automated fixtures; simulated boundaries only |
| Combat/perks/regional balance | PARTIALLY TESTED | Pre-correction84 source runs retained; corrected40-route cohort matches compiled; no balance approval |
| Encounter cosmetic RNG isolation | FIXED & VERIFIED |64 seeds/128 spawns; all40 source and compiled route observations match |
| Stash visual/usability quality | NEEDS OWNER ACCEPTANCE | Four native sizes reviewed; not whole-game professional acceptance |
| Full route, audio/accessibility/performance | PARTIALLY TESTED | Prior scoped evidence retained; full acceptance remains open |
| Physical S23 | NEEDS OWNER ACCEPTANCE | DEFERRED by owner; never passed and not blocking development |

Open priorities: matched larger seeded cohorts with actual named equipment/rarities and permanent upgrades; weak/strong/offence/defence/synergy policies; DoT/proc/stack/cap and frame-time diagnostics; optional Rift/Dungeon/Siege and late/endgame coverage; source/sink distributions and interrupted rewards; native whole-route/cutout review, audio listening and performance. Investigate failures before changing mechanics. Heavy art expansion, Gremlin and seasons stay below these dependencies.

Art closures0;2757 contracts and7178 artist requirements remain. No generated or staged image promoted to completion. Sole dashboard refreshed;50 dependency-registration gaps remain. Approved title music, branding, canon and existing equipment identities retained. Delivery verification is recorded separately. Final artifacts supersede the pre-correction candidates, which were not owner acceptance builds.

## Encounter random-stream correction

The first compiled matched cohort differed from source:13/20 expert and15/20 random, versus11/20 and13/20. Investigation found the encounter composition shuffle used the global RNG, also consumed by audio pitch/volume variation. Headless sound suppression therefore changed enemy order and subsequent combat outcomes. The shuffle now uses the existing seeded combat RNG with the same uniform permutation and weighted role budget. No sound, stats, loot probabilities, perk weights or save schema changed. Exact seeded sequences change intentionally to remove this cosmetic/gameplay coupling.64 seeds/128 spawns with differing global cosmetic consumption now match role order and combat-stream state. Source and compiled40-run cohorts are rerun after this correction; prior observations remain explicitly pre-correction evidence.

## Final delivery and priorities

Source checkpointa87e77e5 supersedes5510d3f2. Final0.4.64/code75 owner Android and Windows candidates exported.13 actual-PCK fixtures pass, actual standalone EXE120-frame startup passes, original Android launcher/adaptive/monochrome/splash and Windows16–256px icons checked against approved sources.15 rollback artifacts060–063 hash unchanged; title.ogg unchanged. No normal0.4.64 APK or Android runtime/device acceptance claimed. Final hashes/paths in DELIVERY.json. Native compiled Stash screenshots included separately.

After correction, the40-route source and compiled observations match exactly (including encounters, loot and perks), with10/20 core-biased heuristic wins and17/20 random wins. These internal expert labels describe a heuristic, not expert human play. Moonkip1/4 and Vault Runner0/4 heuristic results are investigation targets, not proof of a character/weapon nerf or buff requirement. Add sustain-first and named-gear/build-level cohorts before changing balance. Existing compiled economy fixture samples10000 drop opportunities and4000 merchant inventories; free roadside costs are correctly zero. Persistent source/sink affordability, inflation and actual progression speed remain PARTIALLY TESTED. All initial mismatches are preserved as PRE_RNG_CORRECTION evidence; a test completing is not balance acceptance.
