IF AN OLDER DOCUMENT CONFLICTS WITH THIS FILE OR THE LINKED CURRENT AUTHORITIES, THE CURRENT AUTHORITIES WIN.

# Current Lootlings production

Branch `codex/phase4e-gamefeel`, repository `SneakiiCROWN/Lootlings`. **Phase4E; NO PHASE4F.** Older `main` does not override this production branch.

Verified runtime implementation: `2d3a8028594f714a7b9b1889233db5d4967c9451` (main batch `34939d5748add93b3c6b124263822dcfd2f8f213`). QA/report: `e263e86f1d51b6d7078821bbf9c525f1f94b4d33` (evidence `c840e7a122b01043adad5cf9a550269211f782e7`). Subsequent housekeeping checkpoints do not change this APK.

Android **v29 / 0.4.20-phase4e-canon-world**: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-world-debug.apk`. **GO for scoped S23 owner review; HOLD for full Phase4E/release acceptance.** [Build receipt and limitations](phase4e/canon-world/REPORT.md).

**Implemented cast:** Relic Beast, Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin, Gloomlet. **Wanderers:** Vault Runner, Ruin Warden, Nightstage Drifter, Velvet Astrologer, Ashtrail Hunter. **Residents:** Patch Brasswick, Ilex Quill, Sera Vey. **Merchant:** existing Pack Peddler/Merrow role; no new board NPCs.

**Twelve families:** Greatsword, Greataxe, Maul, Spear/Halberd, Twin Daggers, Claws/Gauntlets, Bow, Crossbow, Relic Sling, Staff, Wand, Orb/Focus.

**Regions:** Act I (Outer Treasure Ruins, Salvage Warrens, Hoard Depths), Mossglass Wilds, Moonfen, Frostbell Hollows, Sunken Gearworks, Cinder Crown, Starfall Archive, Nullglass Expanse, Skyhook Bastion, The First Hoard. Written World Bible and stable campaign IDs control the route.

**Source priority:** written canon/stable IDs/production authority → frozen canonical sheets → accepted runtime poses → established gear/UI/world assets → explicitly compatible handoff guidance → exact derived production exports. Handoff STATUS metadata overrides filenames. Reject changed Moonkip, mushroom Gloomlet and winged/quadruped Dragon bodies. Art Bible is compatible guidance only.

**Generated inventory:** 6,805 records; 6,075 launch slots; 3,010 LIVE_BETA; 3,065 missing delivery cells (2,327 playable), grouped into 106 body/view bundles; separately 165 complete support packages (82 right, 83 left); zero LIVE_FINAL. These units are not additive image counts. [Current generated summary](MASTER_INTEGRATION_SUMMARY.md).

**Art gates:** exact missing actions/facings/support layers; Moonkip weaponless paws; original Dragon continuous-tail repair; distinct regional/boss/NPC activity exports. Gloomlet canonical idle exists; rejected procedural combat fallback remains TEMP. Glimmerfin canonical idle is weaponless. **Non-art gates:** save semantic/cross-store/process-death acceptance; final perceptual audio/mastering; physical S23 performance/lifecycle/input; final player-facing visual owner acceptance.

**Authorities:** [canon registry](CANON_REGISTRY.json), [Phase4E status](../../PRODUCTION_PHASE4E.md), [replacement queue](phase4e/polish/CANONICAL_REPLACEMENTS.md), [export contract](phase4e/polish/ART_EXPORT_CONTRACT.md), [exact new-art requests](NEEDS_NEW_CANON_EXPORT.json), [World Bible](../../LOOTLINGS_WORLD_BIBLE.md), [handoff status](../../art/reference/phase4e_handoff/REFERENCE_STATUS.json), [reference guide](../../art/reference/README.md).

Generated manifests/CSV/matrices are not hand edited. Fix underlying catalogs/contracts, refresh isolated Godot reflection, run `tools/build_master_integration.py`, then `tools/build_canon_registry.py`; validate with the existing master/canonical validators and `tools/validate_canon_registry.py`.

**Next:** use the already-accepted Wanderer portrait crops in Field Notes instead of tiny full-body thumbnails; native-review all five on phone/tablet, then continue safe approved-source integration through the registry. Existing encounter-specific Memory backgrounds remain intact. No new identities, fabricated states, balance changes or Phase4F.
