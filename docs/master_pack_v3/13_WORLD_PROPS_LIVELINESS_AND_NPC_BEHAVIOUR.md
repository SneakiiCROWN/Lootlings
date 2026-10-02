> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# World Props, Liveliness and NPC Behaviour

## Goal

The Hideout, shops, regions and route rooms should feel inhabited rather than like painted menu backdrops.

## Prop classes

### Functional props
Interactable and system-linked:
- Forge/anvil
- Stash
- Archive desk
- Shrine
- merchant cart
- contract board
- route map
- chest
- locked vault door
- recovery fire
- boss remnant

### Reactive props
No major gameplay reward; respond to player:
- hanging bells
- lanterns
- books
- loose tools
- water pumps
- crystal clusters
- mushrooms
- training dummy
- suspicious barrels
- caged relic light
- music instrument
- pet bed

### Ambient props
Pure worldbuilding:
- laundry
- crates
- maps
- ropes
- pots
- half-finished repairs
- bedrolls
- ration shelves
- broken statues
- weapon racks
- region trophies
- faction banners
- wanted notices
- expedition boots
- courier bags
- memorial tokens

### Lore props
Used for hidden-story architecture:
- inscriptions
- repeated symbols
- unusual maker marks
- empty sockets
- altered portraits
- impossible maps
- chained books
- missing bells
- sealed doors
- broken crowns

## Hideout population states

NPCs should not stand permanently in one pose.

Use low-cost schedules/state swaps:
- idle work
- talking to another resident
- walking between 2–4 anchors
- inspecting object
- eating/drinking
- repairing
- reading
- sleeping/off-screen
- reacting to new boss trophy
- reacting to new high-rarity item

No need for complex life simulation. Deterministic weighted state changes are enough.

## NPC interaction tiers

### Static bark NPC
Background population. One tap = bark.

### Named resident
Dialogue pool + state reactions + role screen.

### Shop NPC
Dialogue + shop access + entry/exit lines + special stock/rank reactions.

### Route NPC
Temporary encounter. May offer choice, lore, shop or quest.

### Companion/ally
Only later if mechanics justify it. Do not fake combat companions through dialogue alone.

## Hub liveliness checklist

- 6–12 visible entities at phone scale maximum;
- 2–4 moving at once;
- ambient particles;
- one distant loop (smithing, lantern, water, gears);
- one foreground layer;
- one subtle parallax layer if performance permits;
- occasional resident-to-resident exchange;
- player-character reaction when passing certain anchors;
- region trophy/prop changes after major bosses;
- music variation after story milestones.

## Region liveliness

Each region should have:
- foreground environmental motion;
- one distant background motion;
- at least 2 destructible/reactive-looking objects even if cosmetic-only;
- enemy entrance motion;
- reward landing ground plane;
- weather/particle identity;
- ambient creature or non-hostile silhouette where suitable.

Examples:
Mossglass — drifting spores, tiny glass-wing insects, moving vines.
Moonfen — lantern bugs, ripples, distant silhouettes.
Frostbell — snow dust, bell sway, falling ice.
Gearworks — gears, drips, steam, electric flicker.
Cinder Crown — ash fall, heat shimmer, chain sway.
Starfall — page motes, hovering glyph scraps.
Nullglass — reflection flickers, delayed shadows.
Skyhook — banners, cloud movement, rope sway.
First Hoard — dust, coin slides, faint Core pulses.

## Shop identity

Every shop should look and sound different.

Patch / Forge:
- sparks
- hammer ticks
- tools
- hanging weapon silhouettes
- oily brass

Merrow / Peddler:
- moving cart
- dangling charms
- cloth canopy
- pack creature or wobbling baggage
- coin/rattle cues

Edda / Clothier:
- mirrors
- fabrics
- mannequin silhouettes
- dye bottles
- rotating accessory display

Archive:
- page flips
- sliding drawers
- catalog tags
- crystal desk light

Shrine:
- cloth/rune sway
- crystal resonance
- low particle drift

## Interaction feedback

Every tappable prop/NPC needs at least:
- hover/selection highlight where input supports it;
- tap squash/glow/pulse;
- short sound;
- optional tiny text label;
- no ambiguous dead buttons.

## Performance rule

Prefer sprite/tween/parallax state changes over dozens of physics bodies. Decorative movement should never threaten combat performance.
