# Phase 4D implementation and native acceptance

2026-10-05. Branch `codex/phase4d-visual`. Implementation `9e6a76b611b6f15f5d2d9485d65a3bfd39fbad17`; QA/report is a separate following commit. Frozen Phase 4C `0664e4e` was used as the branch base, then the already authorized and validated spinner `4d3ba2c` was carried forward by fast-forward. Original branches and APKs remain intact. No reset, discarded work or main merge.

## Visible result and remaining limits

Home's painted portal is no longer covered by a pill button. A large release-owned gate area and floor caption open Expeditions. Chest, Shrine, Archive desk and contract board have world-attached hit areas. Patch has restrained sparks and the current equipped weapon at the work area; Ilex has reading/page light and Sera has shrine glow. The flat experimental bench overlay was rejected after native review; existing painted furniture is retained. A canonical chest replaces the ambient debug-shaped chest. Existing bounded residents, life events, particles and lighting remain. Sparse bench/page cues follow the station cycle. No housing or pet subsystem.

Hero selection has a transparent stage, baseline shadow/light, larger aspect-preserved portraits, larger roster captions, clear Lootlings and Wanderers BETA tabs, prominent personality and trait, and optional origin. Human affinity remains readable text rather than new bespoke affinity art. Human portraits still fill less space because their approved silhouettes have different proportions; no body stretch. Canonical roster icons remain.

Patch's clipped speech was repaired by a taller panel and concise text. Human Home greetings now use actual character-specific dialogue. Vault is dry and practical, Warden protective, Drifter playful with a restrained flirt, Astro controlled and Hunter concise. Patch speaks as a craftsman, Sera offers grounded rest, and Ilex names the dead with dry humour. Creature dialogue/canon and mechanical traits are preserved. This is a targeted voice correction, not a claim that every old line was newly written.

Gear puts equipped slots before filters/inventory; detail stays optional. Forge uses Gearworks scenery and metal/brass cards, Archive uses Starfall scenery and parchment categories with canonical icons, and Contracts use pinned-paper cards with clearer gold rewards. Decorative children ignore touch. Region cards retain tier/lock/tracking and add short loot hints; tap still opens details. Siege and Dungeon launch panels now show destination art and concise extraction/route identities. Merchant/level-up/results are retained because their existing clean cards were readable in native review.

Combat's top HUD is shorter, pause remains a large touch target, HP and run currency remain clear, XP is a thin progress line with level nearby rather than an overlapping tiny fraction. One main enemy name/HP presentation moves toward the arena. Existing group/status/telegraph logic remains. Regional boss body, size, baseline, shadow, entrance/recoil limits and restrained accent motifs now vary; most regions no longer share one dragon. The clipped Furnace painting was rejected and replaced with an existing transparent forge-golem atlas cell. Regional reuse is explicitly BETA.

The Relic Engine has axle bolts, reel rims and mechanical cheeks. Its inflated empty progress block is now an eight-unit meter. Full/premium reveal, repeated-spin fast mode, Skip, Reduced Motion, pool disclosure, atomic delivery, sparks/fragments and RED forge all remain unchanged. No new final raster art, AI-generated art or copied franchise design.

## Before/after screen acceptance

Twenty named screens were captured before implementation at 1080×2316 and 1600×2560, then captured after. Every after screen was manually inspected in the native screenshot groups. Each row links a phone comparison; the identically named tablet comparison is available in `evidence/1600x2560-<name>.jpg`. Group sheets preserve the full screen compositions. Tablet sheets contain padding added by the evidence layout tool, not by the game.

| Screen | Phone and tablet manual review | Before → after / remaining weakness |
|---|---|---|
| [Home](evidence/1080x2316-home.jpg) | Reviewed | Portal exposed, physical touch areas and station activity; still painted scene plus reused cutouts |
| [Patch](evidence/1080x2316-patch.jpg) | Reviewed | Clipped line fixed; sparks/weapon at work area; canonical NPC body missing |
| [Sera](evidence/1080x2316-sera.jpg) | Reviewed | Warm distinct line, shrine light; canonical NPC body missing |
| [Ilex](evidence/1080x2316-ilex.jpg) | Reviewed | Distinct dry history voice, desk light; shared NPC art remains |
| [Lootlings](evidence/1080x2316-lootlings.jpg) | Reviewed | Larger staged hero, readable trait and roster; existing baked-prop debt remains |
| [Wanderers](evidence/1080x2316-wanderers.jpg) | Reviewed | Actor stage, stronger voice, explicit BETA; affinity is text, human art remains provisional |
| [Regions](evidence/1080x2316-regions.jpg) | Reviewed | Loot hints and taller cards; scrolling exposes fewer cards at once |
| [Siege](evidence/1080x2316-siege.jpg) | Reviewed | Destination art, extraction/chase copy; existing framed panel remains |
| [Dungeon](evidence/1080x2316-dungeon.jpg) | Reviewed | Route/target identities and art; locked actions correctly muted |
| [Gear](evidence/1080x2316-gear.jpg) | Reviewed | Equipped slots first, filters next, optional detail; baseline save has empty stored inventory |
| [Forge](evidence/1080x2316-forge.jpg) | Reviewed | Metal cards and Gearworks background; no newly authored forge character animation |
| [Archive](evidence/1080x2316-archive.jpg) | Reviewed | Parchment, icons, optional detail; bespoke books/discovery art still limited |
| [Contracts](evidence/1080x2316-contracts.jpg) | Reviewed | Readable pinned-paper jobs and currency cue; local board uses original simple code geometry |
| [Merchant](evidence/1080x2316-merchant.jpg) | Reviewed | Existing purchase protection retained; compact HUD, readable item/detail/action |
| [Combat](evidence/1080x2316-combat.jpg) | Reviewed | Slim HUD, enemy context nearer stage, larger visual breathing room |
| [Boss](evidence/1080x2316-boss.jpg) | Reviewed | Act I approved dragon retained; authored attack/hit phases still debt |
| [Verdant](evidence/1080x2316-verdant.jpg) | Reviewed | Correct baseline and explicit BETA; reused Mosskin remains provisional |
| [Level-up](evidence/1080x2316-level_up.jpg) | Reviewed | Clean existing cards preserved, compact underlying HUD |
| [Spinner](evidence/1080x2316-spinner.jpg) | Reviewed | Mechanical framing, thin progress meter, no overlap; existing premium/fast logic preserved |
| [Results](evidence/1080x2316-results.jpg) | Reviewed | Readable rewards/status/actions retained, compact underlying HUD |

Some encounter/item/card contents differ between presentation captures. These sheets compare layout, not seeded balance outcomes. No before/after DPS claim is inferred from them. The twenty native screens are developer fixtures in isolated saves, not screenshots of the owner's progress. Additional Gear/region detail and spinner-result captures remain in `.godot_test_data/phase4d/after/`.

## Boss and weapon evidence / exact canonical blockers

[Boss group one](evidence/bosses-1.jpg) and [group two](evidence/bosses-2.jpg) contain native idle/attack views of all ten campaign bosses. Full source captures are retained alongside. Existing entry, recoil/hit response and actual attack clocks were exercised; authored anatomical attack/hit frames were not created. The visual fit is improved, but no boss art PASS is claimed. Current proxies face the player and retain their proportions; Furnace no longer has clipped feet/slab art.

| Canonical boss requiring original final body | Current approved BETA reuse |
|---|---|
| Verdant Mirror | Clean Mosskin guardian |
| Lantern Jackal | Four-legged vault beast |
| Belljaw | Mossback brute |
| Drowned Engine | Armoured vault golem |
| Furnace Regent | Forge golem atlas cell |
| Redactor | Lantern Hexer |
| Unchosen | Grump Knight |
| Chainwarden | Grump Knight, differentiated accent but shared body |
| Hollow Crown | Hoard Dragon |

All nine need unique canonical silhouette/idle/ready/attack/hit/death and entrance treatment. Act I Hoard Dragon retains approved body art, but authored attack/hit phases remain needed for final animation quality. Verdant, Belljaw, Unchosen/Chainwarden and Hollow Crown reuse remain obvious when seen together. Visual proxy choice is not a lore redefinition.

Twenty-four actor sheets were manually inspected: seven Lootlings and five Wanderers, both facings, Bow/Crossbow/Daggers/Claws/Sling/Greatsword/Spear/Staff, six states each (1,152 samples). Fixtures verify actual equipped/pose family, valid body/weapon, no death sprite substitution and unchanged gameplay RNG. [Exact family/facing support debt](WEAPON_ART_BLOCKERS.md) and [machine-readable samples](evidence/weapon-matrix.json) preserve the flags. Native review includes real [right draw](evidence/bow_1_draw.png), [fire](evidence/bow_1_fire.png), [recovery](evidence/bow_1_recovery.png), and [left draw](evidence/bow_-1_draw.png), [fire](evidence/bow_-1_fire.png), [recovery](evidence/bow_-1_recovery.png). Correct bow/string/arrow direction is preserved; missing authored anatomy is still visible.

Patch, Ilex and Sera need distinct canonical NPC bodies/turnarounds and purposeful work/read/shrine animation. Patch/Ilex currently share recognizably similar red humanoid reuse. Final support/paired/ranged poses, weaponless Moonkip and Mosskin shield-side support solutions are required. No extra limbs, fake cutout edits or stretched hands were used to conceal that debt.

## Automated and native checks

Final focused regressions in [results](qa/phase4d-final-regression-acf9848a5c/results.json): Phase 4B, Phase 4C, Phase 4D, spinner, weapon fit, audio production and save recovery all exit 0 with zero unexpected errors. Save recovery deliberately logs exactly two malformed-fixture parse diagnostics. Existing progression, RED forging, atomic spin receipts, source licences and gameplay RNG isolation are covered. Difficulty, DPS, enemy HP, rewards, prices, loot odds and save/economy rules were not retuned.

Final [phone](qa/phase4d-final-phone-575def3e73/results.json) and [tablet](qa/phase4d-accept-tablet-6c37233f5f/results.json) native checks exit 0 with zero errors. Swipe does not select; deliberate tap opens Gear detail; Back dismisses speech/region sheets; gate/chest touch does not issue an attack; spinner settles to result. Existing release-owned gestures and purchase/equip/upgrade guards remain. Each layout uses a fresh native process and isolated save.

Final [boss native](qa/phase4d-boss-final-e00471b7a0/results.json), [weapon native](qa/phase4d-settled-weapon-proof-d71bf157c0/results.json) and [audio native](qa/phase4d-final-audio-9b93b3de31/results.json) also exit 0 with zero errors. No unrelated full-game simulation was repeated for this presentation-only tranche.

Ninety-frame desktop samples, VSync-bound: combat median 16.664 ms / p95 16.682 / max 16.790, 65 draw calls, 128.7 MB static / 278.1 MB textures; boss median 16.664 / p95 16.685 / max 16.697, 74 draw calls, 127.6 / 277.8 MB; phone Home median 16.666 / p95 16.695 / max 16.714, 72 calls, 141.8 / 305.6 MB; tablet Home median 16.665 / p95 16.695 / max 16.783, 71 calls, 154.8 / 332.0 MB. These are short desktop samples, not Android FPS, a memory budget sign-off or a long soak. Physical frame pacing, heat, background resume and speaker output remain open.

One baseline tablet run logged a Windows root-certificate-store sandbox error despite valid native captures; its log is retained. Final runs with normal Windows access are clean. Initial audio alias validation found an incorrect four-variant scrap alias where only one licensed variant exists; corrected before final checks. Screenshot viewers cached reused paths during iteration; final reviewed evidence has new paths and verifies actual held-family identity rather than trusting captions.

## Audio and engine fact checking

No new unlicensed samples. Existing 329 production PCM assets and source/license manifests remain. Sparse Home bench/page aliases reuse `scrap_01.wav` and `menu_open_01.wav` through saved Ambience controls at low gain. Boss reactions follow actual proxy body families: moss, brute, forge, hexer, humanoid armour and dragon, rather than adding human grunts to beasts. No new final music or voice master claim.

Actual native Home, Outer Ruins and Cinder boss combat were mixed through the Master bus at equal defaults, with zero discarded capture frames. Home peak −8.95 dBFS / RMS −31.91, outer −4.79 / −28.74, boss −1.50 / −23.68. Boss reaches the existing limiter ceiling without PCM clipping. RMS is not LUFS; sample count includes engine capture buffering and is not a calibrated wall-time audio duration measurement. These measurements show signal/headroom only, not a human listening/taste PASS. Recordings remain at `.godot_test_data/phase4d/audio/final/`. Final species/boss authored vocals, music masters and S23 mix/repetition acceptance remain debt.

Godot [Control documentation](https://docs.godotengine.org/en/stable/classes/class_control.html) supports the explicit `MOUSE_FILTER_IGNORE` decorative children and GUI input handling; visual draw order alone does not determine event ownership. Existing touch owner is preserved and tested. Godot [custom drawing documentation](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html) supports bounded code-drawn accents and explicit redraw; this informed the narrow custom meter rather than accepting the theme's oversized ProgressBar minimum. Native behavior was checked in Godot 4.7.2. No external game's numerical balance or protected design was copied, and no unsupported industry-practice claim was used.

## Multidisciplinary sign-off

PASS below is restricted to the listed preserved contract; it does not grant commercial release acceptance.

| Discipline | Verdict | Evidence / open issue |
|---|---|---|
| DESIGN | ISSUES | Visible hierarchy improved; thirty-second S23 feel comparison pending |
| BALANCE | PASS — preserved scope | No tuning; gameplay RNG isolation and existing Phase 4B/4C contracts pass; prior measured baseline retained |
| ECONOMY | PASS — preserved scope | Atomic spins, RED forge, save recovery and retained pricing/rewards pass |
| ROSTER | ISSUES | Larger select stage; support anatomy and BETA human art remain |
| ENEMIES | ISSUES | Readable native stage retained; final authored motion still incomplete |
| BOSSES | ISSUES | Improved proxies/facing/baselines; nine final bodies and authored combat poses needed |
| RNG | PASS — preserved scope | Cosmetic sampling does not consume gameplay RNG; loot/spin odds unchanged |
| UI/UX | ISSUES | Twenty phone/tablet screens reviewed; physical touch/owner preference and affinity art open |
| NARRATIVE | ISSUES | Distinct actual dialogue implemented; reused NPC bodies conflict with final identity |
| AUDIO | ISSUES | Legal species banks and bounded Home cues tested; final masters and device listening pending |
| MOBILE | ISSUES | Native layouts/gestures and signed aligned APK pass; physical S23 acceptance pending |
| QA | ISSUES | Focused regressions/native evidence clean; device recording, soak and lifecycle retest pending |
| PRODUCTION | ISSUES | Separate checkpoints and packaged evidence; commercial art/audio/device blockers remain |

**GO for S23 owner test. HOLD for production release.** Mandatory owner recording is still pending; no claim that native fixtures satisfy the physical thirty-second criterion. Stop here after pushing the QA checkpoint, without a new mode or expansion.
