# Act I combat smoke interpretation — 2026-10-02

The previous **2/5** result is a limited automated-policy observation, not a player win rate or proof of balanced difficulty. The preserved Phase 2 smoke log shows all five runs reached wave 15; samples 2, 4 and 5 ended with zero player HP and a live boss, so those were actual combat defeats, not timeouts, reward-flow failures or stalls.

That fixture taps on a fixed clock, chooses upgrades by `(sample + level) % 3`, equips every drop without comparing it, and always leaves merchants without spending. Its 0.22-second tap threshold at 0.05-second simulation steps actually fires every **0.25 seconds** (four taps/sec), alongside automatic attacks. It reads no visual cue or attack anticipation. Its assertion only requires at least one completion.

The old five-run block seeds global randomness once and seeds gameplay/loot RNG **after** `start_run()`, when the first enemy has already been selected using the prior fixture/run RNG state. It also reuses the main scene after many unrelated smoke operations. Existing logs reproduced 2/5, but the seed labels alone did not define independently reproducible runs. This is a test-isolation/seeding limitation; it is not evidence that the combat RNG itself is nondeterministic.

The smoke fixture now seeds each global/game/loot/visual stream before starting and explicitly resets permanent bonuses, utility ranks, Act I route/patrol selection, Relic Beast avatar, starter equipment, debug overrides and tap-combo state for each sample. Its policy and minimum one-completion assertion remain unchanged, with wording corrected to describe loop coverage. Two separate complete desktop smoke launches now produce **3/5** with identical full logs and zero unexpected errors. [Corrected smoke output](smoke-fixed.log), [repeat runner result](smoke-fixed-repeat-results.json). The changed count reflects a defined independent seed/baseline contract; gameplay difficulty was not changed.

## Focused diagnostic

`tests/combat_seed_diagnostics.gd` uses the guarded disposable-save boundary. Every sample creates a new main scene, restores starter equipment, pins Act I and normal single-enemy patrols, disables debug overrides, clears permanent stat bonuses and utility ranks, disables automatic frame processing, and seeds global/game/loot/visual randomness **before** starting combat. The same five seed triples run under three real-choice policies, then repeat from fresh scenes. Gameplay stats, drop tables and enemy difficulty are untouched.

| Policy | Wins | Replay result |
| --- | --- | --- |
| Original rotating upgrade choice, equip all drops, skip merchants | 3/5 | All five detailed timelines identical |
| Explicit sustain-first upgrade preference, equip all drops, skip merchants | 5/5 | All five detailed timelines identical |
| Same sustain preference, buy up to two cheapest affordable offers per stop | 5/5 | All five detailed timelines identical |

Thirty desktop Godot 4.7.2 headless simulations passed with zero unexpected engine/script errors. [Detailed seed, wave-entry HP, builds, items and final outcomes](combat-seed-diagnostics.json); [runner result](combat-diagnostics-results.json). A preceding restricted run hit the known root-certificate-store access error and is excluded from clean acceptance.

The focused rotating-policy losses were:

- Game/loot seeds 1003/2003: wave 13 Shardseer, 182.07 enemy HP remaining. Entered wave 13 at 36.03/88 HP; upgrades were ignite, wildfire, greed, splash, splash, execute, splash, ignite, greed, execute. No regeneration/lifesteal/armour choice. Automatically equipped Mimic Mallet and left 777 Scrip unused.
- Game/loot seeds 1004/2004: Hoard Dragon, 2665.18 enemy HP remaining. Entered wave 15 at 95.07/100 HP; had only one regeneration and one lifesteal upgrade, with several splash/fire choices and no armour. Left 829 Scrip unused.

The outcomes show that build choices materially affect survival and that completion remains possible with the existing rules. Merchant buying did not improve the five-sample win count beyond the sustain policy, although it changed gear, timing and remaining HP. These small deterministic samples cannot establish population balance or certify every build; no difficulty reduction is justified merely to make all smoke seeds win.

Treat the historical 2/5 as expected losses for an indiscriminate QA bot plus an inadequate independent-seeding contract. The focused fixture now distinguishes determinism, combat defeat and loop completion. Human combat-readability and touch acceptance still require native/device observation: the bot cannot perceive telegraphs, silhouettes, text, timing feel or touch errors. Keep actual difficulty intact and evaluate weak build choices against player feedback before any balancing change.

Reproduce with `tools/run_qa.py --only combat_seed_diagnostics --label combat-diagnostics` using desktop Godot and the bundled/installed Python. The fresh-instance repeat comparison is the acceptance condition; a specific win count is descriptive, never a target to tune damage around.
