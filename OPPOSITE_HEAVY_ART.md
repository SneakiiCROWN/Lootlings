# Opposite-facing adult heavy pack

Continuation of accepted ec24f05; additive to AUTHORED_HEAVY_ART.md. Built-in image generation/editing, original project art only. No external assets/licences. Existing right-facing bodies, neutral actors, inventory and canonical reference images remain unchanged.

## Runtime exports and acceptance

Ten 1024×1536 transparent RGBA exports at `art/sprites/poses/{vault_runner,ruin_warden,nightstage_drifter,velvet_astrologer,ashtrail_hunter}/heavy_two_hand_{ready,release}_left.png`. Originals are these full-resolution paintings, not destructive sheet crops. The generated originals also remain in the tool output directory. Existing three independent 512² heavy held exports are reused.

Each READY retains the accepted front-facing torso, real bent gripping arms, costume and planted stance, with authored leftward head/neck. It is an asymmetric forward guard, not a blindly mirrored right body. RELEASE has genuinely leftward arms/step. The runtime phase transforms load/recoil/settle in the facing direction. No skeletal animation or fabricated forearms. Warden/Astrologer single pauldrons stay image-right; Hunter fur stays image-left and bronze armour/bone trophies image-right; Drifter angular tattoo stays image-right with image-left arm clean. The large source images and native render were inspected for these invariants.

The existing manifest now has 226 unique actor/group/phase/facing rows, twenty authored body exports. Existing resolver selects cached facing before action phase, never flips authored left anatomy. Grip spans are measured per export and bound to actual straight held shafts, not global offsets. Painted hands/body cover the separate back-depth weapon. Leftward visual step/offset was corrected; this is a presentation preview, not a new leftward gameplay mode.

Native OpenGL 480×854: all five adults × three heavy weapons × READY/RELEASE × both facings = **60 captured/visually inspected states**. Full-resolution worst-case checks included Warden Maul READY, Astrologer sword/hair READY, and Runner/Drifter/Hunter RELEASE. Guard weapons can overlap the back of hair, but faces and wrists remain readable; no through-face blade accepted. Existing short keyed-body switch remains beta two-state action, not in-between animation.

Production matrix test produces 864 actor/body/family/facing/phase records with wardrobe/support status in ignored `.godot_test_data/weapon_fit_report.json` (`--report`). It does not count mathematical alignment as accepted art. **93 support-hand/paired combinations remain per facing**, or 186 actor/family/facing cells. Other groups/creatures are NOT complete. All 12 families and Gloomlet remain selectable/playable.

## Validation / limits

Parser/import clean, 20 regression entrypoints pass: fit/authored/wardrobe, smoke, Wanderer migration/save/inventory, all-family expansion/evolution, groups/AoE/routes/campaign, canonical/item/chest/contracts/presentation/vignette/residents/audio, 96-run balance and progression/economy. Smoke 2/5; 96-run audit 22 wins, unchanged. A resident first-meeting assertion initially failed because its test inherited the preceding vignette test's save; rerunning with a fresh per-test APPDATA passes. No runtime defect hidden/suppressed.

One active four-body pack is retained (approximately 24 MiB uncompressed RGBA plus existing held exports), with missing groups negatively cached. Switching facing does not reload art. Package size grows by ten paintings; no nodes/shaders/particles or gameplay RNG added. Native desktop QA is not Android RAM/battery certification. All fifty baked wardrobe contracts retained; left-only layer metadata accepted, no unavailable cosmetics exposed.

Exact remaining production art: both-facing READY/RELEASE/appropriate paired fore-/back-depth exports for the seven creatures' heavy group; all actors' polearm, bow, crossbow, staff and dual groups; separate genuinely paired dagger/claw held exports; actual Sling held art; weaponless Moonkip/Glimmerfin; real Gloomlet standalone body (current stand-in remains usable). Group/canvas/anchors/foreground/depth requirements remain in WEAPON_FIT_CONTRACT.md and the manifest. One-hand/wand/orb fallbacks are not claimed as full authored action packs. Fit closure remains the priority before further UI/world work.

## Rejected candidates

Early whole-pose edits mirrored wardrobe despite instructions. Multi-reference shoulder corrections often changed little. These candidates were rejected, not copied as production assets. Single-purpose edits fixed accepted candidates; Drifter's first relocated tattoo became a radial compass and was rejected/corrected back to angular linework. No falsely labelled production coverage.

## Exact prompts and source lineage

### vault_runner READY

Edit target: existing right READY runtime body. Final output: exec-ddd9b9af-f5b0-4c71-9811-d07442937b12.png.

Use case: precise-object-edit. Edit this game sprite: turn ONLY the head and neck so this same adult character looks toward LEFT edge of the picture. Nose points LEFT. Preserve identity, facial features/hair colour. Everything from collar downward must remain exactly as supplied: same shoulder armour sides, same tattoo sides, same braid drape, same bracers, two curled hands, outfit, hip gear, legs and feet. Do NOT flip any part of the body/clothes. Do NOT move arms or alter pose. This is a leftward READY guard with front-facing torso. No weapon/shaft, no added background, no text. 1024x1536 genuine transparent RGBA. Required edit is visibly LEFT-facing head only, not a mirrored character.

### vault_runner RELEASE

Initial edit target: existing right RELEASE runtime body. Final output: exec-1a59757d-5e68-42aa-8a4c-ec13270d1588.png.

Initial pose prompt:

Use case: identity-preserve. Input image is accepted RIGHT RELEASE body identity reference/edit target. Create a properly authored LEFT RELEASE heavy-weapon action sprite, not horizontal reflection. Vault Runner, umber-skinned adult woman with short black curls, navy gold long scavenger coat, white blouse, fitted waist, brown bracers and boots. Original strap on viewer LEFT shoulder, compass skirt panel/belt tail viewer RIGHT hip. Face/gaze and attack toward LEFT; retain front-facing three-quarter chest, so viewer RIGHT is still anatomical LEFT, keep every asymmetric detail on explicitly named VIEWER SIDE. DO NOT mirror armour/tattoos/gear/hair. Plant forward foot to image LEFT, grounded wide stance, lean forward slightly. Both natural arms bent across waist toward IMAGE LEFT. Two clenched fists around an invisible diagonal shaft rising up-left: lower/rear primary fist approx(380,640), upper/front supporting fist approx(240,560). Clear gripping sockets, no visible weapon/handle/rod. Body, face, outfit, proportions and premium painted finish match reference exactly. Full figure within 1024x1536 transparent RGBA canvas, boots near y1430. No stretched limbs, broken wrist, extra arm/finger, background, shadow cloud, text or new accessories. Only repose arms/legs/head for LEFTWARD attack while clothing sides remain explicitly original.

Correction prompt:

Edit this PNG. Required visible correction: Turn ONLY head/neck LEFT, nose points LEFT. Keep coat compass panel RIGHT hip, original gear/both arms unchanged. Do NOT mirror the image. Do NOT move fists or change planted release stance. Everything else unchanged, preserve face/body proportions/outfit materials/boots/two natural arms. Full-body 1024x1536 genuinely transparent RGBA, no weapon/rod/background/text.

### ruin_warden READY

Edit target: existing right READY runtime body. Final output: exec-60d3a96b-d51c-44b0-9471-334d1c2c9f06.png.

Use case: precise-object-edit. Edit this game sprite: turn ONLY the head and neck so this same adult character looks toward LEFT edge of the picture. Nose points LEFT. Preserve identity, facial features/hair colour. Everything from collar downward must remain exactly as supplied: same shoulder armour sides, same tattoo sides, same braid drape, same bracers, two curled hands, outfit, hip gear, legs and feet. Do NOT flip any part of the body/clothes. Do NOT move arms or alter pose. This is a leftward READY guard with front-facing torso. No weapon/shaft, no added background, no text. 1024x1536 genuine transparent RGBA. Required edit is visibly LEFT-facing head only, not a mirrored character.

### ruin_warden RELEASE

Initial edit target: existing right RELEASE runtime body. Final output: exec-6a88392d-e05b-41c2-94bb-00c57cb74765.png.

Initial pose prompt:

Use case: identity-preserve. Input image is accepted RIGHT RELEASE body identity reference/edit target. Create a properly authored LEFT RELEASE heavy-weapon action sprite, not horizontal reflection. Ruin Warden, bronze adult male with braids/stubble, broad physique, navy gold long coat, white shirt, turquoise necklace, bracers and boots. ONE metal pauldron on viewer RIGHT shoulder, viewer LEFT shoulder plain cloth. Face/gaze and attack toward LEFT; retain front-facing three-quarter chest, so viewer RIGHT is still anatomical LEFT, keep every asymmetric detail on explicitly named VIEWER SIDE. DO NOT mirror armour/tattoos/gear/hair. Plant forward foot to image LEFT, grounded wide stance, lean forward slightly. Both natural arms bent across waist toward IMAGE LEFT. Two clenched fists around an invisible diagonal shaft rising up-left: lower/rear primary fist approx(380,640), upper/front supporting fist approx(240,560). Clear gripping sockets, no visible weapon/handle/rod. Body, face, outfit, proportions and premium painted finish match reference exactly. Full figure within 1024x1536 transparent RGBA canvas, boots near y1430. No stretched limbs, broken wrist, extra arm/finger, background, shadow cloud, text or new accessories. Only repose arms/legs/head for LEFTWARD attack while clothing sides remain explicitly original.

Correction prompt:

Edit this PNG. Required visible correction: Turn ONLY head/neck LEFT, nose points LEFT. Keep the SINGLE pauldron on RIGHT side of picture and plain fabric on LEFT shoulder. Both arms stay LEFT extended. Do NOT mirror the image. Do NOT move fists or change planted release stance. Everything else unchanged, preserve face/body proportions/outfit materials/boots/two natural arms. Full-body 1024x1536 genuinely transparent RGBA, no weapon/rod/background/text.

### nightstage_drifter READY

Edit target: existing right READY runtime body. Final output: exec-7c4c8277-d5c8-4020-a705-10fa9166629c.png.

Use case: precise-object-edit. Edit this game sprite: turn ONLY the head and neck so this same adult character looks toward LEFT edge of the picture. Nose points LEFT. Preserve identity, facial features/hair colour. Everything from collar downward must remain exactly as supplied: same shoulder armour sides, same tattoo sides, same braid drape, same bracers, two curled hands, outfit, hip gear, legs and feet. Do NOT flip any part of the body/clothes. Do NOT move arms or alter pose. This is a leftward READY guard with front-facing torso. No weapon/shaft, no added background, no text. 1024x1536 genuine transparent RGBA. Required edit is visibly LEFT-facing head only, not a mirrored character.

### nightstage_drifter RELEASE

Initial edit target: existing right RELEASE runtime body. Final output: exec-44ec9813-49cb-45d9-81b6-85e653ffc4a8.png.

Initial pose prompt:

Use case: identity-preserve. Input image is accepted RIGHT RELEASE body identity reference/edit target. Create a properly authored LEFT RELEASE heavy-weapon action sprite, not horizontal reflection. Nightstage Drifter, olive adult with black shaggy purple-tipped hair, eyeliner, sleeveless black vest, purple jewels, bracers, chain straps and platform boots. Tattoos ONLY on viewer RIGHT upper arm/wrist, viewer LEFT arm untattooed. Purple sash/chain cluster viewer RIGHT hip. Face/gaze and attack toward LEFT; retain front-facing three-quarter chest, so viewer RIGHT is still anatomical LEFT, keep every asymmetric detail on explicitly named VIEWER SIDE. DO NOT mirror armour/tattoos/gear/hair. Plant forward foot to image LEFT, grounded wide stance, lean forward slightly. Both natural arms bent across waist toward IMAGE LEFT. Two clenched fists around an invisible diagonal shaft rising up-left: lower/rear primary fist approx(380,640), upper/front supporting fist approx(240,560). Clear gripping sockets, no visible weapon/handle/rod. Body, face, outfit, proportions and premium painted finish match reference exactly. Full figure within 1024x1536 transparent RGBA canvas, boots near y1430. No stretched limbs, broken wrist, extra arm/finger, background, shadow cloud, text or new accessories. Only repose arms/legs/head for LEFTWARD attack while clothing sides remain explicitly original.

Correction prompt:

Edit this PNG. Required visible correction: Turn head/neck LEFT, nose points LEFT. Erase geometric tattoo from LEFT side arm. Put same tattoo on RIGHT side arm, including upper arm and wrist. Keep sash/chain on RIGHT hip and both fists LEFT extended. Do NOT mirror the image. Do NOT move fists or change planted release stance. Everything else unchanged, preserve face/body proportions/outfit materials/boots/two natural arms. Full-body 1024x1536 genuinely transparent RGBA, no weapon/rod/background/text.

LeftReleaseHeadPrompt:

Edit ONLY head/neck in this full-body PNG so this same character faces LEFT. Nose and gaze point toward LEFT edge, not right. Keep every pixel below collar, hands, arms, outfit, legs, tattoo and background transparency unchanged. Do NOT mirror anything. Preserve face identity and purple hair. 1024x1536 transparent RGBA. Required change: face turns LEFT.

LeftReleaseTattooPrompt:

Edit ONLY the two arm tattoo markings in this PNG. REMOVE BOTH geometric tattoo marks from the arm on LEFT side of picture, restoring clean olive skin there. Paint the matching original geometric tattoo marks onto the arm on RIGHT side of picture: one upper arm geometric network and one small wrist marking just above bracer. LEFT arm is entirely tattoo-free; RIGHT arm is tattooed. Do not change head (still LEFT facing), hair, pose, hands, bracers, vest, chains, sash, legs or boots. Do NOT flip body. 1024x1536 transparent RGBA full-body sprite, no new props or background.

LeftReleaseGridPrompt:

Use case: precise-object-edit. Image1 left RELEASE edit target; Image2 original READY tattoo reference. Change ONLY Image1's RIGHT-side upper-arm and wrist tattoo designs to match Image2's original angular interlocking zigzag/rectangular geometric linework. NOT a circular/radial compass/star/mandala. Same tattooed arm, same olive skin, preserve Image1's LEFT-facing head, hair, natural arms/fists, black/purple outfit and planted legs exactly. Left-side arm stays clean/untattooed. No new props, words or background. Transparent 1024x1536 RGBA full-body sprite.

### velvet_astrologer READY

Edit target: existing right READY runtime body. Final output: exec-a71f017d-959d-4775-ba94-42a5fad9228d.png.

Use case: precise-object-edit. Edit this game sprite: turn ONLY the head and neck so this same adult character looks toward LEFT edge of the picture. Nose points LEFT. Preserve identity, facial features/hair colour. Everything from collar downward must remain exactly as supplied: same shoulder armour sides, same tattoo sides, same braid drape, same bracers, two curled hands, outfit, hip gear, legs and feet. Do NOT flip any part of the body/clothes. Do NOT move arms or alter pose. This is a leftward READY guard with front-facing torso. No weapon/shaft, no added background, no text. 1024x1536 genuine transparent RGBA. Required edit is visibly LEFT-facing head only, not a mirrored character.

### velvet_astrologer RELEASE

Initial edit target: existing right RELEASE runtime body. Final output: exec-2352b811-300a-4cc4-b703-f48b8c51ad00.png.

Initial pose prompt:

Use case: identity-preserve. Input image is accepted RIGHT RELEASE body identity reference/edit target. Create a properly authored LEFT RELEASE heavy-weapon action sprite, not horizontal reflection. Velvet Astrologer, brown curvy adult woman, silver braids sweeping over viewer LEFT shoulder, plum lips, purple gold arcane bodice and split coat, leggings and gold heels. ONE big pauldron on viewer RIGHT shoulder, viewer LEFT plain purple cloth. Face/gaze and attack toward LEFT; retain front-facing three-quarter chest, so viewer RIGHT is still anatomical LEFT, keep every asymmetric detail on explicitly named VIEWER SIDE. DO NOT mirror armour/tattoos/gear/hair. Plant forward foot to image LEFT, grounded wide stance, lean forward slightly. Both natural arms bent across waist toward IMAGE LEFT. Two clenched fists around an invisible diagonal shaft rising up-left: lower/rear primary fist approx(380,640), upper/front supporting fist approx(240,560). Clear gripping sockets, no visible weapon/handle/rod. Body, face, outfit, proportions and premium painted finish match reference exactly. Full figure within 1024x1536 transparent RGBA canvas, boots near y1430. No stretched limbs, broken wrist, extra arm/finger, background, shadow cloud, text or new accessories. Only repose arms/legs/head for LEFTWARD attack while clothing sides remain explicitly original.

Correction prompt:

Edit this PNG. Required visible correction: MOVE metal shoulder armour from LEFT of picture to RIGHT of picture, and erase plate from LEFT restoring plain cloth. Head still LEFT. Braids stay LEFT. Both fists stay LEFT extended. Do NOT mirror the image. Do NOT move fists or change planted release stance. Everything else unchanged, preserve face/body proportions/outfit materials/boots/two natural arms. Full-body 1024x1536 genuinely transparent RGBA, no weapon/rod/background/text.

### ashtrail_hunter READY

Edit target: existing right READY runtime body. Final output: exec-1c7e0779-8d62-451c-aa55-443903eac2d4.png.

Use case: precise-object-edit. Edit this game sprite: turn ONLY the head and neck so this same adult character looks toward LEFT edge of the picture. Nose points LEFT. Preserve identity, facial features/hair colour. Everything from collar downward must remain exactly as supplied: same shoulder armour sides, same tattoo sides, same braid drape, same bracers, two curled hands, outfit, hip gear, legs and feet. Do NOT flip any part of the body/clothes. Do NOT move arms or alter pose. This is a leftward READY guard with front-facing torso. No weapon/shaft, no added background, no text. 1024x1536 genuine transparent RGBA. Required edit is visibly LEFT-facing head only, not a mirrored character.

### ashtrail_hunter RELEASE

Initial edit target: existing right RELEASE runtime body. Final output: exec-f17b299f-4cda-4193-96ae-23fc0f4c9d82.png.

Initial pose prompt:

Use case: identity-preserve. Input image is accepted RIGHT RELEASE body identity reference/edit target. Create a properly authored LEFT RELEASE heavy-weapon action sprite, not horizontal reflection. Ashtrail Hunter, pale muscular adult male, auburn hair/beard, cheek scar, green gambeson, bracers and boots. Fur ONLY on viewer LEFT shoulder; bronze pauldron ONLY viewer RIGHT shoulder. Bone trophies and pouches viewer RIGHT hip. Face/gaze and attack toward LEFT; retain front-facing three-quarter chest, so viewer RIGHT is still anatomical LEFT, keep every asymmetric detail on explicitly named VIEWER SIDE. DO NOT mirror armour/tattoos/gear/hair. Plant forward foot to image LEFT, grounded wide stance, lean forward slightly. Both natural arms bent across waist toward IMAGE LEFT. Two clenched fists around an invisible diagonal shaft rising up-left: lower/rear primary fist approx(380,640), upper/front supporting fist approx(240,560). Clear gripping sockets, no visible weapon/handle/rod. Body, face, outfit, proportions and premium painted finish match reference exactly. Full figure within 1024x1536 transparent RGBA canvas, boots near y1430. No stretched limbs, broken wrist, extra arm/finger, background, shadow cloud, text or new accessories. Only repose arms/legs/head for LEFTWARD attack while clothing sides remain explicitly original.

Correction prompt:

Edit this PNG. Required visible correction: SWAP shoulder materials: fur belongs LEFT side of picture, bronze pauldron RIGHT side of picture. Bone trophies belong RIGHT hip; move from LEFT to RIGHT. Keep head LEFT, arms LEFT extended. Do NOT mirror the image. Do NOT move fists or change planted release stance. Everything else unchanged, preserve face/body proportions/outfit materials/boots/two natural arms. Full-body 1024x1536 genuinely transparent RGBA, no weapon/rod/background/text.
