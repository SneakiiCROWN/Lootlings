# LOOTLINGS — CONTINUOUS FULL COMPLETION DIRECTIVE

This package is the project-wide completion scope. Do **not** revert to 27-cell starter scope or stop for individual missing/rejected art.

## Intake behaviour
- Validate the entire delivered inbox each run.
- Install/register every exact cell that passes canonical, technical and native visual checks.
- A failed/missing cell blocks only that exact slot. Add it to `ART_CORRECTIONS_REQUIRED.json` and continue.
- Never replace a valid accepted cell with TEMP, generic rig, reference card or lower-authority identity.
- Preserve save/economy/input/combat timing unless a bug fix explicitly requires otherwise.
- Do not require all siblings in a weapon family/entity to pass before installing independent valid cells.

## Game-wide player-facing polish in the same completion programme
Fix human-visible runtime issues without requiring new art where the master spec says UI/VFX art is REUSE_EXISTING:
1. **Selection truth:** Areas/Regions/Dungeons/Raid/Siege/difficulty/loadout/character/companion screens must have one authoritative selected value. On selection change, old selected styling clears immediately and the new selection highlights immediately.
2. **Focus vs selection:** keyboard/controller focus, hover and persistent selected state must be separate; leaving a control must not erase selection and changing selection must not leave the previous item highlighted.
3. **Layer/z-order:** only the active modal/panel is interactive and visually above its parent. Hidden screens cannot remain visible, clickable or consume touches.
4. **Touch isolation:** buttons, cards, scrolling, purchases, rewards, upgrades, Home editing and HUD controls consume touch; no input leaks into ATTACK or controls underneath.
5. **Responsive layout:** phone 1080x2340 and tablet 1200x1920, safe areas, no clipped text, enemy names, cards, bars or buttons; natural swipe scrolling.
6. **Navigation:** Back/Leave returns to the correct immediate parent; Hub → Home → Hub remains separate and deterministic.
7. **State refresh:** every screen rebuild/refresh reflects the saved/current selected IDs rather than stale visual state from the last pressed control.
8. **Acceptance route:** run a native end-to-end player path across region selection, dungeon/raid tabs, difficulty, combat, reward, Hub, shops, Home, companion and save/reload; capture failures in one correction report.

## Completion rule
Continue forward until normal owner/tester routes contain no known `POSE ART PENDING`, TEMP actor, generic rig, rejected identity, stale selected highlight, accidental UI-overlap interaction, or invalid weapon contact for a slot that has accepted art.
