# Phase4E scoped canonical identity and visible integration — v41

2026-10-07. **GO for scoped S23 owner retest; HOLD for Phase4E/release acceptance. No Phase4F.** This is implementation and native evidence, not complete-art approval.

Implementation checkpoints: `82bfda435d2ab7095f98b83708f5d8c707ffacf0` (NPC authority/action continuity/HUD) and `5f99e190efbce037369b4343d3eb62018b357b4f` (remaining archive routes/two companion neutral exports). Separate QA checkpoint is the commit adding this report and its evidence. Earlier pushed Home/save/companion checkpoints remain intact. [Native gallery](GALLERY.md), [targeted results](qa/RESULTS_INDEX.json), [compiled APK route proof](qa/apk-compiled-code.json).

## Visible work completed

**Patch Brasswick and Ilex Quill:** exact original KEY NPCS panels, and only those two, extracted from `art/reference/canonical/characters/04_Lootlings_Art_Bible_Canonical_Reference.png` into the owner's requested dedicated `art/reference/canonical/npcs/Patch_Brasswick_Canonical.png` and `Ilex_Quill_Canonical.png`. The canon registry, replacement register and missing-cell references now point directly to those files. `art/npc_identity_authorities.json` records crops, hashes, original setting and scoped approval. No colour, anatomy or identity repainting.

Two exact runtime workstation panels installed: `art/production/phase4e/npcs/patch_canonical_station_panel.png` and `ilex_canonical_station_panel.png`. Hub station, dialogue, first meeting, memory replay, Memory Archive thumbnail and Field Notes use them. Old Patch/Ilex idle/portrait assets are preserved historically and removed from these active routes. The old shop painting baked a superseded goblin Patch: it is no longer selected; the shop reuses the accepted Hub environment and new Patch panel. Sera's accepted art stays unchanged. No planned Edda body, board-only label or Spinner identity was invented. Pack Peddler/Merrow retains its separate approved authority.

These are small opaque upper-body workstation vignettes, **not transparent full bodies or walking/sitting/work animations**. Painted counters stay at the station rather than walking as a body. NPC body debt closes zero cells; resolution and activity exports remain blockers. The broad Art Bible remains supporting reference only outside this two-entity approval.

**Playable combat continuity:** accepted source-derived strike/cast art no longer disappears merely because the root is still approaching its lane. The old stationary-root gate now applies to idle only; actual phase/facing/weapon constraints remain. Native moving Gloomlet, Emberhorn, Moonkip and Glimmerfin reproduce the old trigger and retain the correct authored action identity.

For exact missing states, normal gameplay no longer draws an alternate flat/procedural rig body, floating held weapon or procedural striking blade. It shows a canonical portrait **reference UI card**, clearly labelled `POSE ART PENDING / REFERENCE ONLY`. This is deliberately an unfinished presentation gate, not a canonical body or fake attack state. Rig/socket/projectile logic remains; explicit isolated QA opt-in `LOOTLINGS_QA=1` plus `LOOTLINGS_QA_RIG_PREVIEW=1` still enables technical prototype drawing with `RIG PROTOTYPE / QA ONLY`. Supported existing authored poses are retained. None of these cards reduces art debt.

**HUD and terminology:** character selector says `CHOOSE YOUR LOOTLING`. Long enemy names use two bounded readable lines; enemy HP/status placement reserves their actual height instead of reducing names to tiny type. Native `ARMOURED MOSSBACK BRUTE` with simultaneous status icons was inspected. Locked 12 weapon families, target-driven facing, staging, damage anchoring, attack timing and dedicated touch input remain intact.

**Companions:** all six final identities and 12 existing portrait/unlock previews remain registered. Two actual transparent, unmirrored neutral right-facing exports derived from the larger collection sheet:

- `art/production/companions/stonekith/stonekith_idle_right.png`
- `art/production/companions/puffnest/puffnest_idle_right.png`

Their original-pixel source exports live under matching `art/source/companions/<id>/` paths. Alpha-only recorded outlines remove the sheet setting; uniform scaling preserves anatomy/colour and fits the 256×256 canvas, central pivot (128,224), ground baseline 224 and horizontal bounds 32–224. `tools/extract_companion_idle.py` reproduces both; `runtime_manifest.json` records authority, hash, crop, explicit no-mirror restriction and native evidence. Collection previews now show these complete neutral silhouettes. They do not manufacture movement/reaction/opposite views or imply that unequipped pets inhabit Home. All six equip/follower gates remain closed. Auricub/Lunarwisp have unresolved clean silhouette/separate-effect acceptance; Pixrask/Breezewyn have intertwined effects/body presentation. No substitute frame was produced. Those exact requested exports remain open, alongside every missing action/view.

**Home/world:** separate `MAIN HUB → HOME → Leave/Back → MAIN HUB` scene architecture, shelf displays, character/loadout navigation and persistence remain preserved and passed native phone/tablet tests. A precise empty furnished Home interior request is in the consolidated manifest. The supplied landscape Home board contains all six pets and baked furniture; removing them cannot safely supply complete empty floor/furniture pixels. Existing accepted environment/prop art remains, with no room redesign or fake companion placement.

**Enemies/bosses/equipment/rewards:** accepted regional/backdrop/item assets and prior Fen Sneak right-neutral export are preserved. No new enemy/boss action cell was falsely closed. Hoard Dragon source-tail replacement remains open; aspect preservation is retained. All ten campaign boss source ratios and eleven boss memory accounts are checked, with exact current Act I authority preserved. Dedicated playable sheets remain primary; rejected Moonkip/Gloomlet/winged Dragon board bodies remain rejected. Stable `nightstage_drifter` and `mossglass_wilds` IDs are preserved despite contradictory owner-brief shorthand. Existing weapon silhouettes/support logic/paired logic/bow imports remain unchanged.

The existing six-tier Relic Engine presentation is retained and natively regression-captured for COMMON, UNCOMMON, RARE, EPIC, LEGENDARY and RED. These forced rarity captures are QA evidence, not reward-odds sampling; actual earned-spin/purchase/restart protection has separate fixtures. No odds, balance, economy, save schema or timing change. Current VFX and 456 packaged source-documented audio assets remain preserved; no new audio or perceptual-mastering approval is claimed in this batch.

## Native state selection and exact debt

120 staged native state probes: twelve actors × idle/strike/recovery/hurt/left-strike × phone/tablet. Actual target coordinates determine facing; `forced_facing_test=0`. Eight additional moving-action captures and two long-name HUD captures. These phase labels test current runtime selection, **not a claim that each has a separate final authored frame**. Existing compatible heavy pose modules may serve more than one probe.

| Actor | Accepted runtime route / 10 probes | Missing-pose reference UI / 10 probes | Remaining state/facing/family cells |
|---|---:|---:|---:|
| relic_beast | 8/10 | 2/10 | 206 |
| emberhorn | 4/10 | 6/10 | 205 |
| mosskin | 0/10 | 10/10 | 211 |
| moonkip | 4/10 | 6/10 | 212 |
| pebblewyrm | 2/10 | 8/10 | 210 |
| glimmerfin | 4/10 | 6/10 | 206 |
| gloomlet | 4/10 | 6/10 | 208 |
| vault_runner | 10/10 | 0/10 | 171 |
| ruin_warden | 10/10 | 0/10 | 171 |
| nightstage_drifter | 10/10 | 0/10 | 171 |
| velvet_astrologer | 10/10 | 0/10 | 171 |
| ashtrail_hunter | 10/10 | 0/10 | 171 |

Art accounting:

| Measure | Before → after |
|---|---|
| Existing accepted extraction-manifest exports | 125 → 125 (preserved) |
| New dedicated NPC reference sources | 0 → 2 |
| New exact NPC station-panel runtime exports | 0 → 2; zero full-body closures |
| Companion UI previews | 12 → 12 |
| Accepted source-derived companion body states | 0 → 2 |
| Companion exact remaining cells | 36 → 34; zero fully equip-ready companions |
| Main playable actor cells | 2,313 → 2,313 |
| Other actor/enemy/boss/NPC cells | 737 → 737 |
| Main missing state/facing/family cells | 3,050 → 3,050 |
| Shared body/view bundles | 106 → 106 |
| Complete support packages | 165 → 165 (82 right / 83 left) |
| Newly approved 35-entity high-res subset | 593 → 593; overlaps main queue, do not add |

No alternate identity, portrait card, UI panel or fabricated action is counted as a solved actor state. 864 weapon-fit probes pass with **one known technical support issue**: Glimmerfin / Staff / right, plus the 165 whole support-art packages. A test pass does not mean every combination is final visual art.

One consolidated production delivery authority: [NEEDS_NEW_CANON_EXPORT.json](../../NEEDS_NEW_CANON_EXPORT.json). It contains 3,050 main cells grouped into 106 bundles, plus explicit supplemental companion contracts (34 remaining) and one empty Home interior request. Every existing cell keeps canvas, identity source, facing, baseline, pivot, socket/support and no-mirror requirements. NPC cells now require the exact newly dedicated panels' identity. The 35-entity high-res queue is a subset, not separate additive debt. Master inventory: 7,040 records / 6,225 launch slots / 3,175 launch LIVE_BETA, zero LIVE_FINAL, zero currently confirmed EXTRACTABLE/CROP/ASSEMBLY slots; 132 fresh source inputs. Two companion neutral successes do not approve all remaining source candidates.

## QA and delivery

237 full-resolution native desktop captures: 144 phone (1080×2340), 93 tablet-like (1200×1920); 130 combat identity, 30 NPC, 20 Home, six companion and 51 UI/reward captures. These are native Godot renders, **not physical S23 footage**. Representative images inspected directly for identity, alpha/body bounds, text, station mapping and navigation.

Seven accepted isolated run groups in `qa/RESULTS_INDEX.json`: staged identity/moving-action review; current canonical/resident fixtures; current native NPC archive/shop review; final canonical/profile/economy/reward-restart/mobile-gesture/weapon-fit regressions; final Home/companion native routes; exact companion source native review; public phone UI/reward native regression. All fixture exits zero, no unexpected Godot errors. Eight art/registry/master/provenance/negative guards pass. A stale pre-approval resident fixture and an APK proof initially using the wrong catalog field were corrected to the actual workstation/art contracts, then rerun successfully; no gameplay was adjusted to satisfy them.

Actual APK imported NPC panels and companion neutrals match local validated imports. Compiled APK memory, Field Notes and resident portrait-resolver code executes successfully. Launcher icon/adaptive layers/splash match the intended packaged branding. Signature, 16 KB zip alignment, arm64-v8a, min SDK 24, target SDK 36 and source/test/reference exclusion passed. APK has no requested network/storage permissions. ADB found no attached device, so performance, lifecycle, sound perception and real touch/save acceptance remain open.

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-identity-debug.apk`

Version: **41 / 0.4.32-phase4e-canon-identity**. Size: **148318083 bytes (141.45 MiB)**. SHA256: `d08072f46db2232eff02c38644969fd8906724ee0eb18721fd33cd515ea8ff2a`. Debug owner-test build, not release approval. [Receipt](qa/APK_RECEIPT.json).

## Remaining gates and smallest S23 retest

1. Install v41 **over the existing app**; do not uninstall/reset saves.
2. Gloomlet/claws plus Relic Beast/greatsword: attack while returning to lane, hurt/recovery, both sides. Confirm accepted action identities persist; report any incorrect generic body. Missing-pose cards are known unresolved art, not intended final presentation. Try one ranged/cast weapon and watch contact/release alignment.
3. Hub Patch and Ilex: dialogue, Patch shop, Field Notes and Memory replay/thumbnail. HOME → companion collection → scroll both ends → Back/Leave to Hub. Stonekith/Puffnest neutral previews should appear; pets remain unavailable while their missing frames are open.
4. Play a normal earned/spend reward, view all tiers obtained naturally, switch app/lock screen/resume, then force-stop/relaunch. Verify selection, balance, purchases and earned rewards; report safe-area/text problems, accidental attacks, frame pacing and perceived sound weight/repetition.

Exact remaining blockers: canonical combat action/opposite/support/defeat/victory states listed in the queue; Patch/Ilex full-body/activity exports; full enemy/boss state sets; Hoard Dragon continuous-tail source replacement; Glimmerfin Staff right contact; 34 companion frames; approved empty portrait Home interior; final visual/audio owner judgement; physical S23 sustained FPS/memory/render/input/safe-area and save/lifecycle/process-death acceptance. Technical protections and existing successful integrations remain. HOLD does not mean these reference cards or partial sources are accepted final art.

## Multidisciplinary sign-off

| Discipline | Status | Evidence / remaining gate |
|---|---|---|
| DESIGN | issues | Identity continuity improved; unfinished combat bodies/telegraph presentation need authored assets and owner review. |
| BALANCE | pass, scoped invariance | No tuning/timing/stat changes; fixture damage/interval invariance checked. No new full balance acceptance claimed. |
| ECONOMY | issues | Targeted cross-store/purchase/reward restart passes; physical device/process-death acceptance still open. |
| ROSTER | issues | Twelve identities retained; exact missing combat states remain. |
| ENEMIES | issues | Approved mechanics/source routes preserved; 27 regional families still have high-res state debt. |
| BOSSES | issues | Ratios/memory routes pass; tail and authored state sets remain. |
| RNG | pass, scoped invariance | No probabilities changed; native fixture RNG states preserved. Forced rarity visuals are not distribution evidence. |
| UI/UX | issues | NPC/selector/name fixes and native touch/navigation pass; reference cards/panels/Home are not finished presentation. |
| NARRATIVE | pass, scoped identity | Dedicated authority wins, scoped NPC identities registered; established dialogue/lore preserved, no new lore invented. |
| AUDIO | issues | Packaging/source documentation preserved; final perceptual mastering/weapon and premium reward approval remains. |
| MOBILE | issues | Native phone/tablet layouts pass; physical S23 performance/lifecycle/input remains. |
| QA | issues | Targeted automated/native/build evidence passes; physical owner acceptance unavailable. |
| PRODUCTION | issues | Implementation/QA checkpoints preserved; Phase4E remains HOLD, no Phase4F. |

Tracked implementation and report changes are checkpointed separately. Owner-supplied pre-existing untracked duplicate source folders/archives are preserved locally and are not silently added to canon or claimed as remote backup. No resets, path migrations or accepted-source deletions.
