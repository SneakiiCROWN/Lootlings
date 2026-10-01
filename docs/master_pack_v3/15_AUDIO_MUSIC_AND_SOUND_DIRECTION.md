# Audio, Music and Sound Direction

## Immediate objective

The current placeholder/legacy soundscape is not considered final. Replace it deliberately, not by randomly swapping files.

## Musical identity

Lootlings should blend:
- dark fantasy orchestra;
- heavy percussion;
- low strings / cellos;
- ritual drums;
- distorted texture/guitar only where it helps;
- crystal bells/chimes for Relic material;
- industrial percussion in Gearworks;
- choir/demonic texture in Cinder/First Hoard;
- intimate plucked/woodwind or soft strings in safe hub moments.

Avoid generic upbeat mobile-game loops.

## Master theme

A 4–6 note **Relic Motif** should recur across regions in different instrumentation.

Examples:
- Hideout: warm strings + hammered dulcimer/soft guitar + crystal chime.
- Mossglass: wood, hand percussion, glassy mallets.
- Moonfen: low pulse, bowed textures, distant bell.
- Frostbell: sparse choir, icy mallets, sub drone.
- Gearworks: metallic rhythm, low synth, mechanical percussion.
- Cinder Crown: taiko-style low drums, aggressive strings, distorted low brass/guitar texture.
- Starfall Archive: piano/celesta, strings, reverse-page texture.
- Nullglass: reversed motif, detuned ambience, granular shimmer.
- Skyhook: driving drums, soaring strings, wind texture.
- First Hoard: full orchestra/choir/percussion with the motif revealed clearly.

## Music states

Per major region:
- Explore/route
- Combat
- Elite/miniboss
- Boss
- Reward/victory sting
- Low-intensity transition

Do not require six separate full songs immediately. Use stems/layers:
- ambience
- rhythm
- harmony
- danger
- boss overlay

## Adaptive rules

- combat layer fades in, not hard cuts;
- boss intro ducks ambience then hits title sting;
- rare chest moment briefly ducks music;
- return to Hideout has decompression;
- low HP may add a pulse only if it does not become annoying;
- menu music should not restart from zero every screen transition.

## SFX families

### UI
- select
- confirm
- cancel
- tab
- rarity reveal
- currency
- error
- notification
- contract complete

### Combat
Per family:
- windup
- swing/cast
- projectile launch
- impact
- crit
- block/guard
- status application
- kill
- boss hit
- boss phase if applicable

### Loot
- chest land
- latch/anticipation
- open
- item eject
- rarity beam
- item settle
- claim
- salvage
- Forge strike
- evolution
- rune socket

### World
- forge hammer
- pages
- shrine hum
- market cloth/wood
- footsteps by surface
- water
- wind
- fire
- chains
- bells
- gears
- portal
- distant creatures

## Character audio

If voice acting is not funded:
- text barks + expressive nonverbal chirps/grunts are acceptable;
- Lootlings can use short tonal identity cues;
- adult humanoids can use effort sounds, laughs, short exclamations;
- never synthesize celebrity/imitation voices.

## Mix targets

Exact LUFS/master targets should be established during final audio pass, but relative priorities:
1. critical combat telegraph;
2. dialogue/voice;
3. loot/reward cue;
4. player weapon;
5. enemy weapon;
6. ambience;
7. music.

Avoid constant limiter pumping.

## Implementation structure

Suggested buses:
- Master
- Music
- SFX
- UI
- Voice
- Ambience

Preserve the existing anti-fatigue mix architecture if already live; replace content underneath it rather than destroying settings/save compatibility.

## Replacement strategy

1. Inventory every current audio file and runtime callsite.
2. Mark KEEP / REPLACE / MISSING.
3. Replace UI first.
4. Replace player/enemy combat cues.
5. Replace loot/chests.
6. Replace region ambience.
7. Replace/adapt music.
8. Run repetition-fatigue test for 20–30 minutes.

## Licensing rule

Every third-party sound/music asset must record:
- source URL;
- creator;
- license;
- commercial-use status;
- attribution requirement;
- modification permission;
- original filename;
- imported filename.

No "free download" file enters the shipping build without verified licensing.

## Production fallback

If high-quality licensed final tracks are unavailable, ship original procedural/commissioned placeholder stems that fit the motif and replace later. A coherent temporary soundtrack is better than mismatched random fantasy tracks.
