# LOOTLINGS — ASSET PRODUCTION & INTEGRATION PIPELINE v1

## Division of Work

### ChatGPT handles by default
- concept art generation
- standalone transparent visual assets
- icons, chests, weapons and character references
- environment/reference boards
- HUD/menu visual direction
- texture generation/reference preparation
- legal/commercial-safe asset research
- license checking and source documentation
- audio source research
- music/SFX direction
- downloading and packaging public commercially-safe assets when technically possible
- asset manifests and provenance files
- Codex-ready integration prompts
- comparing rendered screenshots/recordings to the Style Bible

### Codex handles by default
- Godot integration
- code changes
- animation hooks
- sprite pivots/attachment points
- projectile spawning
- VFX implementation
- AudioBus setup
- importing/compressing assets
- UI scene/layout implementation
- runtime QA/test updates
- Git commits/pushes
- safe project-wide refactors when genuinely necessary

## Credit-Conservation Rule
Do not spend Codex credits on tasks ChatGPT can prepare externally.

Preferred flow:
1. ChatGPT creates/researches/prepares the asset.
2. The asset is placed into the project/reference folder.
3. Codex receives a narrow integration prompt.
4. Codex integrates, tests and validates.

Use Codex for generation/research only when local project context makes it clearly more efficient.

## Visual Asset Rules
Prefer:
- transparent PNG/WebP where appropriate
- isolated subjects
- no baked-in text unless intentional
- no watermarks
- no copyrighted logos
- no copied franchise silhouettes
- readability at target game size
- clean crop/padding
- known intended display size

Each runtime asset should have:
- descriptive filename
- intended use
- target approximate display size
- pivot/orientation notes if relevant

## Audio Asset Rules
For every sourced audio file record:
- filename
- source
- creator if applicable
- license
- source reference/URL
- attribution requirement
- modifications made
- intended use

Prefer CC0, original/generated or clearly licensed commercial-use royalty-free assets. Use CC-BY only when attribution is practical and documented.

Never assume “free download” means commercial-use safe.

## Source-Pull Rule
1. Search current source/license information.
2. Prefer the original publisher/creator page.
3. Verify commercial-use terms.
4. Avoid scraped/rehosted assets when the original exists.
5. Download only what is useful.
6. Package the smallest curated set instead of giant asset dumps.
7. Include LICENSES / SOURCES documentation.

## Integration Handoff Format
Every Codex handoff should include:
- FILES: exact paths and filenames
- INTENDED USE
- DO NOT CHANGE: protected systems/economy/save behavior
- IMPLEMENT: narrow tasks
- VISUAL QA: states to capture at 480x854
- AUDIO QA where relevant
- VALIDATION: tests to rerun
- GIT: one clean commit only after stable

## Asset Priority Order
1. visible blocker in current build
2. repeated placeholder seen during play
3. core combat readability
4. loot/reward spectacle
5. HUD/menu presentation
6. player/enemy animation readability
7. audio repetition/weakness
8. environment polish
9. future content references

Do not generate future catalog art while obvious current placeholders remain.
