# Weapons, Poses and Rendering Contract

Current source of truth for weapon IDs and motions remains `weapon_catalog.gd`.

## Core requirement

A weapon cannot merely float near a humanoid or Lootling. Each family needs a predictable grip/pose contract so the body, hands, projectile socket and VFX agree.

## Renderer architecture target

Do not immediately replace the stable renderer with a giant skeletal rewrite. Migrate in stages:

### Stage A — existing Lootlings
Keep current body sprite + held-weapon overlay. Add per-identity/per-family anchor overrides only where needed.

### Stage B — Wanderer beta
Use modular 2D pose composites:
- back arm
- body
- back accessory
- weapon
- front arm/hand
- foreground VFX

This lets hands visually wrap the weapon without requiring full frame-by-frame animation for every outfit.

### Stage C — authored attack pose sets
Per family, create 3–5 key poses: idle, windup, impact/release, recovery, victory/inspect optional. Tween between them where appropriate.

## Standard attachment data

Planned structure:

```gdscript
POSES[body_frame][weapon_family] = {
    "hand_primary": Vector2(...),
    "hand_secondary": Vector2(...),
    "weapon_origin": Vector2(...),
    "weapon_rotation": ...,
    "projectile_socket": Vector2(...),
    "front_arm_pose": "...",
    "back_arm_pose": "...",
    "body_offset": Vector2(...),
    "vfx_socket": Vector2(...)
}
```

Do not use one universal hand coordinate.

## All 12 family pose contracts

### Greatsword
Two-hand grip. Load back, diagonal cleave, strong recovery. Blade must clear head/hair/cape.

### Greataxe
Two-hand or high one-hand depending body. Overhead/diagonal chop. Long hair/capes need rear clearance.

### Maul
Two-hand compressed windup; low/heavy impact. Avoid face overlap on small bodies.

### Spear / Halberd
Two-hand brace; point forward/right; thrust/hook animation. Keep shaft readable across torso.

### Twin Daggers
One blade each hand; low agile stance; crossing slash. Daggers should not merge visually into forearms.

### Claws / Gauntlets
Weapon bound to hands. No floating grip. Arm pose carries silhouette; slash VFX extends outward.

### Bow
One grip hand + draw hand. Arrow socket at string/rest. Body turns slightly side-on.

### Crossbow
Two-hand support. Muzzle socket at front limb. Recoil small and mechanical.

### Relic Sling
One hand grip plus rotating pouch path. Projectile must begin at pouch release, not the character chest.

### Staff
One or two-hand cast posture. Staff may plant or sweep. Magic projectile/focus socket should sit near head or staff tip based on attack.

### Wand
One-hand point/flick. Off-hand free for spell pose or accessory.

### Orb / Focus
Orb may hover; hand does not need to physically grip it. Use orbit radius and release socket as the real visual contract.

## Lootling-specific pose flavour

Relic Beast: adaptable, slightly over-equipped.
Emberhorn: aggressive forward lean.
Mosskin: planted, defensive.
Moonkip: crouched/agile.
Pebblewyrm: compact/heavy.
Glimmerfin: theatrical casting.
Gloomlet: coiled/shadowy.

These are animation flavours, not stat passives.

## Humanoid stance variants

Each family should support at least:
- neutral
- confident
- aggressive
- elegant

Later, idle stance is player-selectable without changing damage timing.

## Weapon art production

Final target per family:
- 1024×1024 transparent held base
- stage 1 evolution
- stage 2 evolution
- inventory portrait if held sprite is unreadable in cards
- projectile where applicable
- impact VFX
- optional charged/glow layer

Existing IDs and evolution names from `weapon_catalog.gd` should drive filenames rather than inventing duplicate weapon registries.

## Collision / combat rule

Presentation sockets may change. Damage timing, hit rules and RNG do not change merely because art is repositioned. Visual release should be fitted to existing damage/projectile timing unless a deliberate combat change is separately approved.
