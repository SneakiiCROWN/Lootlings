extends Control
# A dedicated, release-owned combat action; never shares a purchase hit region.
var game
var attack: Button
var charge: Control
var weapon_icon: TextureRect
var weapon_texture: Texture2D
func configure(target) -> void:
	game=target; mouse_filter=Control.MOUSE_FILTER_IGNORE; z_index=50
	attack=game.make_action_button(self,"ATTACK",Vector2(80,724),Vector2(320,72),Color("#263d48"),Color("#e9c578"),func():
		if game.state=="playing": game.request_tap_attack())
	attack.name="AttackControl"; attack.add_theme_font_size_override("font_size",23)
	game.touch_ux.register_button(attack)
	weapon_icon=TextureRect.new(); weapon_icon.name="EquippedWeaponGlyph"
	weapon_icon.position=Vector2(14,14); weapon_icon.size=Vector2(44,44)
	weapon_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; weapon_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	weapon_icon.mouse_filter=Control.MOUSE_FILTER_IGNORE; attack.add_child(weapon_icon)
	charge=preload("res://combat_tap_meter.gd").new();charge.position=Vector2(102,786);charge.size=Vector2(276,4);charge.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(charge)
func _process(_delta: float) -> void:
	if game==null:return
	visible=game.state=="playing" and not game.presentation_director.vignette.active and not game.presentation_director.travel_active
	attack.disabled=not visible or is_instance_valid(game.touch_ux.dialog)
	charge.value=clampf(1-game.tap_input_cooldown/.11,0,1)
	if visible:
		var texture:=preload("res://lootlings_ui.gd").item_texture(game.inventory.equipped_item("Weapon"))
		if texture!=weapon_texture: weapon_texture=texture; weapon_icon.texture=texture
