LOOTLINGS — S23 HUMAN PLAYTEST FOLLOW-UP

Continue from the current clean pre-device RC.

Do NOT restart the full audit and do NOT blindly rerun expensive unchanged simulation suites.

The first real S23 human recordings have now been reviewed.

Preserve everything that already works.

Apply this focused human-QA polish pass:

1. HUB CLEANUP
- Preserve the current Hideout artwork and physical fantasy-hub presentation.
- Reduce at-rest clutter.
- Begin Expedition remains dominant.
- Keep Gear / Upgrades / Shop / Archive discoverable but quieter.
- Do not permanently display large NPC/dialogue panels unless that NPC is selected.
- Collapse the Expedition Loadout presentation when not being inspected.
- Reduce unnecessary simultaneous labels while preserving touch accessibility.

2. COMBAT HUD CLEANUP
- Reduce permanent HUD visual weight.
- Keep HP/Ward, XP/level, Run Scrip and wave information clear.
- Move deeper Core/build details behind Pause/Details rather than permanently occupying the lower combat screen.
- Make Tap Combo a compact readable indicator rather than another large layer.
- Preserve mobile readability.

3. COMBAT TEXT/VFX NOISE
- Reduce simultaneous floating combat text.
- Prevent CRIT/proc/effect text from stacking into visual noise.
- Use a compact proc icon/indicator where appropriate.
- Reduce routine use of “YEET!” substantially; if retained, make it a rare special/large-knockback Easter egg rather than normal combat feedback.
- Keep enemies readable through impact VFX.
- Preserve elemental identity.

4. REWARD / MODAL FLOW
The choices are good but there are too many successive full-screen modal steps.

For normal Pick One upgrades:
- tapping a card selects/highlights it
- use one explicit footer action such as TAKE [ITEM]
- avoid opening a second full-screen confirmation panel for ordinary upgrades

This preserves accidental-tap protection through two intentional actions without doubling the number of modal screens.

Keep separate confirmations for genuinely destructive or unusually expensive actions.

Apply the same principle to run merchants:
select offer -> inline details -> BUY [COST] — ENDS THIS STOP.

5. RUN ECONOMY — IMPORTANT
The human footage shows Run Scrip rising roughly:
118 -> 127 -> 196 -> 219 -> 265 -> 343 -> 399 -> 492 -> 627 -> 708

At the observed Wave-6 merchant, standard offers were roughly 94 Run Scrip and reroll was 36.

The one-purchase rule is correct, but the footage suggests Run Scrip may now accumulate much faster than meaningful sinks can consume it.

Do a focused faucet/sink simulation using the existing valid harness.

Measure:
- wallet at each merchant/event decision
- price-to-wallet ratio
- percentage of earned Scrip actually spent
- end-of-run unused Scrip
- reroll use
- premium/save behaviour

Do NOT simply crush income.

Create useful tension between:
- buy now
- save for a premium later option
- reroll
- spend through event/risk opportunities
- skip

Use later/premium sinks and sensible scaling where evidence supports them.

Money should remain exciting to earn but strategically useful to spend/save.

6. MENU VISUAL HIERARCHY
Standardise visual importance:

- ornate gold: primary/important choice
- simpler blue: secondary/navigation
- red: destructive/scrap
- minimal/text treatment: tertiary

Do not give every control equal ornamental weight.

Keep the Lootlings aesthetic.

7. MEMORY ARCHIVE / PLAYER-FACING DEV TERMINOLOGY
Remove player-facing technical copy such as:
“9-second replay”
“11-second replay”

Replace with in-world memory/echo terminology.

Keep durations/internal details out of normal player presentation.

Also move Support ID/internal support information out of the main Profile presentation into an appropriate support/settings area if it is not needed constantly.

8. SALVAGER STALL
Keep current functionality but improve hierarchy:
- featured persistent gear as the main offers
- caches/stash expansion/utility options visually secondary
- avoid six equally dominant cards competing at once

9. AUDIO MIX TECHNICAL CHECK
The recorded files measure approximately:
- title/hub: ~-27 LUFS, ~-6 dBFS peak
- combat: ~-13 to -11.5 LUFS, peaks near -1 dBFS

First verify this is genuinely game-bus balance and not a device-volume recording difference.

If game-side:
- rebalance music/ambience/weapon/impact/creature/UI buses
- preserve character/species identity
- leave sensible peak headroom
- reduce harsh simultaneous SFX stacking

Do not replace good authored species sounds merely to change loudness.

Final subjective creature/music acceptance remains a human listening gate.

10. PERFORMANCE WATCH
The S23 report is around:
- 60 FPS
- frame p95 ~20 ms
- p99 ~23 ms
- combat p95 ~22 ms
- very few frames above 33 ms

Do not introduce performance regressions during these presentation changes.
Reduce unnecessary combat-text/VFX churn where that also improves readability.

11. DO NOT REPEAT UNCHANGED WORK
The footage did NOT physically cover every character, weapon, bow, boss or region.

Reuse the existing valid character x weapon x pose/native evidence for unchanged renderer/pose systems.

Only rerun those expensive matrices if this patch changes the relevant renderer/weapon/pose code.

Keep known genuine authored-art blockers explicit.

12. FOCUSED ACCEPTANCE
After implementation:
- native S23-sized hub capture
- combat capture
- Pick One flow
- run merchant flow
- Salvager Stall
- Memory Archive
- focused touch regression
- reward/economy regression
- audio mix QA
- save regression
- Android build/package/sign/alignment checks

Automated merchant test must verify:
- reroll/skip before purchase
- one purchase maximum
- double/rapid tap cannot buy twice
- buying resolves the stop
- run resumes normally

Leave physical checks pending for:
- real creature/music listening
- S23/S24 thermals
- background/resume
- bow/alternate-character spot checks where not already physically viewed

Checkpoint valid changes and give the new APK path.