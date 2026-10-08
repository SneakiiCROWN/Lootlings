# Lunarwisp — lunarwisp

- entity_id: lunarwisp
- display_name: Lunarwisp
- category: companions
- identity_sources: ["art/reference/canonical/companions/Lootlings_Companion_Collection_Canonical.png", "art/reference/canonical/companions/Lootlings_Companion_Implementation_Pack_Canonical.png"]
- proportions: Exact named canonical companion panel
- silhouette: Exact named panel; no species/appendage replacement
- palette: Canonical source colours unchanged
- equipment: None; cosmetic companion only
- markings: Match named source panel
- scale_contract: {"canvas": [256, 256], "runtime": [56, 56], "bounds": [32, 24, 224, 224]}
- forbidden_identity_drift: ["Species/palette/name change", "Playable identity override", "Combat/stat power"]

Exact missing cells are in the master JSON; different poses never create a different identity.

New launch states: perch_rest and perch_interact, both independently authored views, same canonical identity. Full exact requirements in HOME_COMPANION_INTERACTIONS.json and master cells.
