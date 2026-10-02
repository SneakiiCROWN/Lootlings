> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# Dialogue, On-Screen Text and Story Style

## Tone

Lootlings should sound like a world with history, danger and idiots carrying treasure.

Mix:
- concise dark-fantasy worldbuilding;
- dry character humour;
- cute Lootling confidence;
- occasional grim implications;
- short, punchy reward text;
- no generic "Chosen One, save the universe" sludge.

## UI text hierarchy

### Combat
Keep tiny:
- TARGET
- BREAK
- BURN
- POISON
- CRIT
- EXECUTE
- WARD
- BOSS

### Loot
Use strong verbs:
- FOUND
- CLAIM
- EQUIP
- SALVAGE
- EVOLVE
- SOCKET
- REVEALED
- SIGNATURE

### Route choices
Format:
**ROOM NAME**
one-line consequence hint
one-line flavour

Example:
**LOCKED VAULT**
Treasure • Higher elite chance
"Somebody went to a lot of trouble to keep you out."

## Resident dialogue targets

Each named resident eventually needs:
- 10 first-visit/general lines
- 7 Lootling-specific reactions
- 6 humanoid-origin reactions
- 12 weapon-family reactions
- 10 region-progress reactions
- 8 rarity/chest reactions
- 6 defeat/return reactions
- 5 idle barks
- 3 rare lines

Do not load all at once; use tagged pools with cooldown/history.

## Example Patch lines
- "If it glows, hums and bites, put it on the left bench."
- "That is not a repair. That's a confession."
- "A bigger blade does solve some problems. Mostly spatial ones."
- "You brought me a cursed ring. Great. Put it with the other definitely-not-cursed things."
- "Crossbow's aligned. If the bolt comes out sideways, pretend we never met."

## Example Ilex lines
- "The Archive records victories, failures and whatever that noise was."
- "History survives because somebody bothers to label the box."
- "The Crown erased names. It was less successful at erasing grudges."
- "Your footnote has teeth."
- "I have documented the chest's behaviour as 'rude'."

## Example Sera lines
- "A Core remembers what it was asked to protect."
- "Power isn't the same thing as permission."
- "You may touch the relic. You may not lick the relic."
- "That glow is excitement. Or instability. We'll know shortly."
- "Come back as yourself. The Nullglass likes alternatives."

## Example Merrow lines
- "I sell necessities, luxuries and mistakes with excellent packaging."
- "Route's safe. Mostly. I charge extra for the word 'mostly'."
- "You didn't get this map from me. Especially if it's good."
- "A rescue debt is a debt I actually enjoy collecting."
- "No refunds after the chest starts growling."

## Player bark style

Lootlings already have canonical voice. Wanderer barks should be selectable by voice/personality pack:
- Dry
- Bold
- Scholarly
- Flirty
- Grim
- Cheerful

These are text/voice flavours only.

Example Flirty adult-bark style:
- "If the demon wanted my attention, it could've just asked."
- "That armour is doing a lot of work. So am I."
- "Treasure first. Bad decisions after."

Example Grim:
- "Open the door."
- "It bleeds. Good."
- "We finish what the Crown started."

Example Scholarly:
- "Technically ancient. Practically explosive."
- "I have several questions. The weapon answers all of them badly."

## Romance / adult banter

If romance is ever added, keep it opt-in and character-driven. Do not fake a romance system with random suggestive barks. Adult NPCs can flirt lightly in ordinary dialogue, but relationship state must be explicit before deeper lines are used.

## Boss title cards

Pattern:
REGION TITLE
BOSS NAME
short thematic subtitle

Examples:
CINDER CROWN
**FURNACE REGENT**
Warmth Demands Tribute

NULLGLASS EXPANSE
**THE UNCHOSEN**
Every Future Wants Your Name

FIRST HOARD
**THE HOLLOW CROWN**
All Promises Belong to Me

## Writing QA
- no line claims a mechanic that does not exist;
- no NPC references an uncompleted boss;
- no item lore implies unimplemented elemental damage;
- no text exceeds phone layout bounds;
- repeated barks respect history/cooldown;
- names match stable IDs/display names.
