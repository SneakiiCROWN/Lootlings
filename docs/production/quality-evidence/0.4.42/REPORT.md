# 0.4.42 connected item presentation

Continues pushed 0.4.41 `741ff4a` in the live folder. Approved artwork, title theme, game mechanics, economy and saves are preserved. This is an internal tested candidate, with professional full-game acceptance still open.

## Actual playable changes

- Shop, Stash, Pack Peddler, perk and reward cards reuse the approved cool crystal resting frame and warm gold selected frame. Shared skin instances are duplicated before per-card tinting.
- Large cards show a persistent gold selection tick. Switching cards clears the old tick immediately; keyboard focus remains independent. The mark ignores input and never changes item effects or purchase rules.
- Pack Peddler icons are children of their respective offer buttons. The previous 108-versus-96 row-spacing mismatch caused later icons to cross card edges; artwork now stays inside every offer.
- The previous Shop comparison padding/type improvement remains installed and tested.

Runtime files changed in this pass: `lootlings_ui.gd`, `lootling.gd`, `export_presets.cfg`. Updated fixtures: `player_route_polish_native_qa.gd`, `compiled_candidate_native_qa.gd`; new `cohesive_cards_native_qa.gd`. Generated registry/dashboard, evidence and coordination files are refreshed separately.

## Native evidence and checks

Source route fixture passes Home → Hub → Shop purchase → Stash → Shrine → earned Relic Engine → combat → perks/rewards/results → Hub at 1080×2340, 1200×1920 and 1920×1080. Additional native merchant/perk tests verify actual touch selection, immediate old-selection clearing, focus separation, icon containment, modal input isolation and unchanged funds/attack count. Current captures and logs are beside this report.

Actual exported Windows PCK passes both candidate purchase/return and merchant/perk fixtures at those three dimensions; it loads all 48 newly accepted 0.4.41 textures. Android verification confirms those 48 imported texture bytes and both runtime manifests match local imports; Windows/Android branding comparisons pass. This does not substitute for physical Android testing or subjective sound listening.

Candidates:

- `builds/android/Lootlings-0.4.42-cohesive-item-cards-debug.apk`, signed arm64, version code 51.
- `builds/windows/Lootlings-0.4.42-cohesive-item-cards.exe` plus matching PCK.

## Accurate remaining scope

This UI pass closes **zero authored-art contracts**. Previous multi-family integration closed 48 exact contracts / 96 artist files: Bell Bat 12, Rime Pup 12, Coal Pup 12, Patch 6, Ilex 6. Those are canonical runtime keyframes, not full multi-frame animation families.

Frozen totals remain **191 installed / 3,083 remaining contracts** and **419 installed / 8,076 remaining artist files**. Broad registry: **7,585 mixed requirement records / 6,513 launch slots**, not unique images. The sole production dashboard distinguishes all seven gates; no blanket production-ready acceptance is granted.

Outstanding visible priorities: playable opposite-facing reference fallbacks and missing modular grips; complete motion/attack families; resident route/work/sit; Sera/Merrow bodies; Home/Hub prop cohesion; oversized single-find reward panel and perk comparison phrasing; full perceptual audio review; physical S23 performance, audio and save review. Title music remains unchanged. No new audio is claimed in this pass.

Next broad pass: complete compatible playable body/action/grip families that remove the normal combat route's reference fallback, alongside enemy/NPC motion and contextual reward layouts. Preserve accepted keyframes and working progression; quarantine independent failures.
