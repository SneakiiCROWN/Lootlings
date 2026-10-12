# LOOTLINGS — PREMIUM QUALITY PRODUCTION DIRECTIVE
## Resume Interrupted Work | Professional Visual, Audio, Gameplay & Progression Overhaul

**OWNER-APPROVED, GAME-WIDE, NON-NEGOTIABLE PRODUCTION STANDARD**

Continue developing the EXISTING Lootlings game.

Project: `C:\Users\Snkii\Documents\lootlings`  
Repository: `SneakiiCROWN/Lootlings`  
Production branch: `codex/phase4e-gamefeel`  
Last verified delivery: 0.4.65, commit `6fa78256`  
Verified runtime source checkpoint: `0a3c4ba0`

The previous 0.4.66 Work session was interrupted by the usage/credit limit. It may contain unfinished source changes.

**FIRST: Reconcile actual HEAD, local changes, unfinished 0.4.66 work, latest handoffs and rollback evidence. Preserve everything useful. Never assume the historical checkpoint is current HEAD.**

## 1 — PERMANENT QUALITY STANDARD: AAA-INSPIRED EXECUTION

The owner requires Lootlings to feel like a carefully art-directed, professionally developed premium game from beginning to end.

This standard applies to EVERYTHING:

- Title, boot, splash, loading and transitions.
- Hub, Home, regions, arenas, environments and backgrounds.
- Playable characters, NPCs, companions, enemies and bosses.
- Movement, stances, facing, grounding, animation and weapon contacts.
- Music, ambience, audio mix, attack impacts, voices and interface feedback.
- Combat, weapons, DPS, perks, buffs, debuffs, equipment, relics, loot and progression.
- UI, HUD, typography, dialogue, menus, shops, tooltips and every displayed number.
- Touch, mouse, keyboard, accessibility, save safety and performance.
- Rewards, collections, discoveries, long-term motivation and endgame.

**Functional is not the same as polished. Passing an automated test is not professional presentation acceptance.**

Aim for high-budget-quality craftsmanship and cohesion within realistic indie production resources. Do not imitate or copy another game's copyrighted art.

No generic AI-looking asset soup, default Godot-looking UI, poor fonts, static floating NPC cutouts, mismatched perspectives, placeholder props, random coloured buttons, misleading numbers, repetitive bleeps or excessive particle clutter.

No screen should feel disconnected from the rest of Lootlings.

Treat this as a permanent project-wide quality gate. Add it to the authoritative production standards and relevant handoffs so future development follows it.

Do not claim the entire game is professionally complete until that has been demonstrated.

## 2 — CREDIT-CONSCIOUS EXECUTION RULES

The owner has limited Work/Codex usage. Maximise real, playable progress per run.

DO NOT:
- Restart or redesign the game from scratch.
- Repeat huge audits that have already produced verified evidence.
- Generate another giant speculative plan instead of implementation.
- Spend hours generating hundreds of unrelated sprites.
- Recreate an already accepted canonical asset.
- Rebuild successful APKs after every tiny change.
- Run exhaustive simulations unrelated to the code being modified.
- Spend the entire credit allowance reporting problems without fixing them.
- Change core gameplay balance to make test results look impressive.
- Abandon half-finished work when a new priority appears.

DO:
- Inspect the minimum authoritative files needed to resume safely.
- Identify near-complete changes and release-critical defects first.
- Use existing canonical art, shared systems, scene components and test harnesses.
- Choose cohesive, noticeable player-facing improvements.
- Fix underlying design and placement issues instead of stacking UI workarounds.
- Work in integrated, testable production batches.
- Preserve one live repository writer.
- Keep source commits at meaningful safe boundaries.
- Reserve enough of the session for exported-game QA, packaging, screenshots and handoff.
- Deliver one final tested candidate per stable milestone.
- If the session cannot finish the full scope, complete and verify the highest-value slice and leave a precise continuation point.

**Prioritise the finished quality of an important playable slice over superficial edits across fifty unfinished screens.**

## 3 — FIRST PRIORITY: RECOVER AND FINISH ACTIVE 0.4.66 WORK

Inspect the interrupted work and determine exactly which high-rarity, affix, status stacking, damage, relic, combat timing, Dungeon/Rift/Siege, save or UI tasks are already in progress.

Finish near-complete fixes with clear safety or gameplay value.

Protect previously delivered:
- Save-failure rollback and reward persistence.
- Cosmetic/gameplay RNG separation.
- Earned-only spins.
- Real equipment comparisons.
- Correct capped perk descriptions.
- Existing Mythical Shiny identities.
- All three primary currencies.
- Existing character, region, lore and equipment canon.
- Original title music, branding and normal/owner save isolation.

Do not spend the whole next run on balance simulations. The owner now specifically prioritises visible environmental and interface quality alongside remaining critical foundations.

## 4 — MAIN MENU: CREATE THE DEFINITIVE LOOTLINGS FIRST IMPRESSION

**Approved visual direction: a distinctive, atmospheric, living fantasy environment connected to the existing Lootlings world.**

Preferred concept: a carefully composed moonlit courtyard or appropriate canonical garden outside the established Hub.

This is a direction, not permission to invent unrelated architecture or discard accepted world design.

Inspect `startup_ui.gd`, existing title composition, accepted wordmark, canonical artwork, responsive backdrop, title music and UI themes before editing.

Current title code uses an existing ensemble with most controls hidden except START. Build upon or revise that composition intelligently rather than adding another cluttered layer.

### Desired first impression

When the game opens, it feels immediately premium, atmospheric, recognisable and welcoming.

Use:
- The original approved Lootlings logo, properly sized and framed.
- Beautiful environmental depth and coherent lighting.
- A restrained, original fantasy colour palette.
- Existing world architecture and flora where appropriate.
- One intentional environment or canonical character focal point.
- Clean visual space for menu controls.
- Smooth, brief and skippable entrance transitions.
- The approved original title music, professionally mixed.
- One dominant START or CONTINUE action.
- Quiet secondary Profile and Settings access, with appropriate desktop Exit functionality.

Avoid redundant buttons, hero portrait galleries surrounding START, giant decorative panels and generic marketing slogans.

The menu must look attractive even without animated effects.

### Environmental animation and atmosphere

Create a small shared, efficient ambient visual system.

Possible components—choose only those actually suited to the final environment:

**Tiny glowing torchbugs / fireflies**

Small, charming, pixel-like or painterly magical bugs with soft, restrained glow and natural drifting motion.

They exist purely for atmosphere.

They MUST NOT:
- Be touchable, clickable or collectable.
- Have gameplay hitboxes.
- Steal taps or mouse events.
- Block buttons or navigation.
- Resemble rewards or essential notifications.
- Affect combat, enemy, loot or perk random streams.

Use isolated cosmetic randomness.

**Petals**

Only if suitable flowering plants are actually present. Sparse falling petals with natural breeze movement and good depth placement.

**Water**

Only if the scene contains a believable pool, fountain or stream. Use subtle ripples and controlled reflections, not arbitrary animated blue overlays.

**Other environmental motion**

Tasteful lantern flicker, leaf movement, faint mist or ambient magic, only when they improve the composition.

Do not simultaneously add every effect just because it is possible.

The overall scene should feel alive during a long idle period without becoming distracting, repetitive, noisy or computationally wasteful.

Respect reduced motion, audio preferences, mobile performance and application foreground/background lifecycle.

No global gameplay RNG coupling.

### Main menu acceptance

Visually test:
- Initial boot.
- Title after entrance.
- Title after at least several minutes of idle.
- Start/Continue selection.
- Profile/Settings navigation.
- Reduced-motion mode.
- Phone, S23 portrait, tablet and desktop.
- Safe areas and screen resizing.
- Readability over background effects.
- Touch pass-through and controls.
- Audio continuity and no sudden clipping or excessive repetition.

Use actual compiled screenshots, not speculative mockups, as implementation evidence.

## 5 — HUB: RECOMPOSE THE ACTUAL WORLD AND ITS INTERACTIONS

The owner's current Android Hub screenshot is an explicit failing aesthetic and usability reference.

The existing layout looks assembled from floating UI elements, misplaced NPC sprites, labels and independent hotspots.

**Correct the scene composition itself. Do not simply change the font size or slide the buttons around.**

### Rebuild the spatial logic

Establish believable architecture, floors, grounding, foreground/background layers, foot positions, object scale, consistent lighting, shadows and visual depth.

NPCs must be anchored on appropriate surfaces, facing appropriate directions and naturally belonging to their stations.

Correct unintentional floating, disconnected or doubled elements.

Investigate suspicious rat-like patterns, scattered coin artwork and any decorative imagery that resembles placeholders. Identify their actual source. Remove or properly integrate anything that does not belong.

Do not turn the Hub into a wall of menus, signs, floating labels or unrelated decorative effects.

The location must be readable through environmental design and clear visual landmarks.

Where the existing Hub backdrop makes proper composition impossible, the owner approves a cohesive environment revision or replacement, subject to existing canon authority and asset approval.

### NPCs own their services

**Patch:** The player interacts with Patch at his believable merchant stall. His canonical character appears in the actual shop interface with fitting expression, dialogue and merchandise context. Do not make his shop feel like a generic unrelated menu.

**Sera:** Position Sera naturally at the upgrade/shrine location. Interacting with Sera opens permanent upgrades. Show Sera in the upgrade service itself. The shrine remains meaningful scenery; avoid a duplicate shrine button for the same service.

**Ilex:** Ground Ilex naturally near the Archive and preserve the character's identity within the Archive interface.

Extend this character-to-service principle to other existing relevant NPCs.

Where a service has no canonical NPC, use one intuitive environmental interaction.

### Labels and interactions

Character names should appear clearly near the correct character.

Use consistent, attractive text treatment and subtle interactive discovery instead of big permanent floating words everywhere.

Make the character or station the actual obvious touch target, with sensible accessible bounds.

Avoid doubled entry points, misplaced hitboxes, strange text wrapping and confusing station ownership.

NPCs should have natural, lightweight idle or interaction behaviour using accepted assets.

No cheap bouncing cardboard cutouts or fake animations that look worse than a good static pose.

The Hub should feel alive, approachable and immersive.

## 6 — PERSONAL HOME: SAME PREMIUM STANDARD

The owner has also rejected the current Home composition as visually cluttered, awkward and spatially inconsistent.

Review `personal_home.gd`, existing Home background, decor system, companion placements, saved customisations and interface layout.

Make the room feel like a genuinely inhabited personal space.

Fix:
- Illogical furnishings and poorly grounded objects.
- Companion orientation and placement.
- Misaligned or misleading touch regions.
- Awkward spacing and wasted areas.
- Floating controls unrelated to their corresponding objects.
- Overlapping labels and ugly UI frames.
- Decor choices that do not meaningfully affect the visible room.
- Inconsistent visual scale or perspective.

Where justified, revise the Home environment and its spatial anchors together.

Preserve all existing decor and companion data.

Make it a place players are proud to return to, with believable places for trophies, collected treasures, showcased gear and earned accomplishments.

## 7 — STRONGER REASONS TO PLAY, COLLECT AND GRIND

The owner wants meaningful motivation beyond endless waves, repetitive missions and slightly larger numbers.

Do not invent an unrelated progression game.

Deepen the EXISTING equipment, Forge, upgrades, achievements, Archive, companions, Home, bosses, Dungeons, Prism Rift, Relic Siege and collection systems.

Make desirable goals visible without aggressive notification spam.

Players should have:
- A short-term goal for the current session.
- A medium-term reward, collectible or equipment target.
- A long-term mastery or collection aspiration.
- A meaningful way to remember, display or use what they earned.

The gameplay loop should become:

Explore → discover valuable loot → develop a build → chase a specific challenge → earn a meaningful unlock or collection → show progress in Home or Archive → pursue the next goal.

**First connected vertical slice:**

Identify one existing accomplishment, boss trophy, collection milestone or desirable equipment family that can already be implemented with accepted content.

Connect:
1. Actual gameplay achievement.
2. Persistent reward or collection state.
3. Proper feedback.
4. Archive/collection tracking.
5. A visible Home display or other meaningful earned outcome.
6. Reliable save/reload and duplicate protection.

Complete this slice before proposing dozens of new progression screens.

Ensure old content retains its value.

Avoid meaningless grind padding, mandatory dailies, arbitrary permanent currencies, forced online play and endless stat inflation.

The Loot Gremlin and annual seasonal events are already owner-approved backlog features; they should eventually strengthen this system, but should not derail the present foundations.

## 8 — GAME-WIDE PROFESSIONAL TEXT, AUDIO, HUD AND FEEDBACK

Apply the same quality bar throughout the existing game.

Audit and correct text as each relevant route is touched, and maintain a tracked game-wide acceptance inventory for remaining screens.

Everything needs:
- Correct spelling, punctuation and natural writing.
- Character-specific dialogue personality and established lore continuity.
- Appropriate licensed fonts with consistent sizes and weights.
- Proper wrapping and alignment.
- No invisible names or clipped descriptions.
- No excessive unused screen space or clutter.
- Accurate damage, heal, critical, Ward, XP, status and currency figures.
- Accurate perk, affix, relic, weapon, buff, debuff and capped-gain descriptions.
- Clear, fast, original Lootlings equipment comparisons.
- Natural and accessible touch controls.
- Consistent sound quality, sonic identity and feedback hierarchy.
- Restrained, correctly aligned effects, weapon impacts and animations.
- Good mixing without repetitive high-pitched UI sounds.
- Stable performance and comfort settings.

Inspect actual native runtime output, especially longer names, rapid combat and dense menu states.

Do not add new UI text simply to compensate for unclear level design.

Polished art and audio are not optional extras; they are part of the entire game's quality standard.

## 9 — OWNER-ONLY SECRET UWU DEBUG MENU

Preserve the owner's additional requested feature.

Eventually refine the EXISTING SHH/F1 owner-test system so:
- The activation gesture is deliberately secret and harder to discover.
- It has a discreet successful-unlock audio cue.
- A small draggable floating box reads exactly **UWU**.
- Tapping opens existing cheats; dragging only moves the box.
- Owner saves and test profiles remain isolated.
- Debug functionality is excluded from normal/release builds.
- Exact recovery and activation instructions are documented for the owner.

Do not create duplicate cheat systems. This remains below critical foundation and main world-presentation tasks unless an immediate safe integration is possible.

## 10 — REALISTIC PRIORITY ORDER FOR THE NEXT CREDIT CYCLE

**P0 — Recovery and safety**

Resume any nearly finished interrupted 0.4.66 work and resolve critical save, crash or combat defects. Checkpoint safely.

**P1 — High-impact visible result**

Implement and visually review the new main menu atmosphere and responsive title experience.

**P2 — Connected Hub overhaul**

Correct NPC station ownership, environmental placement, interaction clarity and the Patch/Sera service experience. Choose a cohesive implementation slice rather than scattered button edits.

**P3 — Home and meaningful progression**

Implement the strongest achievable connected Home improvement and one tangible collect/earn/display loop. If these cannot meet the quality gate in this credit cycle, preserve tested preparation and make them the first exact tasks next cycle.

**P4 — Remaining foundation polish**

Continue actual unresolved high-rarity, affix, combat, text, audio and performance defects. Prioritise genuine findings over speculative blanket audits.

Do not let P4 indefinitely postpone the owner's explicitly requested scene-quality improvements, unless a proven blocker requires attention.

**IMPORTANT:** The ordering is based on delivery dependencies, not permission to ship rushed work.

If capacity is limited, finish a smaller premium-quality connected slice and leave a reliable handoff. Do not scatter unfinished changes across every system.

## 11 — VALIDATION, QUALITY GATES & DELIVERY

At a stable boundary, perform an actual Godot/compiled-game acceptance pass.

Mandatory representative evidence:
- Main menu initially and after extended idle.
- Main menu with reduced motion.
- Actual Hub.
- Patch outside and inside his shop.
- Sera at her shrine and inside permanent upgrades.
- Home before/after.
- One earned progress/collection presentation if implemented.
- Representative combat HUD, perk and equipment comparison.

Review small phone, S23 portrait, tablet and desktop, including touch target alignment, screen framing, safe insets, clarity, effects layering and spacing.

For title ambience test:
- Decorative particle input isolation.
- Cosmetic RNG isolation.
- No visually jarring looping/reset.
- Muting/reduced-motion behaviour.
- Responsive aspect ratios.
- Reasonable particle and draw-call budgets.
- Foreground/background behaviour.

For gameplay regression test:
- Existing equipment, currencies and earned-only spinner.
- Saves, rollback and reward transactions.
- Hub/Home navigation.
- Shops and permanent upgrades.
- Combat and boss rewards.
- Owner/normal build separation.

Make at least one actual exported Windows game and a verified owner-test Android APK at the meaningful delivery checkpoint.

Do not claim Android runtime or S23 physical acceptance unless tested on that device.

Protect original and newer APKs, all rollback builds, owner modifications and approved source material.

Report clear evidence:
- Actual new features and fixes installed.
- What I will SEE, HEAR and DO differently in the next APK.
- Compiled test results.
- Before/after screenshots.
- Build paths and hashes.
- Which visual or audio assets require owner approval.
- What remains unimplemented.
- The precise next highest-priority production task.

Record separate statuses for implemented, functional, visually reviewed, audio reviewed, owner-approved and release-ready.

**Do not equate passing source tests with big-budget-quality acceptance.**

# FINAL OWNER VISION

Lootlings should deliver the craftsmanship, personality, polish, immersion and satisfying progression associated with high-budget games while retaining its original fantasy identity.

The player should enjoy simply sitting on the main menu.

They should immediately understand and enjoy exploring the Hub.

Their Home should feel personal, beautiful and meaningful.

NPCs should feel like actual characters living in the world.

Combat and rewards should feel responsive, weighty, clear and exciting.

Equipment and collecting should give them compelling things to chase.

Nothing should look obviously unfinished, randomly positioned, generic or disconnected.

**This applies from the beginning to the end of the ENTIRE game.**

Now recover the current project state, implement the strongest achievable connected production slice, visually verify it, ship a safe tested candidate and preserve a precise continuation handoff.

Do the work. Do not stop at another planning document.