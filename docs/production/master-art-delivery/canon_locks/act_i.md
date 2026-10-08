# The Hoard Dragon — act_i

- entity_id: act_i
- identity_id: hoard_dragon
- display_name: The Hoard Dragon
- category: bosses
- identity_sources: ["art/sprites/enemies/hoard_dragon.png"]
- proportions: Match head/body/limb ratios in the exact named canonical source panel; pose changes never change anatomy
- silhouette: Preserve full named entity silhouette and distinguishing ears/horns/tail/wings/clothing exactly as its locked source
- palette: Sample existing source colours; preserve intrinsic Core/markings; no palette swaps
- equipment: Permanent outfit/armour/props match canonical source. Interchangeable player equipment remains modular; locked 12 families only
- markings: Keep source-specific markings/materials/face/eye treatment in the correct anatomical locations
- scale_contract: {"canvas": [2048, 2048], "bounds": "Per exact cell; uniform scale only; native actor bounds preserved; do not enlarge TEMP art"}
- forbidden_identity_drift: ["Rejected broad-board bodies", "Different species/anatomy/outfit/palette", "Generic fox/cat/mushroom replacement", "Realistic redesign of accepted Wanderers", "New NPC/boss/region labels from boards"]
- explicit_lock: Established wingless/coiled violet-obsidian-gold Hoard Dragon; ONE continuous tail. Existing source tail is defective, not an accepted anatomy template. No winged quadruped redesign.

Exact missing cells are in the master JSON; different poses never create a different identity.
