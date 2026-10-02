> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# Character Story Previews, Play Buttons and Vignettes

## Goal

Make character pages feel collectible and alive. A player should be able to tap a small PLAY button on a character profile, lore entry, boss page, NPC page or major relic page and watch a short, stylish, replayable vignette.

This should deepen attachment without turning the game into a cutscene-heavy experience.

## Recommended presentation style

Primary style: **layered illustrated motion-comic / living-painting vignettes**.

Use:
- painted background plates;
- separated foreground/midground/background layers;
- character cutouts or portrait crops;
- subtle camera pans/zooms;
- parallax;
- eye/blink/head movement where assets allow;
- hair/cloth/weapon idle motion;
- particles and environmental effects;
- silhouette animation;
- animated light/runes;
- short text cards or subtitles;
- strong music/SFX sting.

This gives a premium illustrated-RPG feel at a fraction of the cost of full frame-by-frame animation.

Secondary styles, used selectively:
- **Animated portrait loop** (2–5 sec) for profile pages;
- **Storyboard memory** (5–20 sec) for backstory fragments;
- **Shadow-puppet / silhouette sequence** for secrets, tragedies, myths and unreliable memories;
- **Relic-vision sequence** with abstract particles, glyphs and distorted imagery for deep lore;
- **Boss dossier reveal** with painted splash + movement + title + one action beat;
- **Comedic micro-vignette** for cute Lootlings or lighter NPCs.

Do not force every character into the same tone.

## Character profile PLAY button

Each major character profile may include:

- portrait
- name
- role/class
- short personality line
- tabs for Story / Traits / Relationships / Discoveries / Cosmetics
- small PLAY button

PLAY opens the unlocked vignette library for that character.

Example entries:
- First Meeting
- Origin
- Turning Point
- Signature Moment
- Relationship Scene
- Secret Memory
- Alternate Outfit Showcase
- Victory Pose
- Rare Idle / Comedy Beat

Locked memories should show spoiler-safe placeholders.

## Progressive backstory

Do not reveal a full biography immediately.

Suggested progression:
1. basic public profile;
2. first-meeting vignette;
3. one personal story unlock;
4. relationship/reaction scene;
5. region-linked memory;
6. hidden contradictory clue;
7. late-game truth or partial truth.

This gives players reasons to revisit the profile.

## Playable Wanderers

For player-created Wanderers, avoid pretending there is one fixed canon biography.

Instead provide:
- origin choice;
- background tags;
- optional voice/personality flavour;
- player-selected history snippets;
- unlockable memory templates that adapt text/visual framing to the chosen origin.

Examples:
- Exiled Hunter
- Relic Scholar
- Ashland Survivor
- Gearworks Runaway
- Shrine Keeper
- Mercenary
- Court Defector
- Unknown / Amnesiac

These should affect flavour, dialogue hooks and optional lore where safe, not secretly create huge balance advantages.

## Canonical Lootlings

Each canonical Lootling can have authored backstory vignettes because their identities are fixed.

Possible structure:
- discovery/origin;
- first bond with another crew member;
- fear/weakness;
- favourite object/place;
- encounter with a major region;
- secret memory;
- lore contradiction.

Cute characters can have funny or heartwarming scenes.
Darker characters can have eerie or tragic scenes.
Do not make every story sad.

## NPC profiles

Named residents and major shopkeepers should also support small replayable scenes.

Examples:
- Patch repairing something impossible;
- Ilex hiding a page before the player arrives;
- Sera hearing the reversed Relic motif;
- Merrow mapping a route that does not yet exist;
- Edda building an outfit while gossiping;
- Corvin reacting to an old Court symbol.

These can double as lore delivery.

## Boss / monster pages

Boss Archive pages may have a PLAY button for:
- entrance replay;
- defeat/remnant memory;
- pre-corruption glimpse;
- lore reconstruction;
- alternate discovered clue.

Avoid humanising every monster. Some should remain frightening or unknowable.

## Cosmetic showcase

Character/cosmetic pages can include a short PLAY/POSE button:
- idle;
- weapon stance;
- spin/turn;
- victory pose;
- spell cast;
- outfit flourish.

This is especially useful for adult humanoid cosmetics and should help the player evaluate how an outfit/weapon actually looks in motion.

## Duration guidance

- Profile idle loop: 2–5 sec
- Cosmetic pose: 3–6 sec
- Character intro: 5–12 sec
- Backstory vignette: 8–25 sec
- Secret memory: 5–20 sec
- Major lore reconstruction: 15–35 sec maximum unless a later premium story sequence justifies more

## Replay rules

- Viewed scenes unlock permanently in Archive/character profile.
- Replay never changes rewards or progression.
- First-time unlock may show a small unobtrusive notification.
- Auto-play is limited to major first-time story moments.
- Profile-page play buttons are always manual.
- Videos/scenes should preload lightly to avoid a long black screen.

## Art production pipeline

For each vignette, request/export:
1. background plate;
2. foreground overlay;
3. character body/cutout;
4. optional face/eye layer;
5. optional hair/cape layer;
6. prop/weapon layer;
7. VFX overlays;
8. title card;
9. optional symbol/glyph layer.

All files need stable IDs and source/provenance.

## Why this style is recommended

It can look premium while staying realistic for a small indie team.
The same art can serve:
- profiles;
- Archive;
- stage intros;
- boss reveals;
- lore memories;
- social media promo;
- loading art;
- event banners.

One strong illustration can therefore produce multiple in-game moments rather than being used once.

## Accessibility

- subtitles;
- skip;
- replay;
- reduced motion;
- no critical lore lost if motion is disabled;
- readable text at 480×854;
- no rapid flashing.

## Implementation order

1. Reusable vignette player.
2. Character profile PLAY button.
3. One canonical Lootling example.
4. One resident example.
5. One boss example.
6. Cosmetic pose preview.
7. Archive linkage.
8. Expand only after the system proves stable.
