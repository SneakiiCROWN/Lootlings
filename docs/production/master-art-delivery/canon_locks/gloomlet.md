# Gloomlet — gloomlet

- entity_id: gloomlet
- identity_id: gloomlet
- display_name: Gloomlet
- category: playable_lootlings
- identity_sources: ["art/reference/canonical/characters/Gloomlet_CharacterSheet_Canonical.png"]
- proportions: Match head/body/limb ratios in the exact named canonical source panel; pose changes never change anatomy
- silhouette: Preserve full named entity silhouette and distinguishing ears/horns/tail/wings/clothing exactly as its locked source
- palette: Sample existing source colours; preserve intrinsic Core/markings; no palette swaps
- equipment: Permanent outfit/armour/props match canonical source. Interchangeable player equipment remains modular; locked 12 families only
- markings: Keep source-specific markings/materials/face/eye treatment in the correct anatomical locations
- scale_contract: {"canvas": [512, 512], "bounds": "Per exact cell; uniform scale only; native actor bounds preserved; do not enlarge TEMP art"}
- forbidden_identity_drift: ["Rejected broad-board bodies", "Different species/anatomy/outfit/palette", "Generic fox/cat/mushroom replacement", "Realistic redesign of accepted Wanderers", "New NPC/boss/region labels from boards"]
- explicit_lock: Black-purple furry Assassin, magenta ear interiors, violet eyes/Core, clawed partial armour, full canonical tail; dedicated Gloomlet sheet wins.

Exact missing cells are in the master JSON; different poses never create a different identity.
