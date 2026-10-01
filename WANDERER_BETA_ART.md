# Adult Wanderer beta runtime kit

This is an additive adult player path, not a replacement for the seven canonical Lootlings. All presets are adults. Any pronouns, origin, lineage, bark style and all twelve weapon families may be combined without stat restrictions. `current_lootling_id` is retained when switching branches. Appearance does not enter combat/economy/RNG formulas.

## Accepted assets / provenance

Built-in image generation; original Lootlings-style adult designs, no downloaded third-party character assets. Original generation outputs remain in the tool's generated-image folder. Runtime copies:

- `art/sprites/wanderers/beta/vault_runner_idle.png`: 1024×1536 RGBA, athletic adult woman, umber skin, short dark curls, practical navy scavenger coat/trousers, brass/cyan jewellery. Source output `exec-e89bae4f-e9ef-4a94-a163-e461d65f5de7.png`.
- `art/sprites/wanderers/beta/ruin_warden_idle.png`: 1024×1536 RGBA, broad adult man, bronze skin, short braids/stubble, navy warden coat/trousers, brass/cyan jewellery. Source output `exec-f35b090c-a25b-45a6-bf9c-97946c37395b.png`.

Generation mode: built-in imagegen, transparent background requested. Alpha was checked against empty exterior sample points and both bodies were inspected over the actual native OpenGL gameplay and Hideout backgrounds. No source sheet was shipped as a portrait rectangle. Two earlier source-board extraction trials were rejected for clipped/attached neighbouring pixels; originals are untouched and trial outputs are outside runtime art. No new canonical Lootling artwork was generated or repainted.

Prompt set: Vault Runner requested a centered, full-body, right-facing, weaponless adult brown-skinned athletic treasure hunter with short dark curls, practical navy coat/trousers/boots, brass/cyan relic jewellery, generous transparent margins, grounded ready stance and visible front grip hand; no scenery/glow/shadow/labels/copyrighted designs. Ruin Warden used that accepted body as style/material/composition reference only and requested a distinct mature broad-shouldered male, bronze skin, short braids/stubble, practical navy coat/brass armour/trousers/boots, same right-facing weaponless grip stance, full head/boots and clean alpha. The first close-up female candidate/edit were not accepted; only the compact full-body candidate is live.

## Honest limits

These are two **authored beta presets**, not a modular character creator. Body/skin/face/hair/outfit fields describe the actual selected artwork and are sanitized to that preset. Lineage is lore-only. Origin and bark style change short written flavour; pronouns are editable/persistent. No nonexistent hair/skin/outfit sliders are exposed. Layered arm/hand poses are still required for genuine two-hand grips, bow drawing and independent limb counter-motion. Current presentation uses the existing action phases with measured body/hand/weapon/projectile sockets; paired daggers remain a single existing paired-blade texture. Sling retains the existing honestly pending family fallback. Neither limitation disables its existing mechanics.

## Next production exports (not secretly implemented)

For each enabled adult body, supply transparent RGBA **1024×1536** registered pose/layer exports with a shared feet baseline, body origin and primary/secondary hand sockets. Suggested destination `art/sprites/wanderers/production/<body_id>/`:

- `body_idle.png`, `body_anticipate.png`, `body_attack.png`, `body_recovery.png`, `body_hurt.png`, `body_victory.png`: same proportions/head/skin/outfit; right-facing, full-body, no baked weapons/background/shadow.
- `arm_back_<family>_<phase>.png`, `arm_front_<family>_<phase>.png`: same registration and sleeves/skin; 12 family-specific primary/secondary grips, separate charge/release for ranged families. Empty non-arm pixels transparent.
- `face_<id>.png`, `hair_<id>_<colour>.png`, `outfit_<id>_body.png`, `outfit_<id>_arms.png`, `head_<id>.png`, `cape_<id>.png`, `jewellery_<id>.png`: registered modular layers, no baked weapon or Core spell effect. Start with the two live presets before advertising four remaining frames or additional variants.
- `portrait_<preset_id>.png`: optional clean 512×512 bust/face, transparent. Current HUD derives a safe face region from the standalone runtime body, not from a multi-character board.

Other four body frames, expanded skin/face/hair palettes and glam outfits require matching authored layers before player-facing controls are enabled. Existing tiny-creature cosmetics remain separate: adult outfits must never be pasted onto canonical Lootlings. `wanderer_pose_catalog.gd` is the replaceable attachment hook; weapon textures/stages remain `weapon_catalog.gd` authority.
