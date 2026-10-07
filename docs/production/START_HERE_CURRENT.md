IF AN OLDER DOCUMENT CONFLICTS WITH THIS FILE OR THE LINKED CURRENT AUTHORITIES, THE CURRENT AUTHORITIES WIN.

# Current Lootlings production

Branch `codex/phase4e-gamefeel`, repository `SneakiiCROWN/Lootlings`. **Phase4E; NO PHASE4F.** Older `main` does not override this production branch.

Verified runtime implementation: **`585c24cd3333b40d52e65e71395ebe7ffc3969ab`**, approved Archive/merchant/rune/service/flying-spell integration. Separate QA/evidence is the commit adding `phase4e/canon-utilities/REPORT.md` (resolve with `git log -1 --format=%H -- docs/production/phase4e/canon-utilities/REPORT.md`). Preserves v35 implementation `a69d300169081a943190a050c8ea156f13fc8208` / QA `18b566243488101ef5cf91dc50748e0f769e7c4a`, v34 canonical actions and all accepted v33 work. Metadata receipt commits do not change the APK.

Android **v36 / 0.4.27-phase4e-canon-utilities**: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-utilities-debug.apk`. **Scoped native/package QA passes; HOLD for full Phase4E/release acceptance.** [Current report/build receipt](phase4e/canon-utilities/REPORT.md), [24 native phone/tablet captures](phase4e/canon-utilities/GALLERY.md). Independent repo work continues without waiting for physical S23 acceptance. Historical [v35 content](phase4e/canon-content/REPORT.md), [v34 action comparisons](phase4e/canonical-actions/GALLERY.md) and [v33 world report](phase4e/bible-runtime/REPORT.md) remain preserved.

**Implemented cast:** Relic Beast, Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin, Gloomlet. **Wanderers:** Vault Runner, Ruin Warden, Nightstage Drifter, Velvet Astrologer, Ashtrail Hunter. **Residents:** Patch Brasswick, Ilex Quill, Sera Vey. **Merchant:** existing Pack Peddler/Merrow role; no new board NPCs.

**Twelve families:** Greatsword, Greataxe, Maul, Spear/Halberd, Twin Daggers, Claws/Gauntlets, Bow, Crossbow, Relic Sling, Staff, Wand, Orb/Focus.

**Regions:** Act I (Outer Treasure Ruins, Salvage Warrens, Hoard Depths), Mossglass Wilds, Moonfen, Frostbell Hollows, Sunken Gearworks, Cinder Crown, Starfall Archive, Nullglass Expanse, Skyhook Bastion, The First Hoard. Written World Bible and stable campaign IDs control the route.

**Source priority:** written canon/stable IDs/production authority → frozen canonical sheets → accepted runtime poses → established gear/UI/world assets → explicitly compatible handoff guidance → exact derived production exports. Handoff STATUS metadata overrides filenames. Reject changed Moonkip, mushroom Gloomlet and winged/quadruped Dragon bodies. Art Bible is compatible guidance only.

**Generated inventory:** 6,889 records; 6,159 launch slots; 3,103 LIVE_BETA; 3,056 missing delivery cells (2,318 playable), grouped into 106 body/view bundles; separately 165 complete support packages (82 right, 83 left); zero LIVE_FINAL. v34 resolved nine exact TEMP action cells; v35/v36 non-body batches resolve zero additional combat cells. These units are not additive image counts. [Current generated summary](MASTER_INTEGRATION_SUMMARY.md).

**Art gates:** exact missing actions/facings/support layers; Moonkip weaponless paws; original Dragon continuous-tail repair; distinct regional/boss/NPC activity exports. Gloomlet canonical idle exists; rejected procedural combat fallback remains TEMP. Glimmerfin canonical idle is weaponless. **Non-art gates:** save semantic/cross-store/process-death acceptance; final perceptual audio/mastering; physical S23 performance/lifecycle/input; final player-facing visual owner acceptance.

**Authorities:** [canon registry](CANON_REGISTRY.json), [Phase4E status](../../PRODUCTION_PHASE4E.md), [replacement queue](phase4e/polish/CANONICAL_REPLACEMENTS.md), [export contract](phase4e/polish/ART_EXPORT_CONTRACT.md), [exact new-art requests](NEEDS_NEW_CANON_EXPORT.json), [World Bible](../../LOOTLINGS_WORLD_BIBLE.md), [handoff status](../../art/reference/phase4e_handoff/REFERENCE_STATUS.json), [reference guide](../../art/reference/README.md).

Generated manifests/CSV/matrices are not hand edited. Fix underlying catalogs/contracts, refresh isolated Godot reflection, run `tools/build_master_integration.py`, then `tools/build_canon_registry.py`; validate with the existing master/canonical validators and `tools/validate_canon_registry.py`.

**Current utility continuation:** eight original-pixel item/prop/VFX exports (112→120 accepted extractions); Memory/Trophy Archive, local Contracts, merchant capacity, two heavy-echo rune cards and owned Notes, Siege service icons, Fire/Arcane flight. Utility icons clear on panel changes; service drag/leave safety and both missile directions captured. No new body/action states or gameplay changes; no new missing-art requirements. **Next:** continue the safe canonical queue, preserve absent states as TEMP. All external art/device/save/audio/owner gates remain open; no Phase4F.

**Preserved v35 content:** 13 original-pixel item/prop/VFX exports (99→112); eight relic IDs use painted cards/Notes/rewards/drops; distinct Gold/Scrip/Star Shards; Camp/Risk/Vault illustrations; Notes map; Lightning/Poison contacts and Frost projectile. All six spinner tiers captured. Exact request package includes filenames/destinations and equipment/VFX contracts.

**Preserved v34 actions:** Emberhorn claws windup/strike; Moonkip original baked daggers windup/strike; Pebblewyrm claws windup; Glimmerfin baked staff windup and Wand/Orb cast; Gloomlet violet Assassin claws strike. Eight true source action exports close nine right-facing TEMP cells. No invented opposite/recovery or weaponless claims. Existing heavy actor routes remain; no new enemy/boss/NPC/Wanderer states.

**Preserved v33 continuation:** 13 approved original-pixel spell/projectile/contact motifs, chest/premium-machine energy, scroll/key/crown symbols and merchant/Forge props; accepted HUD framing/Relic Beast face, fitted dungeon cards, larger Notes/Memory paintings and Ilex dialogue spacing. All six rarity previews captured. That earlier batch closed zero combat cells; v34 action coverage above supersedes its counts/APK.

**Historical v31 delivery:** implementation `844b0ad2c7c4d696db0826f90863e07d4c2fbf39`, QA `85bbbdf2faf12d6f70470399cc5d5cd4568b9904`, [approved-mass report and controlled before/after evidence](phase4e/approved-mass/REPORT.md). Its Forge/bounty/Archive/ATTACK/frame improvements are preserved. Current v33 receipt supersedes its APK/status/counts.
