# Reference organization and preservation

Completed 2026-10-01 against stable fallback `2bdcb7d07e560e45d3a23bb230765cf5e2124f8f`.

## Authority and layout

- `canonical/characters/`: unchanged original neutral Relic Beast, six named character sheets and shared class template. These alone define playable character identity. The Emberhorn and class-template files have identical bytes but retain their distinct established roles.
- `docs/`: one copy of the authoritative universe bible, catalog, manifest, current art rules, priority matrix, status template, permanent style/pipeline handoff, complete art scope and supplied platform research. Research is supplied planning information, not a new platform verification.
- `source/established_presentation_boards/`: existing gameplay/equipment/style targets, not replacement character identities.
- `source/production_boards/`: five supplied broad concept boards, reference only; not canonical character designs or runtime assets.
- `source/canonical_extract/`: supplied supplemental crops plus their manifest and caveat README. Reference only; never enable gated content with these crops.

Other canonical domain folders (weapons, enemies, bosses, environments, props_chests, ui_icons, vfx, marketing) should receive genuinely approved source assets when supplied. They are not populated with broad concept boards merely to fill the structure. Runtime assets remain in `art/sprites`, `art/backgrounds`, and `art/audio`, unchanged by this consolidation.

## Merged historical instructions

Old pack installation READMEs, the completed Master Production next-pass prompt, and the completed Visual/Audio Rescue prompts are no longer active project instructions. Their durable rules are retained here, in current art rules, and in the root project/design/provenance/status documentation:

- Never restore an old project ZIP over the live repository or restart validated systems.
- Preserve canonical neutral mascot identity exactly; Emberhorn remains separate.
- Concept boards and sheet crops are references, not production runtime art.
- Named characters, missing weapon families and future data-only content remain gated until clean runtime assets exist.
- Preserve validated saves, combat cadence, economy, reward odds and three-zone structure.
- Player-visible OpenGL 480x854 inspection and actual audio-path QA are required; code-only tests do not prove presentation quality.
- External assets require verified commercial permission and provenance. No external downloads were integrated in the rescue pass.
- The malformed Hoard Dragon is an explicit art blocker, not final accepted anatomy.

## Audit and recovery

`REFERENCE_CLEANUP_AUDIT.csv` inventories every original file with size, original SHA256, final destination/hash or reason for removal. Images and documents preserve bytes except the current art rules and permanent handoff, whose path references were refreshed and explicitly recorded. The production ZIP was removed only after every entry matched an existing loose file by SHA256. Three duplicate master documents, two duplicate extracted boards and two `(1)` boards were hash-verified before removal. All unique image sources and permanent design/provenance documents survive. Reference-only Godot import metadata was removed; the root `.gdignore` prevents new reference imports. Runtime import settings are untouched.

Historical tracked files and reference import metadata can be recovered from Git at the fallback checkpoint above. Untracked duplicate ZIP/copies are redundant with retained byte-identical files; their hashes are recorded. Completed untracked task prompts are merged as durable rules above rather than retained as live instructions. No unique production art was deleted.
