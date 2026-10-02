# Adult Wanderer beta runtime kit

This is an additive adult player path, not a replacement for the seven canonical Lootlings. All presets are adults. Any pronouns, origin, lineage, bark style and all twelve weapon families may be combined without stat restrictions. `current_lootling_id` is retained when switching branches. Appearance does not enter combat/economy/RNG formulas.

## Accepted assets / provenance

Built-in image generation; original Lootlings-style adult designs, no downloaded third-party character assets. Original generation outputs remain in the tool's generated-image folder. Runtime copies:

- `art/sprites/wanderers/beta/vault_runner_idle.png`: 1024×1536 RGBA, athletic adult woman, umber skin, short dark curls, practical navy scavenger coat/trousers, brass/cyan jewellery. Source output `exec-e89bae4f-e9ef-4a94-a163-e461d65f5de7.png`.
- `art/sprites/wanderers/beta/ruin_warden_idle.png`: 1024×1536 RGBA, broad adult man, bronze skin, short braids/stubble, navy warden coat/trousers, brass/cyan jewellery. Source output `exec-f35b090c-a25b-45a6-bf9c-97946c37395b.png`.

Generation mode: built-in imagegen, transparent background requested. Alpha was checked against empty exterior sample points and both bodies were inspected over the actual native OpenGL gameplay and Hideout backgrounds. No source sheet was shipped as a portrait rectangle. Two earlier source-board extraction trials were rejected for clipped/attached neighbouring pixels; originals are untouched and trial outputs are outside runtime art. No new canonical Lootling artwork was generated or repainted.

Prompt set: Vault Runner requested a centered, full-body, right-facing, weaponless adult brown-skinned athletic treasure hunter with short dark curls, practical navy coat/trousers/boots, brass/cyan relic jewellery, generous transparent margins, grounded ready stance and visible front grip hand; no scenery/glow/shadow/labels/copyrighted designs. Ruin Warden used that accepted body as style/material/composition reference only and requested a distinct mature broad-shouldered male, bronze skin, short braids/stubble, practical navy coat/brass armour/trousers/boots, same right-facing weaponless grip stance, full head/boots and clean alpha. The first close-up female candidate/edit were not accepted; only the compact full-body candidate is live.

## Additive production batch — three new playable beta looks

The two accepted presets above are unchanged. Three additional standalone bodies are selectable through the same avatar/pose/weapon/vignette hooks:

| ID / runtime filename under `art/sprites/wanderers/beta/` | Actual visible design | Selected generation output |
| --- | --- | --- |
| `nightstage_drifter` / `nightstage_drifter_idle.png` | Adult androgynous-compatible alternative presentation; olive skin, violet-tipped shag, liner, ear stack/choker, geometric tattoos, black leathers, violet sash, chain belt and heavy boots. | `exec-46659a03-8799-4d00-8735-8f3d826805ff.png` |
| `velvet_astrologer` / `velvet_astrologer_idle.png` | Adult feminine arcane glamour; brown skin, silver braids/cuffs, plum/gold bodice and split overskirt over leggings, jewellery and elegant boots. | `exec-847ead84-7c77-43a0-be4d-9c3d6522852f.png` |
| `ashtrail_hunter` / `ashtrail_hunter_idle.png` | Adult masculine rugged hunter; weathered pale skin, auburn hair/beard, scar, green leathers, fur, bronze pauldron, bone trophy/pouches and practical boots. | `exec-718bdc33-42da-4606-a620-3320c56a1c9c.png` |

Built-in imagegen, not CLI/API or downloaded third-party art. Each is 1024×1536 RGBA, weaponless, right-facing, with per-preset measured front-hand/Core/portrait anchors. Original outputs remain in the tool-generated source folder. Initial Astrologer/Hunter outputs (`exec-f87da680-deec-47f0-bacb-6efdd07dcd12.png`, `exec-fdb0a72d-8715-4218-84f9-e17d5134f708.png`) had residual background alpha and were rejected before checkpointing. Background-extraction edits produced the selected clean exports; these are new beta designs, not edits to accepted characters. Empty corners/exterior points and opaque hand anchors were checked; native 480×854 selector/Hideout/title/combat captures inspected for halos/crops and weapon alignment. No canonical Lootling art was edited.

Prompt set: original premium painted dark-fantasy adult full-body runtime cutouts, subtle anime appeal, transparent portrait canvas, three-quarter facing right, stable ready stance and empty visible waist-level front grip; full head/boots, no baked weapons, scene, shadow, glow, text, protected designs/logos or copied musicians. Vault Runner supplied material/render-quality reference only, not a coat/body template. Subjects: olive-skinned androgynous Nightstage Drifter with violet shag, liner/piercings/tattoos, sleeveless charcoal leathers/purple sash/chain belt/boots; dark-skinned glamorous Velvet Astrologer with silver braids, plum/gold covered bodice, small exposed midriff, split skirt/leggings and elegant boots; mature pale muscular Ashtrail Hunter with auburn beard/scar, green short-sleeved gambeson, fur/bronze shoulder, rust-brown straps/trousers/boots, utility pouches/bone trophy. Extraction edit requested preservation of supplied identity/outfit/full body, removal of haze/backdrop/shadow/stray exterior alpha, zero-alpha corners and clean fine hair/fabric. These exports are not registered modular layers.

### Appearance export contract

`WandererCatalog.APPEARANCE_SLOTS` defines face, skin tone, hair style/colour, facial hair, makeup, markings, jewellery/piercings, headwear, upper/lower outfit, footwear, gloves/bracers, back item, armour accents, accessories and style. `appearance_manifest(preset_id)` resolves real baked component IDs. Schema 3 adds a versioned `appearance` snapshot to existing nested Wanderer data; older profiles derive it automatically. Sanitization rejects invented modular combinations and derives components from the real preset. Appearance is stat-free. Pronouns/origin/lineage/bark style remain independent of presentation/gender.

Component IDs establish the future registered export contract, NOT separate unlocked items/controls. Destination: `art/sprites/wanderers/production/<preset_id>/<slot>_<component_id>.png` (1024×1536 RGBA, identical body registration/feet baseline/hand anchors, transparent unused pixels). Separate upper/lower/arm/back/head/hair/accessory layers must be inspected in all twelve weapon stances before independent swaps are enabled. Jewellery, choker, belt, boots, hair and alternative/arcane/hunter outfits are genuinely visible now, but baked into each authored preset. Infernal/elegant-rogue/lighthearted sets, independent layers and articulated two-hand/ranged poses remain pending.

## Honest limits

These are five **authored beta presets**, not a modular character creator. Body/skin/face/hair/outfit fields describe the actual selected artwork and are sanitized to that preset. Lineage is lore-only. Origin and bark style change short written flavour; pronouns are editable/persistent. No nonexistent hair/skin/outfit sliders are exposed. Layered arm/hand poses are still required for genuine two-hand grips, bow drawing and independent limb counter-motion. Current presentation uses the existing action phases with measured body/hand/weapon/projectile sockets; paired daggers remain a single existing paired-blade texture. Sling retains the existing honestly pending family fallback. Neither limitation disables its existing mechanics.

## Next production exports (not secretly implemented)

For each enabled adult body, supply transparent RGBA **1024×1536** registered pose/layer exports with a shared feet baseline, body origin and primary/secondary hand sockets. Suggested destination `art/sprites/wanderers/production/<body_id>/`:

- `body_idle.png`, `body_anticipate.png`, `body_attack.png`, `body_recovery.png`, `body_hurt.png`, `body_victory.png`: same proportions/head/skin/outfit; right-facing, full-body, no baked weapons/background/shadow.
- `arm_back_<family>_<phase>.png`, `arm_front_<family>_<phase>.png`: same registration and sleeves/skin; 12 family-specific primary/secondary grips, separate charge/release for ranged families. Empty non-arm pixels transparent.
- `face_<id>.png`, `hair_<id>_<colour>.png`, `outfit_<id>_body.png`, `outfit_<id>_arms.png`, `head_<id>.png`, `cape_<id>.png`, `jewellery_<id>.png`: registered modular layers, no baked weapon or Core spell effect. Start with the two live presets before advertising four remaining frames or additional variants.
- `portrait_<preset_id>.png`: optional clean 512×512 bust/face, transparent. Current HUD derives a safe face region from the standalone runtime body, not from a multi-character board.

Other four body frames, expanded skin/face/hair palettes and glam outfits require matching authored layers before player-facing controls are enabled. Existing tiny-creature cosmetics remain separate: adult outfits must never be pasted onto canonical Lootlings. `wanderer_pose_catalog.gd` is the replaceable attachment hook; weapon textures/stages remain `weapon_catalog.gd` authority.
