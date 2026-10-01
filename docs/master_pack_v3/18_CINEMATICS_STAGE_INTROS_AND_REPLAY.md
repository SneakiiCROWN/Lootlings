# Cinematics, Stage Intros and Replay Archive

## Goal

Use short, high-impact, mostly one-time cinematic moments to hook players, establish each region/boss/character, and make progression feel authored without repeatedly interrupting play.

Cinematics must feel like part of Lootlings, not generic mobile-game popups.

## Core rules

- First-time presentation may be cinematic.
- Repeat visits must default to fast/no-interruption presentation.
- Every non-critical cinematic is skippable.
- Previously viewed cinematics are replayable from the Archive.
- Never replay a full intro automatically on every run.
- Prefer 5–20 second sequences for region/stage introductions.
- Major story/boss reveals may run 15–35 seconds when justified.
- Preserve player control as much as practical.
- Do not hide required gameplay information exclusively inside a cinematic.
- Text, subtitles and reduced-motion support are required.
- Use existing art and layered 2D motion first; reserve expensive full animation for moments that deserve it.

## Recommended cinematic types

### 1. First Arrival — Region Intro
Trigger: first time entering a region.

Length: about 8–15 seconds.

Structure:
1. short atmospheric establishing shot;
2. foreground prop/environment motion;
3. region name/title;
4. one memorable visual or NPC/enemy beat;
5. camera settles into playable framing;
6. control returns immediately.

Examples:
- Mossglass: drifting spores, giant glass leaves opening, a hidden eye vanishing behind foliage.
- Moonfen: lanterns ignite one by one while an incorrect-looking moon reflects in water.
- Frostbell: wind reveals a frozen bell tower; one bell position is visibly empty.
- Gearworks: machinery wakes sequentially; Patch-like maker mark flashes on an impossible old machine.
- Cinder Crown: chained doors pull apart while something enormous moves behind the furnace glow.
- Starfall: archive pages rise into orbit and briefly form a symbol before scattering.
- Nullglass: player silhouette appears in reflection a fraction before the real character arrives.
- Skyhook: camera sweeps past hanging bridges as an airship/creature silhouette crosses cloud cover.
- First Hoard: seven seals ignite; the camera lingers subtly on an unexplained eighth recess.

### 2. Boss Entrance
Trigger: first boss encounter; abbreviated version on repeats.

Length: 6–18 seconds.

Must:
- establish scale/personality;
- show the boss name/title;
- provide a readable gameplay handoff;
- never repeatedly waste the player's time.

Repeat version:
- 1–3 second sting/title, or fully disabled in Settings.

### 3. Character Introduction
Trigger: first meaningful meeting with a major NPC / playable identity.

Length: 4–12 seconds.

Use:
- pose;
- parallax;
- facial/portrait motion if available;
- environmental action;
- one line that immediately communicates personality.

Avoid biography dumps.

### 4. Loot / Relic Discovery
Trigger: first Signature/Legendary/major Relic discovery.

Length: 3–8 seconds.

Use physical chest/item motion, light, camera emphasis and a short stinger. Later copies use the normal fast reveal.

### 5. Story Echo / Memory
Trigger: optional lore discovery.

Length: 5–20 seconds.

Can use:
- silhouettes;
- animated paintings;
- camera pans across still art;
- text fragments;
- particles;
- altered colour;
- audio motif;
- intentionally incomplete imagery.

These are ideal for hidden lore because they are cheaper than full character animation and more mysterious.

## Production style — Layered 2D cinematics

Preferred first implementation for current Godot architecture:

- painted background;
- separated foreground/midground/background layers;
- character cutouts;
- prop cutouts;
- particles;
- controlled camera pan/zoom;
- light overlays;
- screen-space VFX;
- small skeletal/tween motions;
- optional mouth/eye/cloth/hair motion where assets permit;
- subtitle/dialogue track;
- music/SFX cue track.

This produces strong cinematic presentation without requiring hundreds of frame-by-frame animations.

## Cinematic data contract

Each cinematic should be data-driven, for example:

cinematic_id
trigger_type
trigger_id
first_time_only
repeat_variant_id
duration
skippable
archive_category
title
subtitle
music_cue
ambience_cue
camera_track
layers[]
actors[]
events[]
dialogue[]
lore_flags[]
completion_flag

Do not hard-code every scene into one giant UI script.

## Replay Archive

Add a section to the existing Archive / Field Notes ecosystem:

MEMORIES / CINEMATICS

Categories:
- Regions
- Characters
- Bosses
- Relics
- Story
- Echoes

Each unlocked cinematic can be replayed manually.

Locked entries may show:
- silhouette;
- ???;
- vague clue;
- region source;
depending on spoiler sensitivity.

Replay mode must never alter campaign state, loot, rewards, contracts or unlock flags.

## Skip / repeat settings

Settings options:
- First-time cinematics: ON/OFF
- Repeat boss stings: ON/OFF
- Auto-skip viewed cinematics: ON/OFF
- Reduced cinematic motion: ON/OFF
- Subtitles: ON/OFF
- Cinematic text speed where applicable

If a player skips a first-time cinematic, still mark it as discovered/unlocked for replay unless the cinematic itself contains an interactive choice.

## Hook philosophy

The opening hour needs memorable authored moments without becoming cutscene-heavy.

Recommended early cadence:
- opening game hook: 20–40 seconds maximum;
- first playable character reveal: 5–10 seconds;
- first Hideout reveal: 8–12 seconds;
- first expedition/region arrival: 8–15 seconds;
- first miniboss: 3–6 seconds;
- first major boss: 10–18 seconds;
- first Signature/Legendary: 3–8 seconds.

After that, cinematics become less frequent and more meaningful.

## Opening cinematic concept

Working concept, flexible until story finalises:

1. darkness; crystal/Relic pulse;
2. fragments of voices arguing about ownership, promises and "the Hoard";
3. seven symbols briefly illuminate;
4. a barely visible eighth recess remains dark;
5. rapid flashes of cute Lootlings, human Wanderers, terrible monsters, enormous treasure and broken worlds;
6. a hand/paw reaches for a Relic Core;
7. the Core reacts unexpectedly;
8. title: LOOTLINGS;
9. immediate handoff to player setup / first choice.

Do not explain the mystery. Hook first.

## Stage-intro presentation

Region intro titles should include:
- region name;
- very short descriptor;
- optional campaign chapter;
- distinct sound sting.

Example:
FROSTBELL
"The City That Forgot Its Warning"

Avoid repeating chapter cards every room.

## Boss title format

NAME
epithet / role

Examples should use live canonical boss IDs/names rather than inventing replacements during implementation.

Title cards should be sharp and brief, with visual identity derived from the boss/region.

## Hidden cinematic variants

Some cinematics may gain tiny differences after lore discoveries:
- extra symbol;
- changed reflection;
- alternate whisper;
- missing/added prop;
- NPC watching from background;
- new subtitle fragment.

These variations are excellent theory fuel but must not become required for basic story comprehension.

## Asset requirements per cinematic

Minimum:
- one usable background;
- optional foreground layer;
- actors/portraits/cutouts;
- 1–3 VFX overlays;
- title treatment;
- music cue;
- 2–6 SFX;
- subtitle/dialogue content.

Production versions can later add:
- skeletal animation;
- facial motion;
- cloth/hair motion;
- animated enemies;
- bespoke transitions.

## QA

For every cinematic:
- 480×854 safe framing;
- no cropped faces/text;
- skip works;
- replay works;
- completion flag persists;
- skip cannot duplicate rewards;
- replay cannot alter campaign state;
- subtitle timing is readable;
- audio ducking recovers;
- reduced-motion mode works;
- repeat encounter does not replay full first-time cinematic;
- no loading hitch at gameplay handoff.

## Implementation order

1. Build reusable cinematic player/data contract.
2. Add Archive replay support.
3. Prototype one Region Intro and one Boss Entrance with existing assets.
4. Validate skip/replay/save behaviour.
5. Expand region intros.
6. Expand major NPC introductions.
7. Add Echo/Memory scenes for lore.
8. Replace beta assets with final production art/animation progressively.

The cinematic system should be reusable and cheap enough that new stages can gain a memorable intro without writing bespoke engine code every time.
