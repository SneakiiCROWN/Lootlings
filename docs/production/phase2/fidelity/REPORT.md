# Player-facing fidelity delivery — 2026-10-03

Implementation checkpoint: `a1ceabe`, on the preserved `codex/phase2-vertical-slice` branch. Initial status was clean; preceding mobile/tablet, save, combat, branding and correction checkpoints remain intact. No AI-generated final art, new balance rules or architecture replacement in this pass.

## Fixed

**Species reactions:** replace universal exertion/hurt/death routing with fourteen nonverbal species/body profiles, attack/hurt/death roles and four variants per role: 168 new recorded/designed PCM48 sounds. All twelve playable identities and every rendered enemy/boss family have explicit routing. Creature banks contain no human pain source. Attack calls stay quiet and rate-limited; pain/death can claim a busy SFX slot. The existing six-player pool, buses, limiter and weapon sound families remain. Seventeen superseded generic reactions and import records are preserved under `art/source/audio/superseded_human_reactions`, excluded from import/export; their licensing/hash records remain in `sources.json`. Current shipped bank: **325 SFX + four ambience loops = 329 PCM assets**, 12,952,132 PCM data bytes measured natively. Music remains provisional.

| Identity / rendered family | Voice treatment |
|---|---|
| Relic Beast | Bright small-beast growl, quick attack, cloth/rustle accent |
| Emberhorn | Warm assertive growl with restrained fire texture |
| Mosskin | Slow low organic growl with woody creak |
| Moonkip | Quick real-cat calls, light cloth accent |
| Pebblewyrm | Low, weighty growl and stone contact |
| Glimmerfin | Soft real-cat calls and light watery/glass accent |
| Gloomlet | Dry lower cat call with restrained shadow breath |
| Vault Runner, Velvet Astrologer, Nightstage Drifter | Light nonverbal breath/cloth family |
| Ruin Warden, Ashtrail Hunter; Grump Knight | Heavier human vocal/armour family |
| Skirmisher imp; hexer | Small imp growl; airy nonverbal hexer breath |
| Mossback brute; Emberworks tank | Low woody brute; dense metal/forge growl |
| Hoard Dragon and currently reused dragon bosses | Long low dragon growl, restrained fire accent |
| Mossglass boss; Cinder Crown boss | Root/wood family; forge/metal family |

Routing follows the actual rendered species, independently of weapon class and affixes. Campaign bosses that still reuse the dragon body share its family; this is not a claim that their distinct lore has received unique authored art or bespoke performances. Variation uses selected recording windows, body-size pitch, room-noise filtering, bounded fades and low material layers, without robotic modulation or generated voices. Source authors, URLs, licenses, excerpt transformations and input/output hashes are preserved in [licenses](../../../../art/audio/production/LICENSES.txt) and [manifest](../../../../art/audio/production/sources.json). New source pages: [Darsycho — Monster snarls](https://opengameart.org/content/monster-snarls), [Kerzoven — Cat Purr & Meow](https://opengameart.org/content/cat-purr-meow). Subjective fatigue/character appeal on phone speakers still needs the owner’s listening test.

**Bow direction:** correct limb mirror/rotation, grip and forward projectile socket for both facings; remove conflicting paw/shield stance rotations. Derive held limbs from the existing approved bow export by removing its static painted string between retained ties. Original pixels/source and complete inventory icon remain. Runtime draws one tensioned string behind the grip and a forward nocked arrow; windup pulls the string back, fire removes the nock, recovery briefly vibrates the string. Held import is limited to 512. Native evidence covers **all twelve actors × both facings × five phases = 120 captures**: idle/nocked, draw/windup, fire, flight, recovery/impact. Numeric checks also require string behind grip and socket beyond limbs. The backwards bow issue is corrected. Genuine string-pulling/support-hand body poses remain an art blocker; geometry is not anatomical completion. Left is an explicitly labelled preview because current Act I places the opponent to the right.

**Projectiles:** original code-drawn relic arrowhead, outlined shaft, bronze collar and split fletching; crossbow gets heavier bolt detail, sling a faceted stone, staff/wand a luminous shard, orb a partial orbital seal. Actual travel direction sets orientation. Physical, fire, frost, lightning, poison, corruption and arcane use restrained distinct trails/colours and brief impacts. Impact lifetime is 0.24 seconds, capped at sixteen records. Live identity reads the existing dominant build, Frostbell Chime signature or magical family; captures deliberately force every presentation palette. Corruption is an available visual theme, not a newly introduced damage mechanic. Damage, cadence, travel timing and RNG stay unchanged.

**Drops:** combat Run Scrip uses its actual currency icon, XP a distinct memory wisp. Equipment/material-like items use real canonical weapon/item/slot art, a floor shadow, rarity seal, restrained rarity shaft/glints and outlined name/type captions rather than debug circles/plates. Every existing drop rarity and weapon/armour/charm/rune presentation is captured, along with actual combat payouts, chest ejection, boss choices and reward cards. Permanent Gold/Scrap/Shards keep canonical result/menu icons; their existing payout system is preserved, not converted into a new physical-drop mechanic. Approved shared slot art remains where individual item art does not exist.

**Review follow-ups:** floating combat/reward text now measures its width and stays inside the arena; the visibly clipped “THE HOARD OPENS” message is fixed. Character selection replaces “CANONICAL” / export terminology with player-facing style/build copy. Existing strong body art, UI materials, dialogue, icon/splash branding, touch ownership, inspect/confirm economy protections and save behavior are preserved.

## Native review and regressions

[Portable accepted results](accepted-results.json), [capture index](evidence/README.md), [matrix report](evidence/matrix-report.json).

- **2,592 rendered samples:** twelve actors × twelve weapon families × nine states × two facings, twenty-four actor/facing sheets inspected. Includes idle, ready, movement, windup, strike, impact, recovery, hurt and defeat. Validates current renderer and exposes remaining art debt; does not approve missing anatomy.
- **162 focused visual/socket cases:** 120 bow phases plus 42 ranged-family/palette cases. Native projectile flight/impact examples, actual enemy-death payouts and all four item rarities inspected. Focused clips use real combat functions with controlled fixture state.
- **Actual native audio hooks:** attack/hurt/death for twelve players, plus 27 enemy/miniboss/boss contexts across Act I/Mossglass/Cinder and archetypes. Live output is captured in [combat-voices.wav](evidence/combat-voices.wav). Busy twelve-weapon/combat/reward mix passes: peak **−0.80 dBFS**, RMS **−23.32 dBFS**. Routing/PCM/mix checks are not human listening approval.
- **136 final native screens:** 68 at 1080×2316 and 68 at 1200×1600; combat/HUD, bars, selectors, menus, shops, reward decisions, bosses, chest, notices, settings, lore, archives, effects and new drop/projectile examples reviewed. Final layout recaptures include the hoard-text and selector-copy fixes. **22 native size/cutout/input cases** preserve expanded scenery and safe combat/UI transforms.
- Fourteen broad headless regression fixtures pass; latest audio-bank/fidelity checks and combat/touch/reward follow-up pass. Native mobile layout, full matrix, Act I flow, focused fidelity and audio mix pass. Only save-recovery’s two intentionally corrupt-file diagnostics are expected.
- Earlier fixture failures were corrected, not counted as acceptance: wrong debug-drop method/source-size assumption, SFX pool exhaustion between artificially rapid hook assertions, and boss hurt cadence needing the fourth attack. Original logs remain in isolated QA storage. First successful APK was superseded after the two native screen-review fixes.

The old **2/5** combat smoke finding is already resolved in [seed diagnostics](../COMBAT_SEED_DIAGNOSTICS.md): fresh baseline and seeding before foe creation repeat **3/5**, sustain policies reach **5/5**. Current smoke remains 3/5. Tapping-bot wins test loop coverage; they do not measure visual readability or define player difficulty. No difficulty reduction in this pass.

## Android and smallest S23 retest

Final APK: **`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase2-fidelity-debug.apk`**. Version code **4**, name **0.1.3-fidelity**, same package/debug signing key. [Build identity](android-build-report.json), [branding comparisons](android-branding-results.json). Official Godot 4.7.2 arm64 export, signing, 16KB alignment, SDK24/36, offline permissions, source/test/docs exclusion and navy system splash checks pass. Export checks compare all 329 imported audio assets, both accepted greatsword bodies and the final held bow byte-for-byte with local imports, and require all three fidelity modules. This is a device-test debug APK, not release signing or physical acceptance.

1. Copy the APK to the S23 and open it in My Files; install **as an update** over Lootlings. Keep existing app data.
2. Use a bow with Relic Beast, then a small creature such as Gloomlet/Moonkip. Watch idle/draw/fire/recovery, listen to attacks/pain, inspect elemental shots as available, then ordinary loot and a chest/boss reward. Report any backward bow, human creature grunt, obscured shot/drop or harsh/repetitive sound, with character/weapon and a short recording if possible. Gear/availability follow your existing progression; do not reset the save for this test.
3. Swipe a long menu and drag off an action button; verify no purchase/equip or combat attack leaks. Play about ten minutes, Pause, background for thirty seconds and return; finish a run, close/reopen and check committed gear/currency. Open combat **Pause → TEST REPORT** and send a screenshot plus any hitch/heat/audio/edge issue.

No attached physical device was validated in this pass. Actual S23 loading, frame pacing/FPS, PSS/thermals, sound quality, cutout/text readability, touch feel and Android lifecycle require these tests. Desktop RTX native rendering and synthetic events do not certify handset performance.

## Genuine remaining blockers

- **Authored anatomy:** 82 right / 83 left support-hand/paired combinations remain. Bow draw hands and two-handed/paired creature poses need approved body exports; Moonkip needs weaponless art to remove its baked daggers. This pass does not paint substitute paws, mirror unsuitable asymmetric anatomy or falsely mark them final.
- **Animation/art:** unique lore-matched boss bodies and authored attacks/hurt/death, actual death body exports, articulated opening chest, broader final environment/prop and wardrobe acceptance; sharper Gloomlet portrait master and individual item art where approved shared icons remain. Current body motion/VFX cannot replace missing authored anatomy.
- **Audio/device/release:** final music and subjective handset audio acceptance, measured mobile memory/pacing/thermal budgets and release signing. New species banks remove the wrong universal human grunts but remain subject to the owner’s sound-quality review.
- **Persistence:** live expeditions still do not resume after process death; semantic/cross-store save hardening remains separate. Existing committed progression and suspend/resume protections pass current regressions.

Next production work: owner S23 retest of this exact APK, then focused approved bow draw/support poses and weaponless Moonkip, followed by boss animation/music. Do not repeat completed mobile, branding, save or fidelity implementation.
