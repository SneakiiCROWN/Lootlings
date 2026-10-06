Current v26 continuation: five compatible Fire/Frost/Poison/Lightning/Arcane rune glyphs add to the preserved v25 exports, for 78 routed exports. Additional reproducible alpha-only extraction: tools/extract_master_compatible_icons.py. Permanent routing/status inventory: docs/production/MASTER_INTEGRATION_SUMMARY.md. The completed v25 inventory below remains historical provenance.

# Locked-source Phase4E exports

73 source-pixel exports with runtime routes: 10 transparent combat body/views, 48 opaque expression portraits, 12 transparent inventory weapon icons, 3 transparent HUD glyphs. Original source RGB is cropped/masked; body canvases are uniformly fitted to 512×512. No synthesized states, recolouring, new identities or mirrored anatomy.

`extraction_manifest.json` records source SHA256, crop, canvas, alpha requirement, output SHA256 and restrictions. `runtime_manifest.json` records actual palms, core anchors, ground baseline, phase, view and permitted weapon families. Existing authored heavy/bow/staff routing takes precedence. Missing movement/release/hurt/views retain explicitly TEMP rigs; this package is not a complete final animation set.

| Source | Usable material integrated | Material kept open |
|---|---|---|
| Relic Beast mascot | Right idle, established alpha guide, original RGB | Missing individual action/view/support states |
| Emberhorn sheet | Right three-quarter idle, actual left side idle, eight expressions | Other weapon/action states; occluded hands in turnaround views |
| Mosskin sheet | Right idle with original shield, actual left side idle, eight expressions | Shield removal, paired hands and missing action states |
| Moonkip sheet | Right idle with original baked twin daggers, eight expressions | Weaponless body, other family grips, left/action states; no dagger erasure or invented paws |
| Pebblewyrm sheet | Right idle, eight expressions | Remaining views/actions; variants do not establish new unlocked outfits |
| Glimmerfin sheet | Weaponless right idle including full tail, eight expressions | Remaining views/actions/support hands |
| Gloomlet sheet | Violet Assassin right idle and original crouched claw anticipation, eight expressions | Actual release/recovery/hurt/left frames; glowing slash illustrations do not supply clean missing anatomy |
| Class template | Same canonical source content as Emberhorn | Duplicate exports not counted |
| Handoff 01/05 Dragon | Single-tail production guidance only | Winged/quadruped body conflicts with established coiled Dragon; malformed current source tail still REPLACE |
| Handoff 02 Moonkip / 03 Gloomlet | No body export | Rejected changed anatomy/mushroom identities |
| Handoff 04 art bible | Twelve compatible inventory-family icons, Fire/Lightning/Rune glyphs | Conflicting cast, new regions/NPC labels, incomplete objects, layered/occluded artwork and text are not production bodies/assets |

No production-ready Wanderer, NPC activity, regional enemy or boss state frame is available in these listed sheets. Existing good authored poses and Patch/Ilex/Sera idles remain intact. No board body is promoted to canon. Portrait backgrounds deliberately remain opaque and are not combat transparency failures.

Reproduction: `tools/extract_phase4e_locked.py` with Pillow, NumPy and workspace-local OpenCV (`.godot_test_data/image-tools`, currently opencv-python-headless 5.0.0.93). Seeded GrabCut and traced outlines change alpha only. Review all outputs before changing runtime eligibility. `tools/validate_canonical_art.py` and eight guard tests prohibit conflicting body sources and invented phases. Import PNGs with the project Godot editor before native review/build.

The exact post-extraction queue is `docs/production/phase4e/extraction/MISSING_ART_MANIFEST.json`; canonical authority remains the active replacement register. These existing-source extractions are suitable for scoped owner review, not final whole-roster art acceptance.
