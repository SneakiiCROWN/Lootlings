# Phase 4E independent FIX work / art delivery readiness

2026-10-05. Preserved the current branch and every prior checkpoint. No reset, revert, new reconciliation or Phase4F. Implementation checkpoints: `ed5203d` (feedback/nameplate) and `bce1e73` (approved phase routing). No canonical replacement asset is claimed completed.

## Implemented

- Projectile landings now retain flight direction, weapon and struck material. Physical arrows/bolts produce directed material contacts; sling has a heavier dust/contact arc. Frost crystal fragments, rising flame, lightning forks, poison bubbles, corruption wisps and arcane seals distinguish elemental hits. The existing brief .24-second lifetime and 16-effect cap remain; no damage, attack clock, reward odds or balance changes.
- Pack projectile hit effects no longer depend on the selected member still being the struck member. The visual snapshot uses the live struck serial/material without changing selection, HP or RNG. Dead/missing targets receive no false hit effect.
- Rarity burst time starts at actual result lock. A delayed frame no longer consumes Legendary/RED emphasis before drawing it. Premium holds, six tiers, low-tier skip/fast rules, pity, prices and cue hooks remain.
- Native review exposed the machine's tiny rarity nameplate using the menu's oversized ornate nine-slice. A dark inset, cached nameplate restores readable tier text without crushed corner decorations. The existing machine frame/reels remain.
- Approved authored pose manifest rows can now route WINDUP/ANTICIPATE, STRIKE/CAST/ATTACK, IMPACT, RECOVER, HURT and IDLE through existing phases. Missing optional exports retain the working READY/RELEASE pair. Existing published exports have only READY/RELEASE, so this adapter change preserves their current visible selection. No unapproved row, board or prototype is imported/promoted. Movement/defeat/victory exports still require explicit asset-specific integration when delivered.

## Active art queue / external requirements

All 52 exact canonical register entries remain open where recorded. The derivative [per-asset requests](../polish/replacement-export-requests.json) and [delivery contract](../polish/ART_EXPORT_CONTRACT.md) specify each ID's source identity/problem, states, both views, PNG transparency/canvas, socket needs, reusable rig and existing approved rows to preserve. Current merchant delivery requirements retain Merrow/Pack Peddler's existing role; no future NPC is promoted. These are specifications for approved art, not synthetic final artwork.

The authored support-art count stays **165 cells (82 right / 83 left)**. Moonkip still needs a proper weaponless redraw/export, Gloomlet its canonical combat body, and the other rejected bodies approved combat-state packages. Glimmerfin already has a weaponless idle. Regional proxies, missing boss phases/bodies and NPC puppets remain TEMP. Hoard Dragon's source tail remains REPLACE; proportional rendering is preserved and no crop/squash/FX hides it. No external approval was inferred from a concept board.

## Evidence and verification

- 80 matched native impact captures: frozen pre-change drawing comparator and current renderer, seven labelled bow element previews plus staff/orb/sling, both real target-facing arrangements, 1080×2340 phone and 1600×2560 tablet. Real projectile launch/landing code executes; element overrides are QA previews, not evidence of new gameplay elements. Both per-system and engine-wide RNG are fixed. Comparison crops show the same enemy/attack result; improved effect identities remain compact and below numbers. [Comparison 1](projectile_compare_1.jpg), [comparison 2](projectile_compare_2.jpg), [128-image manifest including machine](native-manifest.json). Full-resolution originals remain in the manifest paths.
- 48 native machine captures: all six tiers, rolling/anticipation/reveal plus actual delayed-lock stepping, both layouts. COMMON/UNCOMMON/RARE/EPIC/LEGENDARY/RED are present. Forced rarity previews are labelled and grant no rewards. Legendary gold rays and RED branching energy survive the late-frame lock; corrected nameplates read cleanly. Skip/repeat, charge-once and premium return regressions pass.
- Real desktop process-boundary recovery: material, actor+weapon mastery, blueprint and RED item, each cut after durable reservation and after recipient commit before acknowledgement. The runner terminates only its owned isolated Godot process handle, then checks two fresh processes plus receipt replay. **8 cases / 16 fresh recovery verifications passed**, exact once, wallet/spins/sparks retained. This closes that defined desktop acceptance gap, not arbitrary mid-write power loss or Android lifecycle/device acceptance.
- Feedback, authored pose, contact/facing, 864 weapon-fit samples, Phase4E, spinner distribution/repeat, touch, typed-save and reward regressions pass. No changes to combat difficulty or the saved economy. Current contact flags remain zero; art debt is not zero.
- Final Android v18 / `0.4.9-phase4e-art-ready`: export, signing, 16KB alignment, arm64, SDK24–36, no-permission/offline package, ZIP integrity and changed compiled-script hashes verified. Existing bow/heavy imports and 456 source-documented PCM assets are retained. APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-art-ready-debug.apk`; 137,126,412 bytes; SHA256 `f41cecab276478c4a10fd2b9fad4c4e20d37c2dd8e24dc73daf61113e931abf1`. [Build receipt](build-report.json), [compiled-script comparison](exported-script-hashes.json).

Initial fixture failures were rejected: a missing typed Array annotation, untyped pack assignment, and StringName keys in synthetic save setup. Production save code was not altered to accommodate those fixtures; corrected setup uses actual production String keys. Earlier unseeded/partially seeded impact captures are superseded by the final matched comparator. All rejected local logs remain preserved; only accepted receipts are included here.

Drawing callbacks were checked against current official [CanvasItem documentation](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html); persistence API behavior against [ConfigFile documentation](https://docs.godotengine.org/en/stable/classes/class_configfile.html), and the actual restart result against installed Godot 4.7.2. Neither API documentation nor a successful write is treated as proof of cross-store acceptance: the fresh-process test supplies that narrower evidence.

## Remaining acceptance gates and shortest S23 retest

Repo fixes above are completed and checkpointed. Current missing replacement packages require approved authored art, not further procedural proxies. Final body/monster/NPC visual acceptance and final audio/mastering/perceptual judgement remain external. Broader save semantic/power-loss acceptance is still separate from the tested reward boundaries; physical S23 loading, frame pacing/FPS, memory/rendering, input and lifecycle remain device gates. Existing authored dialogue/repetition logic, Homestead activity/routes, weapon timing, sound families and menus are preserved; this is not a new full-project re-audit or full acceptance claim.

Install v18 over the current test app without clearing data. In one run, use bow/staff/orb/sling and switch sides; check compact distinct hit effects and unchanged contacts/facing. Open the Relic Engine, check tier/nameplate readability and repeat/skip behavior; watch Legendary/RED if legitimately available, without spending to chase a forced tier. Background/return during combat and a reveal, then relaunch once and verify inventory/currency/rewards. Report visual judgement, sound judgement, stalls or input errors. Repo-side process tests do not require owner participation.

## Multidisciplinary sign-off (continuation scope; full Phase4E remains unaccepted)

| Discipline | Status | Evidence / remaining issue |
|---|---|---|
| DESIGN | ISSUES | Stronger differentiated contacts retained; final visual feel requires owner acceptance. |
| BALANCE | PASS for unchanged scope | Damage/timing/difficulty untouched; contact/stat/RNG contracts retained. |
| ECONOMY | ISSUES | Prices/odds/chase unchanged, all four reward recipients pass tested restarts; broader save semantics/device gates remain. |
| ROSTER | ISSUES | Twelve identities locked; approved combat-body/weaponless packages missing. |
| ENEMIES | ISSUES | Regional bodies/proxies require the registered authored replacements. |
| BOSSES | ISSUES | Dragon source tail, distinct missing boss bodies/attack exports remain. |
| RNG | PASS for changed scope | Presentation does not draw gameplay RNG; matched native comparisons seed all relevant RNG. |
| UI/UX | ISSUES | Nameplate/delayed reveals corrected; final owner/mobile acceptance remains. |
| NARRATIVE | PASS for unchanged scope | Existing contextual voice/repetition contract passes; no new canon or board-derived IDs. |
| AUDIO | ISSUES | Existing licensed material/weapon/boss/reward cues retained; no new mastering/perceptual sign-off. |
| MOBILE | ISSUES | Phone/tablet native readability and export pass; S23 hardware/lifecycle/input not tested here. |
| QA | ISSUES | Scoped regressions/native/process tests pass; external acceptance gates remain. |
| PRODUCTION | ISSUES | Separate safe checkpoints and exact asset requirements delivered; art/owner/device dependencies prevent release acceptance. |
