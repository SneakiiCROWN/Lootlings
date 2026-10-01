# WEAPONS, POSES, GRIPS & EQUIPMENT PRESENTATION

## Existing authoritative weapon families
Do not rename these IDs:
- greatsword
- greataxe
- maul
- spear
- daggers
- claws
- bow
- crossbow
- sling
- staff
- wand
- orb

Projectile profiles already exist for arrow, bolt, sling stone, magic orb, wand spark and focus shard. Keep the existing gameplay family contracts unless a dedicated balance task changes them.

## Presentation goal
A weapon must look owned by the actor, not pasted beside them.

Every actor render profile exposes:
- main_hand_socket
- off_hand_socket
- weapon_origin
- projectile_socket
- front_layer_anchor
- back_layer_anchor
- face_safe_zone
- feet_contact_y

Every weapon presentation profile supplies:
- grip mode
- pivot
- handedness
- idle angle
- anticipation angle/offset
- release angle/offset
- recovery angle/offset
- projectile launch point if ranged
- two-hand second-grip offset where relevant
- actor-scale bounds

## Pose families
### heavy_two_hand
greatsword / greataxe / maul
Read: planted, weighty, diagonal carry, strong windup.

### polearm_two_hand
spear
Read: rear-hand power + front-hand guide, point never crosses the face.

### dual_close
daggers / claws
Read: asymmetrical hands, low ready, cross-body release, no identical mirrored blades unless art calls for it.

### precision_ranged
bow / crossbow / sling
Read: launch side toward foe, projectile socket visibly clears the body.

### caster_long
staff
Read: staff can remain partly behind actor; spell launch is not automatically the staff tip if gameplay says otherwise.

### caster_short
wand
Read: wrist-forward, face clear, readable spark socket.

### focus_float
orb
Read: orb may hover around a hand/focus anchor, but damage timing still follows existing combat logic.

## Actor profiles
### lootling
Oversized gear, tiny body, strong silhouette. Existing named Lootlings keep their own proportions. Weapon overlay may exaggerate size but may not obscure face/Core.

### humanoid_light
Rogue / witch / ranger / tinker frames.

### humanoid_medium
General adventurer / priest / hunter / crystal gunner.

### humanoid_heavy
Blade warden / berserker / armoured guardian.

### humanoid_tall
Optional tall presentation frame. Cosmetic only; same combat hit rules unless future mechanics intentionally say otherwise.

## Runtime fitting rule
Actor art and weapon art remain independent layers.
Do not bake one weapon permanently into final humanoid production bodies.
If a beta board body already contains a weapon, use it only for portrait/selection art or mark it beta; combat-ready exports should be weaponless.

## Weapon-to-origin flavour, not class locks
Aurelia Voss: crossbow / sling / orb / wand
Kaien Rook: greatsword / spear / maul
Selene Veyra: staff / wand / bow / orb
Rex Calder: greatsword / claws / daggers / greataxe
Nessa Vale: bow / crossbow / spear
Corvin Ash: maul / greataxe / greatsword
Vesper Thread: wand / orb / daggers / staff
Juno Brass: crossbow / sling / orb / wand
Custom Wanderer: any unlocked weapon

These are recommendation/default flavours only. If the game lets an origin equip a family, the fitting system must make it look intentional.

## Equipment visuals
Gameplay slots remain:
Weapon
Armour
Charm
Rune

Appearance layers are separate:
weapon_skin
outfit
head
hair
shoulder
cape
gloves
boots
belt/satchel
jewellery
dye_a
dye_b
dye_c
aura
trail

Never make a sexy/cute/badass appearance alter power unless a named gameplay item explicitly does so.

## Validation
For every actor profile × weapon family that is enabled:
1. idle frame has no face/Core obstruction;
2. anticipation stays inside 480×854 safe bounds;
3. release points toward the current target;
4. ranged projectile originates at the socket, not the actor centre;
5. two-hand weapons visually meet both grips;
6. front/back layering does not cut through torso;
7. hurt/victory poses return weapon to a safe state;
8. mobile screenshot is inspected, not just headless-tested.
