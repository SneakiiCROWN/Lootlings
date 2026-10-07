# Phase4E canonical combat actions — 2026-10-07

**GO for scoped S23 owner review; HOLD for full Phase4E/release acceptance.** No Phase4F. Preserved accepted v33 world/HUD/dialogue/spinner/mobile/save work. Implementation: `d5b7b87347c003a36ce73ef1e6ca20e75d71ce3c`. Separate QA/evidence checkpoint is the commit that adds this report; find it with `git log -1 --format=%H -- docs/production/phase4e/canonical-actions/REPORT.md`.

## Visible implementation

Eight transparent 512×512 exports from **five original canonical character sheets**, all integrated. These are actual attack-sequence illustrations, not idle portraits passed off as attacks. Original RGB is preserved before uniform resampling; precise alpha masks exclude sheet background, labels, ground and neighbouring illustrations. Source/export hashes, crop rectangles, mask outlines, scale, baseline and measured palm coordinates are in [source-actions.json](source-actions.json) and the production extraction/runtime manifests. No original sheet is edited, stretched, repainted or redesigned.

| Actor | New exact right-facing runtime coverage | Images | TEMP cells resolved |
|---|---|---:|---:|
| Emberhorn | Claws windup and strike | 2 | 2 |
| Moonkip | Twin Daggers windup and strike, original hood/anatomy and one source blade in each hand | 2 | 2 |
| Pebblewyrm | Claws windup, raised paw and grounded armoured silhouette | 1 | 1 |
| Glimmerfin | Staff windup; Wand and Orb strike/cast with an extended casting hand | 2 | 3 |
| Gloomlet | Claws strike, original violet furry Assassin | 1 | 1 |
| **Total** | **Actual source poses, no invented views/states** | **8** | **9** |

Production paths: `art/production/phase4e/lootlings/{emberhorn,moonkip,pebblewyrm,glimmerfin,gloomlet}/`. Total accepted extracted assets: **91 → 99**. New claws/casting frames reuse measured primary/secondary sockets and existing equipment overlays. Moonkip's actual daggers and Glimmerfin's source staff remain baked for those exact families; duplicate weapon overlays are suppressed. They do **not** claim modular weaponless bodies. Glimmerfin's sheet heading says “NO WEAPON” above a visibly staffed pose: runtime follows the actual pixels, not that erroneous label.

The renderer selects exact extracted ATTACK art at strike/commit. Late recovery explicitly requests RECOVER, which remains absent; it cannot reuse a source strike to manufacture a recovery frame. Missing opposite-facing views remain TEMP instead of mirroring asymmetrical weapons/anatomy. Movement/lunge eligibility, target-facing, paired sockets, damage, attack timing, RNG, reward odds, economy and save schema are unchanged.

Relic Beast and Mosskin's good authored heavy poses remain intact. All five Wanderers' accepted weaponless/neutral sources and authored heavy pose modules remain intact. **No new Wanderer, enemy, boss or NPC state is delivered in this batch.** Existing regional proxies visible in combat are not accepted by these captures. v33 presentation work is preserved rather than repeated.

## Source boundaries / exact remaining blockers

- Used only `Emberhorn_CharacterSheet_Canonical.png`, `Moonkip_CharacterSheet_Canonical.png`, `Pebblewyrm_CharacterSheet_Canonical.png`, `Glimmerfin_CharacterSheet_Canonical.png`, `Gloomlet_CharacterSheet_Canonical.png` under `art/reference/canonical/characters`. Existing accepted runtime gear, socket and VFX sources are assembled around these exports.
- The five handoff boards supply **zero new runtime bodies**. Rejected Moonkip/Gloomlet/winged-quadruped Dragon identities remain rejected. No new Art Bible body reinterpretation is introduced.
- Additional `art/reference/source/canonical_extract/characters/relic_beast_pose_reference.png` is a different brown/capybara-like body. Its filename does not authorize replacing the frozen current Relic Beast identity. Excluded.
- **Hoard Dragon remains REPLACE / NEEDS_NEW_CANON_EXPORT.** Additional `art/reference/source/canonical_extract/loot_boss/hoard_dragon_reference.png` is an orange winged quadruped, not the established wingless/coiled purple/obsidian/gold Dragon. It cannot repair the malformed source tail without redesign. Existing aspect-ratio correction is preserved; no tail repair, crop/FX concealment or boss-frame approval is claimed.
- Moonkip's true weaponless hands/body remain missing. New source dagger poses retain their weapons and cannot certify Bow/Staff/Sling/other-family support. Glimmerfin's existing neutral is weaponless; this batch's staff windup is not.
- Remaining exact left-facing windup/strike views, other weapon families, movement, follow-through, recovery, hurt, defeat and victory-return are open wherever the accepted manifests lack actual authored exports. Pebblewyrm claws strike and Glimmerfin Orb/Wand windup remain open. Gloomlet's prior right claws anticipation is retained; the new strike does not complete its full action/view package.
- Regional enemies, current Patch/Ilex/Sera/merchant activity states and bosses still require exact accepted identity/state exports as listed in the register. No broad reference-board creature/name is substituted for an established game ID. Mosskin's source shield-bash illustration has baked, occluding equipment; it cannot become a new weaponless/support pose by erasing covered anatomy.

**Exact production requests:** [NEEDS_NEW_CANON_EXPORT.json](../../NEEDS_NEW_CANON_EXPORT.json), [missing-cell manifest](../extraction/MISSING_ART_MANIFEST.json), [canonical replacement register](../polish/CANONICAL_REPLACEMENTS.md). Each remaining body/view bundle supplies game ID, state/facing/family restrictions, source identity, transparent canvas, ground baseline and target anchors. Missing authored palm coordinates stay OPEN; target rig coordinates are not invented source hand positions. Playable canvases are 512×512 RGBA, ground y496; full Dragon state delivery remains 2048×2048 RGBA with complete continuous tail and existing boss pivots.

## Measured art debt: frozen v33 → this batch

| Unit | Before | After |
|---|---:|---:|
| Exact missing delivery cells | 3,065 | **3,056** |
| Playable missing cells | 2,327 | **2,318** |
| Enemy/boss/current NPC missing cells | 738 | 738 |
| Body/view bundles | 106 | 106 |
| Whole support packages | 165 (82 right / 83 left) | 165 (82 right / 83 left) |
| TEMP action cells resolved in this batch | 0 | **9** |
| Extracted assets | 91 | **99** |

These units are not additive image counts. One cast image supports Wand and Orb, hence nine cells from eight images. No whole support/view package closes. Current generated inventory: **6,847 records / 6,117 launch slots / 3,061 LIVE_BETA / 3,056 missing / zero LIVE_FINAL**. Counts are regenerated from routes and source reflection; changing a phase label cannot silently turn an idle into an attack. Final owner aesthetic acceptance remains open.

## Native and automated validation

[Gallery](GALLERY.md): **84 full-resolution images** (quality94 JPEG, no resizing): 18 controlled before + 66 after at **1080×2340 phone** and **1200×1920 tablet**. Source PNG hashes and delivered image hashes/dimensions are preserved in [native_manifest.json](native_manifest.json).

- Controlled before comparison disables only this batch's eight action routes, revealing the existing TEMP rig for the same staged action. This is a controlled renderer comparison, not a separate v33 executable. Nine routes × two layouts before/after; seven preserved heavy actors × two layouts; 34 actual-update captures.
- Native desktop GLES3 captures were inspected against source sheets and current enemies/environment/HUD. Source identity, silhouette, source paws, baked dagger pair, staff shaft/head, Orb/Wand release hand, feet margins and separation are visible. Alpha refinement retains original Moonkip fingers and Glimmerfin shaft rather than painting replacements. Low-resolution sheet source detail remains a Beta quality limitation at full phone size; extraction is not final owner acceptance.
- Actual combat-update validation starts fresh isolated runs, advances `game._process(1/60)` and the real attack clock for five revised actors, checks that attacks fire, and captures the actual phases reached. These runs do not assign attack phases or force facing. They are controlled native gameplay-code steps, **not** physical S23 or human feel acceptance.
- `canonical-actions-live-e7ff8c5e6a`: native pass, 56.88s, zero engine/script errors. Includes all nine new routes, missing-recovery/opposite-view protections, seven preserved heavy actors and actual-update loops. Presentation sampling/capture leaves combat RNG, loot RNG, damage and interval unchanged.
- `canonical-actions-baseline-7df27fec93`: native controlled-before pass, 17.19s, zero errors.
- `canonical-actions-final-7e0c334313`: weapon-fit, mobile gesture/input, Phase4E visible UI and RC save regressions all exit0, zero errors, fresh isolated profiles. Existing player data untouched.
- Canonical negative guard: all eight tests pass, including rejected boards, frozen source changes and idle-as-attack rejection. Master integration and canon registry freshness/count/route guards pass (122 fresh inputs, 834 identities, 814 catalog routes). All 246 preserved authored pose rows remain protected.

Logs and APK proof are in [qa](qa). No physical FPS, thermals, process-death, lifecycle, speaker/headphone judgement or final art approval is inferred from desktop screenshots/tests.

## Android / owner retest

**v34 / `0.4.25-phase4e-canonical-actions`**

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canonical-actions-debug.apk`

143,575,082 bytes (~136.9MiB). SHA256 `aef320ebe5877db9729d5707d9b851f1bdaa55cbf9eef0ebecdd6087f8bc7d8b`. Signed arm64 debug, minSDK24/targetSDK36, 16KiB alignment verified. Reference/source/test art excluded. Receipt verifies all99 extracted imports and five accepted Wanderer bodies; delivered runtime action manifest equals the validated workspace manifest. [Build receipt](build-receipt.json) · [shipped action proof](qa/apk-action-proof.json). Device validation false; no external toolchain/global save changes.

Smallest S23 retest:
1. Install this APK **over the existing Lootlings app; do not uninstall/clear data**.
2. In ordinary combat, inspect Emberhorn/Claws, Moonkip/Twin Daggers, Pebblewyrm/Claws, Glimmerfin/Staff then Orb or Wand, Gloomlet/Claws. Watch anticipation/strike and hand contact; new art is specifically the right-facing states listed above. Check recovery and opposite-facing fallback remain honest TEMP rather than a mirrored or frozen attack.
3. Pause/resume once and return to Hideout; report any input leakage, save loss, clipping or stutter. A short recording of problematic states is enough. These scoped tests do not replace remaining broad physical-device acceptance.

## Multidisciplinary sign-off — full Phase4E

| Discipline | Status / evidence limits |
|---|---|
| DESIGN | ISSUES: visible source-action improvement; incomplete state sets and final owner acceptance |
| BALANCE | ISSUES: full sign-off not renewed in this art batch; damage/interval invariants pass, no tuning |
| ECONOMY | ISSUES: full sign-off not renewed; no prices/rewards/odds changes, save/input regression passes |
| ROSTER | ISSUES: nine TEMP cells removed; 2,318 playable cells and weaponless/support debt remain |
| ENEMIES | ISSUES: regional proxies/exact action exports remain |
| BOSSES | ISSUES: Dragon source tail and exact named-boss state packages remain |
| RNG | ISSUES: broad distributions not rerun for unchanged logic; capture leaves both RNG states unchanged |
| UI/UX | ISSUES: desktop phone/tablet/input regressions pass; physical S23 acceptance open |
| NARRATIVE | ISSUES: canon preserved; full text/voice acceptance not renewed here |
| AUDIO | ISSUES: unchanged licensed audio; final mastering/perceptual acceptance open |
| MOBILE | ISSUES: APK packaging passes; physical performance/lifecycle/input testing open |
| QA | ISSUES: native/automatic scope passes; device, save semantic/cross-store/process-death and owner gates open |
| PRODUCTION | ISSUES: safe implementation/QA checkpoints and exact remaining queue; Phase4E remains HOLD |

Continue independent safe queue work from this checkpoint. No missing asset or HOLD authorizes a redesign, reset or Phase4F.
