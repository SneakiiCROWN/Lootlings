extends SceneTree
const Weapons = preload("res://weapon_catalog.gd")
const Items = preload("res://item_catalog.gd")
const Forge = preload("res://forge_system.gd")
var game
var native := false

func _initialize() -> void:
	if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0591/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

static func base_id(family: String) -> String:
	if Weapons.STARTERS.has(family): return str(Weapons.STARTERS[family].id)
	for item in Items.ITEMS:
		if str(item.get("weapon_type", "")) == family: return str(item.id)
	return ""

func prepare(family: String, stage: int, grouped: bool = false) -> void:
	game.inventory.reset_to_starter()
	var item := Items.create_affixed_item(base_id(family), "EPIC", 45, ["keen"])
	for step in range(stage): item = Forge.evolve(item)
	game.inventory.equip(item)
	game.campaign_id = "act_i"
	game.grouped_patrols = grouped
	game.start_run()
	game.set_process(false)
	if grouped:
		game.wave = 2
		game.wave_kills = 0
		game.spawn_enemy()
	game.player_x = game.target_player_x()
	game.enemy_hp = 10000
	game.enemy_max_hp = 10000
	game.enemy_hit_multiplier = 1
	game.enemy_variant_guarded = false
	game.player_hp = 40
	game.enemy_attack_clock = 2
	game.wave_banner_timer = 0
	game.inventory.equipped.Weapon.effects = {}

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for family in Weapons.live_ids():
		assert(not base_id(family).is_empty())
		assert(Weapons.evolution_text(family, 0).is_empty())
		for stage in [1, 2]:
			prepare(family, stage)
			var item: Dictionary = game.inventory.equipped_item("Weapon")
			assert(item.id == base_id(family) and item.rarity == "EPIC" and item.serial == 45)
			assert(item.affix_ids == ["keen"] and Forge.stage(item) == stage)
			assert(game.inventory.save("user://evolution_qa.cfg") == OK)
			var restored = preload("res://inventory_system.gd").new()
			restored.load("user://evolution_qa.cfg")
			assert(restored.equipped_item("Weapon") == item)
			var data: Dictionary = Weapons.EVOLUTION_TRAITS[family]
			game.attack_sequence = int(data.every)
			if data.get("low_hp", false): game.enemy_hp = 3000
			var hp: float = game.enemy_hp
			var rng_state: int = game.rng.state
			game.apply_weapon_evolution(family, game.enemy_serial, true)
			assert(game.rng.state == rng_state, "Evolution must not consume gameplay RNG")
			if data.has("damage"): assert(is_equal_approx(hp - game.enemy_hp, game.base_damage * float(data.damage[stage - 1])))
			if data.has("heal"): assert(is_equal_approx(game.player_hp, 40 + float(data.heal[stage - 1])))
			if data.has("slow"): assert(is_equal_approx(game.enemy_attack_clock, 2 + float(data.slow[stage - 1])))
			# Incorrect cadence / opening / target cannot apply a repeated hit.
			hp = game.enemy_hp
			game.attack_sequence += 1
			game.apply_weapon_evolution(family, game.enemy_serial, false)
			assert(game.enemy_hp == hp)
			if native and stage == 1 and family in ["greatsword", "daggers", "bow", "orb"]:
				game.show_hideout()
				game.gold = 1000
				game.inventory.scrap = 100
				game.refresh_hideout()
				game.hideout_ui.show_forge()
				assert(game.hideout_ui.forge_detail.text.contains(Weapons.evolution_text(family, 2)))
				await capture("evolution_forge_" + family)
	# Stage zero has no hidden evolution effect.
	prepare("greatsword", 0)
	game.attack_sequence = 4
	game.apply_weapon_evolution("greatsword", game.enemy_serial, true)
	assert(game.enemy_hp == 10000)
	# Explicit evolution splash reaches the other actor, without changing selection.
	prepare("bow", 2, true)
	var serial: int = game.enemy_serial
	var other_hp: float = game.enemy_encounter.actors[1].enemy_hp
	game.attack_sequence = 5
	game.apply_weapon_evolution("bow", serial, true)
	assert(game.enemy_encounter.selected == 0)
	assert(game.enemy_encounter.actors[1].enemy_hp < other_hp)
	if native: await capture("evolution_arc_duo")
	# Fatal primary hit cannot send its remaining melee hits into the next target.
	prepare("claws", 0, true)
	game.enemy_hp = 1
	other_hp = game.enemy_encounter.actors[1].enemy_hp
	game.multi_hits = 4
	game.resolve_player_attack(false)
	assert(game.total_kills == 1 and game.enemy_encounter.selected == 1)
	assert(game.enemy_hp == other_hp)
	# Defeat is terminal: DOT siphon and evolution cannot restore HP on Results.
	prepare("orb", 2)
	game.player_hp = 0
	game.enemy_poison_stacks = 3
	game.enemy_poison_time = 5
	game.plague_power = 1
	game.dot_tick_clock = 0
	game.attack_sequence = 4
	game.end_run(false)
	game.update_elemental_damage(0.5)
	game.apply_weapon_evolution("orb", game.enemy_serial, true)
	assert(game.player_hp == 0 and not game.run_won)
	print("EVOLUTION QA PASSED: 12 families / both stages, persistence and affix retention, triggers, RNG neutrality, stage-zero preservation, bounded splash and fatal-hit target binding")
	game.queue_free()
	await process_frame
	quit(0)

func capture(name: String) -> void:
	game.queue_redraw()
	for frame in range(30): await process_frame
	assert(root.get_texture().get_image().save_png("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0591/" + name + "_qa.png") == OK)
