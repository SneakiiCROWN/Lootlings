extends RefCounted

const Wanderers = preload("res://wanderer_catalog.gd")
const Actions = preload("res://action_pose_catalog.gd")
const Weapons = preload("res://weapon_catalog.gd")
const BODY_RECT := Rect2(-75, -146, 150, 225)
# Grip points are measured in the runtime weapon texture, not arbitrary sprite
# origins. Rects remain replaceable with authored arm/hand pose layers later.
const WEAPONS := {
	"greatsword":{"size":Vector2(112, 142), "grip":Vector2(0.5,0.88), "socket":Vector2(0.78,0.12), "angle":0.36},
	"greataxe":{"size":Vector2(112, 142), "grip":Vector2(0.5,0.88), "socket":Vector2(0.78,0.12), "angle":0.44},
	"maul":{"size":Vector2(116, 110), "grip":Vector2(0.13,0.91), "socket":Vector2(0.82,0.15), "angle":-0.12},
	"spear":{"size":Vector2(104, 162), "grip":Vector2(0.37,0.76), "socket":Vector2(0.8,0.08), "angle":0.35},
	"daggers":{"size":Vector2(92, 94), "grip":Vector2(0.27,0.68), "socket":Vector2(0.82,0.1), "angle":-0.2},
	"claws":{"size":Vector2(87, 72), "grip":Vector2(0.25,0.55), "socket":Vector2(0.9,0.3), "angle":0.0},
	"bow":{"size":Vector2(86, 114), "grip":Vector2(0.48,0.55), "socket":Vector2(0.68,0.46), "angle":-0.62},
	"crossbow":{"size":Vector2(115, 80), "grip":Vector2(0.24,0.71), "socket":Vector2(0.95,0.34), "angle":-0.1},
	"sling":{"size":Vector2(86, 114), "grip":Vector2(0.48,0.55), "socket":Vector2(0.68,0.46), "angle":-0.62},
	"staff":{"size":Vector2(80, 142), "grip":Vector2(0.27,0.8), "socket":Vector2(0.72,0.12), "angle":-0.12},
	"wand":{"size":Vector2(75, 93), "grip":Vector2(0.31,0.88), "socket":Vector2(0.75,0.14), "angle":0.16},
	"orb":{"size":Vector2(64, 64), "grip":Vector2(-0.22,0.78), "socket":Vector2(0.7,0.43), "angle":0.0}
}

static func sample(g, hurt: bool = false) -> Dictionary:
	var action := Actions.sample(g.current_weapon_family(), float(g.run_time), float(g.attack_clock), float(g.current_attack_interval()), float(g.attack_anim), hurt, float(g.player_reward_flash))
	var preset := Wanderers.definition(str(g.profile.get("wanderer", {}).get("preset_id", "vault_runner")))
	var body_rect: Rect2 = preset.get("body_rect", BODY_RECT)
	var local_hand: Vector2 = body_rect.position + Vector2(preset.grip) * body_rect.size
	var item: Dictionary = g.inventory.equipped_item("Weapon")
	var subtype: String = str(item.get("weapon_type", "maul"))
	var weapon: Dictionary = WEAPONS.get(subtype, WEAPONS.maul)
	var growth := 1.0 + clampi(int(item.get("evolution_stage", 0)), 0, 2) * 0.06
	var weapon_size: Vector2 = Vector2(weapon.size) * growth
	var rotation := float(weapon.angle) + float(action.release) * (0.42 if g.current_weapon_family() in ["VANGUARD", "ROGUE"] else -0.08) - float(action.anticipate) * 0.16
	var facing := float(g.player_facing)
	var body_scale: Vector2 = Vector2(action.scale) * Vector2(facing, 1)
	var root := Transform2D(float(action.rotation) * facing, body_scale, 0.0, Vector2(action.offset))
	var weapon_rect := Rect2(-Vector2(weapon.grip) * weapon_size, weapon_size)
	var projectile_local: Vector2 = weapon_rect.position + Vector2(weapon.socket) * weapon_size
	return {"action":action, "root":root, "body_rect":body_rect, "hand":local_hand, "weapon_rect":weapon_rect, "weapon_rotation":rotation, "projectile":root * (local_hand + projectile_local.rotated(rotation)), "core":body_rect.position + Vector2(preset.core) * body_rect.size}

static func projectile_origin(g) -> Vector2:
	# Match the drawn ranged root exactly; presentation never changes travel time.
	var idle_bob := sin(float(g.run_time) * 4.3) * 3.0
	var lunge := clampf(float(g.attack_anim) / 0.22, 0.0, 1.0) * (4.0 if g.attack_was_tap else 3.0)
	return Vector2(float(g.player_x) + lunge, 472.0 + idle_bob) + Vector2(sample(g).projectile)
