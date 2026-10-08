# Armour inventory family

Built-in imagegen authored this missing twelve-item icon family against `art/reference/canonical/phase2_master/lootlings_fantasy_gear_compendium.png` and the existing item descriptions in item_catalog.gd, phase3_item_catalog.gd and phase4_catalog.gd. No dedicated item identity sheet was replaced. The compendium is equipment style authority only; none of its character or logo variants override dedicated canon.

The twelve live Armour IDs retain their names, effects, prices, signatures and save IDs. These are static inventory icons, not character outfit/body/animation deliveries. They do not close any frozen pose or support-hand contract.

Initial batch: four columns, three rows in current item ID order: mossguard_harness, ironpaw_plate, ruinweave_coat, dragon_scale_patch, patchplate_vest, coin_stitch_coat, thorn_receipt, last_page, second_skin, warden_warranty, scarlet_margin, keeper_coat. Prompt requested empty wearable chest equipment, approved royal/shadow/arcane/wildling materials, upper-left light, actual transparent alpha, no people/mannequins/weapons/text/UI, full contained silhouettes and readable small-size contrast.

Rejected initial Dragon-Scale Patch and Second Skin regions were never exported to runtime. The first became a full breastplate; the second had an unsuitable sculpted torso. A two-item correction requested a leather-bound guardian-scale patch without pauldrons/waist plate and a flat unisex lightweight violet leather vest without human anatomy. Corrected source is retained separately.

Runtime export is exact source-pixel rectangular extraction in Godot, preserving original RGBA. No repainting, alpha fabrication, flipping, recolouring or resynthesis is used during export. Each PNG has a sidecar binding source region/hash, authority hash, role, dimensions and reviewed delivery. Original source sheets are kept outside shipping exports.

Runtime files: `art/production/phase4e/items/armour_inventory_v1/`. Shared selector in lootlings_ui.gd reaches ItemIcon, drops, reward cards, comparison, stash, shop and Forge. Unknown/unavailable items retain the established fallback. Full and small native rendering must pass before checkpoint acceptance.

Acceptance: all twelve passed full-size and 40-unit native review at phone, tablet and desktop sizes. The shared selector also passed the actual exported PCK routes. All twelve imported textures and sidecars were verified inside the Android 0.4.35 APK.
