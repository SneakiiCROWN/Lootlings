# Phase4E multi-category canon integration — 2026-10-07

**GO for scoped S23 owner testing; HOLD for full Phase4E/release acceptance.** Implementation `a69d300169081a943190a050c8ea156f13fc8208`. The separate QA SHA is the commit adding this report (`git log -1 --format=%H -- docs/production/phase4e/canon-content/REPORT.md`). Preserves v34 canonical action integration and all accepted v33 work. No Phase4F, reset, redesign, generated replacement body, balance/save/economy/odds/encounter change.

## New visible runtime integration

**13 transparent original-pixel exports**, all used, from three accepted `art/reference/phase2_master` sources: jewellery/relic/consumable sheet, chests/shrine/merchant props sheet, spell/reward VFX sheet. [Source crops, hashes, alpha exclusions](source-exports.json) · [export review](exports.png). Source RGB is unchanged, original crop resolution retained, four-pixel transparent gutters. Alpha-only foreign-fragment removal is recorded; no new anatomy, recolouring or invented canonical design.

| Category | Actual runtime change |
|---|---|
| Relics / reward cards / Stash / merchant / Notes | Eight real relic IDs now route to existing approved paintings rather than a shared generic charm glyph: Promise Bubble and Safe Aperture → ward orbit; Marsh Promise → verdant amulet; Receipt Ring → obsidian ring; Gilded Debt → azure/gold ring; Coffer Key and Courier's Appetite → existing treasure key; The Last Receipt → existing recipe scroll. Four new item images plus two previously accepted exports. Existing named item art remains protected. These shared compatible illustrations are Beta item presentation, not invented new gameplay or character identities. |
| Currency / Home HUD / menus / rewards / spinner | Permanent Gold and Star Shard icons use original coin-hoard and crystal art. Run Scrip remains its separate existing icon; XP remains the existing memory wisp. No currency conversion, balance, reward or wallet mutation. Labels and amounts stay unchanged. |
| Field Notes / owned gear / lore | Existing gear pages now show the resolved painted relic; a source map marks the Notes header. Existing item descriptions, signatures, affixes, stats and owned-item gating remain intact. No new or rewritten lore. |
| Dungeon / world presentation | Quiet Camp, Cursed Crossing and Final Vault cards use accepted camp, brass torch and vault portal cutouts. They retain actual route kinds, descriptions, heal value, encounter composition and progression. Portal is a destination illustration, never a substituted boss portrait. Camp is a static prop, not an invented rest animation. |
| Combat VFX | Lightning contacts use the source chain/crystal spark motif; Poison contacts use the source green cloud. Both fit the existing bounded contact area, on existing lifetimes. Frost magic uses a source crystal projectile oriented along its existing trajectory. Physical arrows, bolts, bowstring, sling, sockets and actor facing remain unchanged. No particles/simulation nodes or damage added. |
| Six-tier Relic Machine | Existing mastery result symbols now consume the painted Star Shard art; all Common/Uncommon/Rare/Epic/Legendary/RED presentations were captured. Gold is not a spinner reward kind; no new reward kind is invented. Existing machine materials, premium bursts, skip/pity/free-spin/charge/save protections are preserved, not reimplemented. |

Production paths: `art/production/phase4e/items/`, `props/`, `vfx/`. Seven new item/symbol exports, three props, three elemental motifs. Accepted extraction inventory **99 → 112**. Native review rejected a detached Home torch placement; it was removed before delivery and reused only in the labelled dungeon Risk card. No floating decorative prop remains from that experiment.

## Actors / canon boundaries / exact missing art

**No new playable, Wanderer, NPC, enemy or boss action export in this batch.** v34's eight canonical action images/nine TEMP cells remain integrated, as do the accepted seven Lootling neutrals, five Wanderer bodies and authored heavy modules. Weapon-specific frames remain restricted; no dagger/staff frame becomes weaponless, no idle becomes an attack, no asymmetric body is mirrored.

Targeted additional actor review: Mosskin's shield-bearing strike still has occluded equipment/anatomy; Pebblewyrm's ground-slam frame has source rocks/contact FX occluding a required paired paw. They cannot supply a correct modular two-hand state by erasing hidden pixels. Existing good authored poses remain. No rejected Moonkip/Gloomlet board, capybara-like old Relic Beast or winged/quadruped Dragon source is imported.

Hoard Dragon **still REPLACE**: exact established wingless/coiled violet/obsidian/gold body with one continuous anatomically readable tail; idle/named attacks/hurt/recovery/defeat, both facings, full uncropped transparent silhouette, 2048×2048 full-state delivery and current rig/boss pivots. Existing renderer aspect correction remains. No tail repair or proxy boss acceptance is claimed.

Other exact gates remain: Moonkip true weaponless paws/body; left/action/hurt/recovery/defeat/victory frames where absent; full paired/support hand layers; distinct named regional enemy/boss states; Patch/Ilex/Sera/current merchant authored activities. No new NPC, weapon family, region or biography from concept-board labels. Existing canonical portraits, current NPC art, region backgrounds, Archive memories, authored writing, weapons, armour/runes and accepted UI remain intact. This batch does not falsely claim those unchanged categories as new deliveries.

**One current production request package:** [NEEDS_NEW_CANON_EXPORT.json](../../NEEDS_NEW_CANON_EXPORT.json). Reusable body/view packages retain exact entity/state/facing/family, canvas, transparency, ground/pivot/hand targets and source-search evidence. Each exact requirement now also records purpose, weaponless/baked equipment restriction, source scale, allowed baked markings versus separate temporal VFX, filename, production/runtime destination, TEMP slot ID and priority. Missing real source-palm pixels remain OPEN; rig targets are not invented anatomy. [Underlying exact-cell evidence](../extraction/MISSING_ART_MANIFEST.json) and [named replacement register](../polish/CANONICAL_REPLACEMENTS.md) remain linked authorities, not separate competing counts.

| Debt / inventory unit | Before v34 | After v35 |
|---|---:|---:|
| Missing actor delivery cells | 3,056 | **3,056** |
| Playable missing cells | 2,318 | 2,318 |
| Other actor missing cells | 738 | 738 |
| Body/view bundles | 106 | 106 |
| Full support packages | 165 (82 right / 83 left) | 165 (82 right / 83 left) |
| Additional TEMP combat cells resolved | 0 | **0** |
| Accepted extracted assets | 99 | **112** |

The earlier v34 reduction **3,065 → 3,056 / nine action cells** is preserved. This batch replaces generic item/prop/effect presentation, which is not counted as missing combat-body art. Generated current inventory: **6,873 records / 6,143 launch slots / 3,087 LIVE_BETA / zero LIVE_FINAL**. No whole package or final aesthetic approval is inferred from adding icons.

## Validation / acceptance limits

[46 native full-resolution captures](GALLERY.md), phone **1080×2340**, tablet **1200×1920**, desktop GLES3. JPEG94 without resizing; source/delivery hashes and dimensions recorded. Reward/VFX/rarity captures are **controlled previews**, not physical S23 acceptance or claims of normal seeded outcomes. Actor target-facing flag remains unforced. Notes/station/route/reward screens run in the actual game UI with disposable profiles.

- Final native `canon-content-mastery-delivery-b9f470ea7c`: exit0, zero errors, 31.6s. Checks every art mapping resolves a real item ID, item data stays immutable, Gold cannot replace Scrip, and Camp/Risk/Boss captures select the real corresponding route layer. All six spinner tiers captured with the real mastery reward kind, no real rewards granted by previews. The earlier exploratory “gold” preview kind fell back to a generic charm; that capture is superseded, not counted as proof of painted spinner currency. QA-only fixture correction does not change shipped gameplay.
- Targeted item-art, chest, mobile gesture/input and RC save checks all pass; preserved weapon-fit matrix and Phase4E visible UI checks pass. [Logs](qa). Frozen canonical negative guard: all eight tests pass; 11 frozen sources and 246 accepted pose rows remain protected; no boss frame approval.
- Master freshness/count guards and canon registry pass: 122 source inputs, 834 identities, 814 catalog routes. Only status/hash receipts regenerate; missing-body counts are not fabricated.
- Thirteen extraction audits verify unchanged source RGB, source/export hashes and clear gutters. [Audit](qa/extraction-audit.json).
- Frost rotation uses CanvasItem's local drawing transform, then restores it before further drawing; actor/weapon direction is not changed ([current Godot documentation](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-draw-set-transform)). Native review confirms the neighbouring UI/actors remain correctly staged.
- Native inspection refined neighbouring alpha fragments and rejected the floating prop placement. Small currency icons remain supplementary to readable numeric counters. Portrait/body/env differences and remaining regional proxies visible in captures are still Beta/open; the effects pass does not approve them.

No physical FPS, thermals, Android GPU memory, touch/lifecycle/process-death or final perceptual audio/art acceptance is claimed. Source paintings remain static where no authored animation exists.

## Android / checkpoints / retest

**v35 / `0.4.26-phase4e-canon-content`**

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-content-debug.apk`

145,384,378 bytes (~138.65MiB), SHA256 `f150a13ff6547ce204744a552dad3b2663a64929292715dd0f8a954f97e065e0`. Signed arm64 debug, minSDK24/targetSDK36, signature and 16KiB alignment verified. All112 accepted extracted imports and five Wanderer bodies verified; source/reference/test art excluded. New art adds ~1.81MB to APK bytes versus v34. [Build receipt](build-receipt.json) · [new imports / shipped compiled module hashes](qa/apk-content-proof.json). Device validated false.

Install over the existing app without uninstalling/clearing data. Check Home currency counters and Notes owned gear; in a dungeon inspect Camp/Cursed Crossing/Final Vault cards; inspect a new relic reward and keep/leave flow, elemental contacts, and an available earned spin. Pause/resume and return Home once. Report any clipping, unreadable symbols, input leakage, stutter or save loss. No need to force a jackpot or spend for this retest.

## Multidisciplinary sign-off — full Phase4E

DESIGN: ISSUES (partial art/owner gates). BALANCE: ISSUES (full sign-off not renewed; no tuning). ECONOMY: ISSUES (unchanged; physical reward/save acceptance open). ROSTER: ISSUES (2,318 cells). ENEMIES: ISSUES (regional proxies). BOSSES: ISSUES (Dragon and named state packages). RNG: ISSUES (broad distributions unchanged, not rerun). UI/UX: ISSUES (scoped native/input checks pass; device gate open). NARRATIVE: ISSUES (canon preserved; full acceptance not renewed). AUDIO: ISSUES (unchanged, perceptual/mastering gate open). MOBILE: ISSUES (package/layout passes, physical tests open). QA: ISSUES (scope passes; save semantic/cross-store/process-death/owner/device gates remain). PRODUCTION: ISSUES (safe implementation/evidence checkpoints; full Phase4E HOLD).

Continue the safe canonical queue from this checkpoint. This is a multi-category implementation delivery, not completion of all Phase4E art or permission for Phase4F.
