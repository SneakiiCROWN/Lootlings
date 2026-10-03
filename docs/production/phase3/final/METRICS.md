# Phase 3 measured tables

Godot 4.7.2; raw lab is one fixed 30-second seed. Combat cohorts use eight shared seeds per policy. Percentiles use nearest-index p10/p90 and the median; durations exclude menu dwell. Completed-fight DPS excludes unfinished fights, whose deaths remain in run outcomes.

## Raw starter weapon lab

| Starter | Sustained DPS baseline → final | 2s burst baseline → final | Attack interval baseline → final |
|---|---:|---:|---:|
| scrapfang_blade | 66.37 → 67.06 | 67.45 → 57.31 | 1.003s → 1.003s |
| scrap_axe | 70.38 → 71.30 | 69.90 → 60.28 | 1.003s → 1.003s |
| mimic_mallet | 69.87 → 70.59 | 71.00 → 60.33 | 1.003s → 1.003s |
| ruin_pike | 58.31 → 58.92 | 60.54 → 51.64 | 1.003s → 1.003s |
| moonbite_daggers | 49.19 → 49.07 | 56.96 → 42.09 | 0.578s → 0.578s |
| ruin_claws | 51.21 → 52.25 | 53.02 → 46.45 | 0.578s → 0.578s |
| bonebow | 52.73 → 53.18 | 56.51 → 39.07 | 0.592s → 0.592s |
| scrap_repeater | 53.21 → 54.78 | 53.83 → 47.17 | 0.663s → 0.663s |
| pebble_sling | 50.10 → 49.99 | 56.76 → 41.01 | 0.663s → 0.663s |
| glimmerstaff | 56.25 → 56.99 | 52.97 → 47.12 | 0.807s → 0.807s |
| ruin_wand | 60.96 → 61.70 | 56.38 → 50.53 | 0.807s → 0.807s |
| relic_orb | 58.00 → 58.74 | 52.97 → 47.12 | 0.807s → 0.807s |

## Paired weapons cohort

Completions: 297/384 → 341/384.

| Measure | Baseline p10 / median / p90 | Final p10 / median / p90 |
|---|---:|---:|
| seconds | 105.4 / 135.5 / 169.0 | 105.15 / 139.45 / 183.35 |
| damage_taken | 242.24 / 454.18 / 683.85 | 247.42 / 419.15 / 713.04 |
| min_hp_ratio | 0.0 / 0.51 / 0.86 | 0.0 / 0.75 / 0.84 |
| boss_seconds | 9.1 / 15.3 / 22.0 | 10.4 / 16.25 / 24.0 |
| foe_seconds | 0.75 / 1.85 / 4.7 | 0.75 / 1.85 / 4.85 |
| scrip_earned | 812 / 940.0 / 1044 | 953 / 1028.0 / 1232 |
| scrip_spent | 0 / 109.0 / 342 | 105 / 199.0 / 218 |
| scrip_left | 595 / 778.0 / 976 | 749 / 839.0 / 1127 |
| decisions | 16 / 20.0 / 22 | 22 / 23.0 / 29 |

## Paired campaigns cohort

Completions: 80/80 → 80/80.

| Measure | Baseline p10 / median / p90 | Final p10 / median / p90 |
|---|---:|---:|
| seconds | 97.35 / 123.77 / 161.85 | 95.35 / 133.3 / 172.05 |
| damage_taken | 168.91 / 370.02 / 711.92 | 198.15 / 342.54 / 634.13 |
| min_hp_ratio | 0.44 / 0.86 / 0.92 | 0.61 / 0.82 / 0.88 |
| boss_seconds | 9.2 / 13.32 / 25.0 | 10.1 / 15.38 / 24.4 |
| foe_seconds | 0.6 / 1.65 / 4.25 | 0.65 / 1.65 / 4.5 |
| scrip_earned | 904 / 933.0 / 1096 | 967 / 1009.5 / 1122 |
| scrip_spent | 0 / 124.0 / 342 | 105 / 248.0 / 342 |
| scrip_left | 632 / 852.0 / 957 | 640 / 760.0 / 916 |
| decisions | 18 / 20.0 / 24 | 21 / 25.0 / 29 |

## Paired actors cohort

Completions: 24/48 → 45/48.

| Measure | Baseline p10 / median / p90 | Final p10 / median / p90 |
|---|---:|---:|
| seconds | 102.7 / 241.78 / 425.4 | 112.05 / 201.45 / 414.5 |
| damage_taken | 214.47 / 1088.81 / 1668.33 | 249.96 / 713.58 / 2007.47 |
| min_hp_ratio | 0.0 / 0.35 / 0.9 | 0.36 / 0.69 / 0.86 |
| boss_seconds | 10.8 / 18.43 / 26.05 | 10.1 / 18.95 / 64.8 |
| foe_seconds | 1.0 / 3.55 / 11.55 | 0.85 / 2.9 / 9.8 |
| scrip_earned | 804 / 878.5 / 947 | 892 / 938.0 / 1180 |
| scrip_spent | 248 / 295.0 / 342 | 105 / 154.5 / 204 |
| scrip_left | 462 / 583.5 / 699 | 688 / 734.0 / 1075 |
| decisions | 20 / 21.0 / 22 | 22 / 23.0 / 24 |

## Final roster breadth

Each column has eight fresh seeds per actor. Shared and identity kits use tap/sustain; idle uses identity kit/sustain. This is policy sensitivity, not a player win-rate forecast.

| Actor | Shared tap wins | Identity tap wins / median seconds | Identity idle wins / median seconds |
|---|---:|---:|---:|
| ashtrail_hunter | 8/8 | 8/8 / 131.12 | 5/8 / 270.33 |
| emberhorn | 8/8 | 8/8 / 113.27 | 6/8 / 291.63 |
| glimmerfin | 8/8 | 8/8 / 147.22 | 3/8 / 255.7 |
| gloomlet | 8/8 | 8/8 / 166.38 | 4/8 / 270.75 |
| moonkip | 8/8 | 8/8 / 127.52 | 1/8 / 235.33 |
| mosskin | 8/8 | 8/8 / 122.0 | 3/8 / 310.6 |
| nightstage_drifter | 8/8 | 8/8 / 132.87 | 3/8 / 272.0 |
| pebblewyrm | 8/8 | 8/8 / 98.62 | 6/8 / 295.53 |
| relic_beast | 8/8 | 8/8 / 125.27 | 6/8 / 393.13 |
| ruin_warden | 8/8 | 8/8 / 124.4 | 8/8 / 383.08 |
| vault_runner | 8/8 | 8/8 / 133.95 | 4/8 / 288.55 |
| velvet_astrologer | 8/8 | 8/8 / 120.35 | 3/8 / 301.3 |

## Marginal contribution and incoming pressure

Core delta is additional 30-second stationary DPS at tag-count 3, not a per-tag multiplier. Range, multi-target splash and per-foe perks cannot be reduced to this stationary number.

| Family | Crit contribution DPS | Physical / Fire / Lightning / Poison DPS delta |
|---|---:|---:|
| greatsword | 4.48 | 21.16 / 26.78 / 14.12 / 12.43 |
| greataxe | 4.99 | 22.58 / 27.02 / 14.12 / 12.43 |
| maul | 4.72 | 22.27 / 26.99 / 14.12 / 12.43 |
| spear | 3.93 | 18.56 / 26.22 / 14.12 / 12.43 |
| daggers | 9.73 | 16.25 / 25.26 / 16.09 / 12.49 |
| claws | 8.93 | 15.70 / 25.73 / 16.09 / 12.71 |
| bow | 9.01 | 17.26 / 25.67 / 15.81 / 12.43 |
| crossbow | 8.14 | 16.99 / 25.93 / 15.53 / 12.55 |
| sling | 5.22 | 16.17 / 25.14 / 15.53 / 12.41 |
| staff | 3.36 | 15.80 / 28.15 / 14.68 / 12.38 |
| wand | 3.29 | 15.70 / 25.16 / 14.68 / 12.41 |
| orb | 3.29 | 15.70 / 25.13 / 14.68 / 12.38 |

110 incoming-pressure samples cover all ten regions, three regular roles at waves 1/7/14, plus every miniboss and final boss. Each 60-second trial uses an untrained Vanguard with inflated HP, no attacks and phase-one bosses. Incoming DPS range: 0.904–14.589. This estimates 100-HP pressure TTK, not actual lethal-run TTK. Both boss phases are covered separately by native action contracts.

Full per-sample arrays, failed outcomes, item luck ordering and min/max values are retained in JSON/JSONL. Do not conflate lucky loot with high final HP.
