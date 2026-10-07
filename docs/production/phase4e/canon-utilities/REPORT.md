# Phase4E canonical utility integration — 2026-10-07

**Phase4E continues; full acceptance HOLD.** Implementation `585c24cd3333b40d52e65e71395ebe7ffc3969ab`. Separate QA/evidence SHA is the commit adding this report. Prior `18b566243488101ef5cf91dc50748e0f769e7c4a` delivery remains preserved. No Phase4F, redesigned identity, new gameplay type, damage/timing/economy/odds/save change.

## Actual runtime delivery

Eight original-pixel transparent exports from three accepted Phase2 master sheets: jewellery/relic/consumable, chest/shrine/merchant props, and spell/reward VFX. Same source tree and extraction/masking pipeline as v35; no handoff bodies, generated substitutes or recolouring. Original RGB and proportions retained, recorded alpha-only neighbour exclusions and four-pixel gutters. [Source/export evidence](source-exports.json) · [composited extraction review](exports.png).

| Approved export | Runtime integration |
|---|---|
| `memory_hourglass` | Memory Archive central illustration, between its explanatory line and filters. No timer, daily gate or consumable implied. |
| `trophy_dais` | Trophy Archive header illustration; existing category badges, secret masks and progress retained. |
| `contract_banner` | Local Contracts header; existing jobs, claim/reward rules and written descriptions retained. |
| `courier_cache` | Merchant Stash Expansion illustration. Loose floating placement rejected during review; capacity/cost/confirmation and purchase safety remain unchanged. This is luggage/capacity art, not a new cache reward. |
| `fault_seal` | Echo Invoice and Fault Script heavy-echo rune cards, shared item icons, owned-gear Notes, merchant/Stash and drops. Replaces their generic Arcane category fallback. Existing named rune glyphs remain protected. The illustration does not grant Fire damage or change signatures. |
| `healing_wreath` | Existing Siege healing-service control. Existing crystal ward and fire-arc art also distinguish prism/leech services. Icons clear on every subsequent panel opening, including spinner/mode/extraction controls. |
| `fire_missile` | Fire magic projectile source art replaces code-shaped missile. Rotation is local to this visual layer; same flight, origin, speed, lifetime and contact. |
| `arcane_comet` | Arcane magic projectile uses an actual flying source motif instead of a stationary ward motif. Both missile facings captured; no actor-facing override. Existing Frost, Corruption, physical arrows/bolts/sling and all weapon sockets retained. |

Production exports: `art/production/phase4e/items/`, `props/`, `vfx/`. Eight newly integrated exports; two already accepted service motifs reused. This closes the selected utility/missile group, **not the entire source tree or Phase4E**. It does not claim new playable, Wanderer, enemy, elite, miniboss, boss or NPC action states. Previous seven canonical neutrals, five Wanderer bodies, authored heavy poses and v34's nine-cell action reduction remain intact. Existing environments, NPC/merchant portraits, Home, armour/equipment, authored dialogue and lore remain protected.

## Inventory / remaining requests

| Unit | Start | End |
|---|---:|---:|
| Accepted extracted assets | 112 | **120** |
| Missing delivery / TEMP art cells | 3,056 | **3,056** |
| Playable missing cells | 2,318 | 2,318 |
| Other missing actor cells | 738 | 738 |
| Body/view bundles | 106 | 106 |
| Complete support packages | 165 (82 right / 83 left) | 165 (82 right / 83 left) |
| New combat TEMP cells resolved | 0 | **0** |
| New missing-art requirements introduced | 0 | **0** |

Current generated inventory: 6,889 records / 6,159 launch slots / 3,103 LIVE_BETA / zero LIVE_FINAL. Manifest growth includes export records and runtime texture routes, not extra characters or fabricated completed states. [Exact request package](../../NEEDS_NEW_CANON_EXPORT.json) remains authoritative and retains entity/state/purpose/facing/equipment/canvas/transparency/scale/baseline/hand/VFX/filename/source/runtime destination/priority contracts. No absent state is silently closed by a utility icon.

Remaining exact external-art gates: established wingless/coiled Hoard Dragon continuous-tail body and required states; true weaponless Moonkip with intact paws; missing canonical facing/action/recovery/hurt/defeat/victory and support/paired-hand layers; distinct named regional enemy/boss states; current NPC authored activities. Do not erase hidden equipment/anatomy, mirror asymmetry, substitute similar creatures or promote TEMP rigs. Non-art gates remain save semantic/cross-store/process-death acceptance, audio mastering/perceptual acceptance, physical S23 performance/lifecycle/input and final owner visual acceptance. Independent repo-side work remains queued; device testing is not a development stop.

## QA

[24 native captures](GALLERY.md): actual game UI at 1080×2340 and 1200×1920, desktop GLES3, disposable saves. Full-resolution JPEG94, no resizing. Rune and projectile captures are controlled previews; left/right labels specify forced missile flight, **not** forced actor staging or ordinary seeded outcomes. Actors retain real target-facing logic. Service capture executes the actual event handler and uses real current/new values and costs.

- Native delivery `canon-utilities-delivery-36c0992bc2`: exit0, zero errors, 20.15s. Actual immutable rune IDs, source-route checks, Archive/merchant/contracts, actual service text, drag does not heal/charge, KEEP MOVING changes neither wallet nor HP, utility icons cleared on mode switch, both missile directions.
- Targeted `canon-utilities-regressions-d41118dd65`: item art, mobile gestures, Phase4B reward/save rules, Phase4E visible controls, RC save and complete weapon-fit fixture all pass, zero errors.
- Eight canonical negative-guard tests pass. Frozen11 sources, rejected5 boards, accepted246 pose rows preserved; no boss frames approved. Master freshness guard:122 inputs; registry:834 identities /814 routes.
- Eight source audits verify unchanged RGB, source/export hashes and transparency. Signed APK verifies all120 accepted imports and five accepted Wanderer bodies, excludes source/reference/test art. [Build receipt](build-receipt.json) · [compiled modules/import proof](qa/apk-content-proof.json).
- Native inspection rejected floating luggage placement, refined neighbouring source fragments, confirmed full service comparisons/costs fit, and corrected a fixture-only missing Hideout dismissal before rune reward captures. Earlier exploratory captures are superseded; gallery uses the final run only.

No physical-device FPS/thermal/GPU/lifecycle/process-death or final visual/audio approval claimed. No new body art or full roster/enemy/boss completion claimed.

## Android / checkpoint

**v36 / `0.4.27-phase4e-canon-utilities`**

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-utilities-debug.apk`

146,553,570 bytes (~139.76MiB), SHA256 `886fad6704f62c67d9a7c1c14c748926e2e121d07c6e636fd3c85cb3c1e31022`. Signed arm64 debug, SDK24/36, signature/16KiB alignment verified; device validated false. One completed APK export for the batch. Implementation `585c24cd3333b40d52e65e71395ebe7ffc3969ab`; separate QA SHA: `git log -1 --format=%H -- docs/production/phase4e/canon-utilities/REPORT.md`.

Scoped build/native QA passes; full Phase4E remains HOLD. No S23 work is required to continue independent repository integration. When owner retests, install over existing app without clearing data; inspect Memory/Trophy Archive, Contracts, merchant capacity, heavy-echo rune cards, Fire/Arcane spells and a Siege service; drag then leave service, pause/resume and return Home.

## Multidisciplinary full-phase sign-off

DESIGN: ISSUES (partial art/owner gates). BALANCE: ISSUES (full acceptance not renewed; unchanged). ECONOMY: ISSUES (unchanged; device/save acceptance open). ROSTER: ISSUES (2,318 missing cells). ENEMIES: ISSUES (regional proxies remain). BOSSES: ISSUES (Dragon/state assets). RNG: ISSUES (unchanged; broad distributions not rerun). UI/UX: ISSUES (scope native/input passes, owner/device open). NARRATIVE: ISSUES (canon retained; full acceptance not renewed). AUDIO: ISSUES (unchanged, perceptual/mastering open). MOBILE: ISSUES (layout/package passes, device open). QA: ISSUES (scope passes, full save/device/owner gates open). PRODUCTION: ISSUES (safe delivery, full Phase4E HOLD).
