extends Control

var game
var info_label: RichTextLabel
var status_label: RichTextLabel
var reset_button: Button
var close_button: Button
var reset_armed := false
var reset_timer := 0.0
var refresh_timer := 0.0
var previous_tree_pause := false
var section_groups:Dictionary={}
var tabs:OptionButton
var amount:SpinBox
var item_picker:OptionButton
var item_search:LineEdit
var value_picker:OptionButton
var value_readout:Label
var god_button:Button
var value_slider:HSlider
var section_scroll:ScrollContainer
const VALUE_FIELDS={"sigils":["Rift Sigils (saved)",0.0,999999.0,1.0],"xp":["XP this level (run)",0.0,1000000.0,.1],"wave":["Wave (test jump)",1.0,15.0,1.0],"hp":["HP",0.0,1000000.0,.1],"max_hp":["Maximum HP",1.0,1000000.0,1.0],"damage":["Attack power",1.0,1000000.0,1.0],"crit":["Critical chance",0.0,1.0,.01],"armor":["Armour fraction",0.0,.72,.01],"ward":["Ward",0.0,1000000.0,1.0],"attack_interval":["Auto-attack seconds",.12,8.0,.01],"gold":["Lootcoins",0.0,999999999.0,1.0],"diamonds":["Loot Diamonds",0.0,999999.0,1.0],"scrap":["Scrap",0.0,999999999.0,1.0]}

static func allowed(debug_build: bool) -> bool:
	return debug_build and (OS.get_name()!="Android" or preload("res://owner_test_access.gd").enabled())

func configure(target) -> void:
	game = target
	name = "DevelopmentPanel"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 1000
	build_ui()
	visible = false

func build_ui() -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("#030714e8")
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var panel := Panel.new()
	panel.position = Vector2(12, 12)
	panel.size = Vector2(456, 830)
	var box := StyleBoxFlat.new()
	box.bg_color = Color("#11172afb")
	box.border_color = Color("#d4ad65")
	box.set_border_width_all(3)
	box.set_corner_radius_all(14)
	panel.add_theme_stylebox_override("panel", box)
	add_child(panel)
	var title := make_label("SSSHHH! · OWNER PLAYGROUND", 19, Color("#ffe3ac"))
	title.position = Vector2(16, 12)
	title.size = Vector2(360, 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font",preload("res://lootlings_typography.gd").heading())
	panel.add_child(title)
	close_button = Button.new()
	close_button.text = "×"
	close_button.position = Vector2(394, 8)
	close_button.size = Vector2(48, 48)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", 24)
	close_button.tooltip_text = "Close development panel (F1 / Escape)"
	close_button.pressed.connect(close)
	panel.add_child(close_button)
	info_label = bounded_readout("", 12, Color("#d9e5ff"))
	info_label.position = Vector2(20, 44)
	info_label.size = Vector2(416, 86)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(info_label)
	status_label = bounded_readout("Keep this between us. Test saves only; normal progress stays safe.", 12, Color("#ffe39a"))
	status_label.position = Vector2(20, 138)
	status_label.size = Vector2(416, 36)
	panel.add_child(status_label)
	var profile_button:=Button.new();profile_button.position=Vector2(20,182);profile_button.size=Vector2(416,50);profile_button.text="RETURN TO NORMAL PROFILE" if preload("res://save_scope.gd").active else "ENTER ISOLATED TEST PROFILE";profile_button.pressed.connect(func():preload("res://save_scope.gd").switch_profile(get_tree(),not preload("res://save_scope.gd").active));panel.add_child(profile_button)
	tabs=OptionButton.new();tabs.position=Vector2(20,240);tabs.size=Vector2(416,48)
	for title_value in ["RUN & COMBAT","GEAR & LOOT","PROGRESSION","DIAGNOSTICS"]:tabs.add_item(title_value)
	tabs.item_selected.connect(filter_sections);panel.add_child(tabs)
	var scroll := ScrollContainer.new()
	section_scroll=scroll
	scroll.position = Vector2(16, 296)
	scroll.size = Vector2(424, 392)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var list := VBoxContainer.new()
	list.custom_minimum_size = Vector2(406, 0)
	list.add_theme_constant_override("separation", 6)
	scroll.add_child(list)
	add_section(list, "RUN / ENCOUNTER", [
		["WAVE 1", "wave", 1], ["WAVE 5", "wave", 5], ["MINIBOSS", "wave", 8],
		["WAVE 10", "wave", 10], ["FINAL BOSS", "wave", 15], ["KILL FOE", "kill", null]
	])
	add_section(list, "SURVIVAL / RESULTS", [
		["GOD MODE", "god", null], ["FULL HP", "hp", "full"], ["1 HP", "hp", "one"],
		["VICTORY", "victory", null], ["DEFEAT", "defeat", null], ["HOARD CHEST", "hoard", null]
	])
	add_section(list, "RESOURCES  •  SAVE", [
		["+500 LOOTCOINS", "gold", 500], ["+100 SCRAP", "scrap", 100], ["+100 DIAMONDS", "shards", 100],
		["+1 EARNED SPIN", "earned_spin", 1], ["+LEVEL XP", "xp", null], ["", "noop", null]
	])
	add_section(list, "FORCED LOOT", [
		["COMMON", "drop", "COMMON"], ["RARE", "drop", "RARE"], ["EPIC", "drop", "EPIC"],
		["LEGENDARY", "drop", "LEGENDARY"]
	])
	add_section(list, "WEAPON PRESENTATION", [
		["VANGUARD", "weapon", "VANGUARD"], ["RANGER", "weapon", "RANGER"],
		["MAGE", "weapon", "MAGE"], ["ROGUE", "weapon", "ROGUE"]
	])
	add_section(list, "CORE IDENTITY", [
		["NEUTRAL", "core", "Neutral"], ["FIRE", "core", "Fire"], ["LIGHTNING", "core", "Lightning"],
		["POISON", "core", "Poison"], ["PHYSICAL", "core", "Physical"], ["+ UPGRADE", "upgrade", null]
	])
	add_section(list, "ENEMY VARIANTS", [
		["HASTY", "variant", "hasty"], ["ARMOURED", "variant", "armoured"], ["VOLATILE", "variant", "volatile"],
		["CURSED", "variant", "cursed"], ["GILDED", "variant", "gilded"], ["FROST", "variant", "frostbitten"],
		["CHARGED", "variant", "overcharged"], ["ROOTBOUND", "variant", "rootbound"], ["", "noop", null]
	])
	add_section(list, "SIGNATURE LOOT", [
		["CROOKED", "signature", "crooked_constellation"], ["FROSTBELL", "signature", "frostbell_chime"], ["LANTERN", "signature", "last_lantern"]
	])
	add_section(list, "TROPHY QA", [
		["UNLOCK DRAGON", "achievement", "hoard_dragon"], ["UNLOCK EPIC", "achievement", "first_epic"], ["RESET TROPHIES", "achievement", "reset"]
	])
	add_section(list,"PERK TESTING",[["COMMON OFFERS","perk_offers","COMMON"],["RARE OFFERS","perk_offers","RARE"],["EPIC OFFERS","perk_offers","EPIC"],["POISON SYNERGY","synergy_poison",null]])
	add_section(list, "TEST SPEED", [
		["1×", "speed", 1.0], ["2×", "speed", 2.0], ["4×", "speed", 4.0]
	])
	add_section(list,"MYTHICAL SHINY",[])
	var myth_group:VBoxContainer=section_groups["MYTHICAL SHINY"].node
	for id in preload("res://mythical_collection.gd").IDS:myth_group.add_child(make_button(id.replace("_"," ").capitalize(),"item_id",id))
	add_section(list,"TEST PROGRESSION",[["+10 SIGILS","sigils",10],["+100 WARD","ward",100],["SAVE TEST","save_test",null],["RELOAD TEST","load_test",null],["MODES","modes",null],["SPINNER","spinner",null]])
	amount=SpinBox.new();amount.min_value=1;amount.max_value=10000;amount.value=500;amount.custom_minimum_size=Vector2(406,52);section_groups["TEST PROGRESSION"].node.add_child(amount)
	section_groups["TEST PROGRESSION"].node.add_child(make_button("ADD THIS MANY LOOTCOINS","gold_amount",null))
	section_groups["TEST PROGRESSION"].node.add_child(make_button("REMOVE THIS MANY LOOTCOINS","coins_remove",null))
	section_groups["TEST PROGRESSION"].node.add_child(make_button("ADD THIS MANY LOOT DIAMONDS","diamonds_add",null))
	section_groups["TEST PROGRESSION"].node.add_child(make_button("REMOVE THIS MANY LOOT DIAMONDS","diamonds_remove",null))
	section_groups["TEST PROGRESSION"].node.add_child(make_button("RESET TEST WALLET BALANCES","wallet_reset",null))
	value_picker=OptionButton.new();value_picker.custom_minimum_size=Vector2(406,52)
	for key in VALUE_FIELDS:value_picker.add_item(VALUE_FIELDS[key][0]);value_picker.set_item_metadata(value_picker.item_count-1,key)
	section_groups["TEST PROGRESSION"].node.add_child(value_picker)
	value_picker.item_selected.connect(func(_index):refresh_value_bounds())
	value_slider=HSlider.new();value_slider.custom_minimum_size=Vector2(406,48)
	section_groups["TEST PROGRESSION"].node.add_child(value_slider)
	value_slider.value_changed.connect(func(value):amount.value=value)
	amount.value_changed.connect(func(value):value_slider.set_value_no_signal(value))
	value_readout=make_label("",13,Color("#d9e5ff"));value_readout.custom_minimum_size=Vector2(406,54)
	value_readout.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	section_groups["TEST PROGRESSION"].node.add_child(value_readout)
	var exact_actions:=HBoxContainer.new();exact_actions.add_theme_constant_override("separation",8)
	section_groups["TEST PROGRESSION"].node.add_child(exact_actions)
	for operation in ["Set","Add","Remove"]:
		var action_button:=make_button(operation.to_upper(),"exact_value",operation.to_lower());action_button.custom_minimum_size=Vector2(128,52);exact_actions.add_child(action_button)
	refresh_value_bounds()
	add_section(list,"ITEM CATALOG",[]);item_picker=OptionButton.new();item_picker.custom_minimum_size=Vector2(406,52)
	item_search=LineEdit.new();item_search.placeholder_text="Search equipment by name or identity";item_search.custom_minimum_size=Vector2(406,52)
	section_groups["ITEM CATALOG"].node.add_child(item_search);item_search.text_changed.connect(filter_items)
	filter_items("")
	section_groups["ITEM CATALOG"].node.add_child(item_picker);section_groups["ITEM CATALOG"].node.add_child(make_button("GRANT SELECTED ITEM","catalog_item",null))
	reset_button = make_button("RESET LOOTLINGS TEST SAVES", "reset", null)
	reset_button.custom_minimum_size = Vector2(406, 52)
	section_groups["TEST PROGRESSION"].node.add_child(reset_button)
	section_groups["TEST SPEED"].node.add_child(make_button("RESET SHH POSITION","shh_reset",null))
	section_groups["TEST SPEED"].node.add_child(make_button("HIDE SHH SHORTCUT","shh_hide",null))
	section_groups["TEST SPEED"].node.add_child(make_button("RELOCK SHH","relock",null))
	filter_sections(0)

func filter_sections(index:int) -> void:
	tabs.select(index)
	for section in section_groups.values():section.node.visible=section.tab==index
	section_scroll.scroll_vertical=0
	section_scroll.set_deferred("scroll_vertical",0)
func add_section(parent: VBoxContainer, heading: String, actions: Array) -> void:
	var wrapper:=VBoxContainer.new();parent.add_child(wrapper);parent=wrapper
	var tab:int=1 if heading in ["FORCED LOOT","WEAPON PRESENTATION","SIGNATURE LOOT","MYTHICAL SHINY","ITEM CATALOG"] else 2 if heading in ["RESOURCES  \u2022  SAVE","TROPHY QA","TEST PROGRESSION"] else 3 if heading=="TEST SPEED" else 0
	section_groups[heading]={"node":wrapper,"tab":tab}
	var label := make_label(heading, 11, Color("#91a9d7"))
	label.custom_minimum_size = Vector2(406, 22)
	parent.add_child(label)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	parent.add_child(grid)
	for action in actions:
		if str(action[0]).is_empty():
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(130, 52)
			grid.add_child(spacer)
		else:
			grid.add_child(make_button(str(action[0]), str(action[1]), action[2]))

# Fixed readout bounds prevent long build summaries or command receipts from
# expanding into the next control. Overflow remains scrollable, not discarded.
func bounded_readout(value: String, font_size: int, color: Color) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.fit_content = false
	label.scroll_active = true
	label.add_theme_font_override("normal_font", preload("res://lootlings_typography.gd").body())
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", color)
	label.text = value
	return label

func make_label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_override("font",preload("res://lootlings_typography.gd").body())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func make_button(value: String, action: String, payload) -> Button:
	var button := Button.new()
	button.text = value
	if action=="god":god_button=button
	button.set_meta("debug_action",action);button.set_meta("debug_payload",payload)
	button.custom_minimum_size = Vector2(130, 52)
	button.add_theme_font_size_override("font_size", 13)
	button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(run_action.bind(action, payload))
	return button

func run_action(action: String, payload) -> void:
	if not preload("res://save_scope.gd").active:
		status_label.text="Enter the isolated test profile before using commands.";return
	if game == null:
		return
	if action == "reset":
		game.touch_ux.request("RESET ISOLATED TEST PROFILE?","Deletes only this test profile. Normal saves stay intact. No PIN is used.",func():game.debug_action("reset",null));return
	if action=="wallet_reset":
		game.touch_ux.request("RESET TEST WALLET?","Sets only isolated test Lootcoins and Loot Diamonds to zero. Equipment, upgrades, Sigils and normal saves remain intact.",func():status_label.text=game.debug_action("wallet_reset",null);refresh_info());return
	if action=="achievement" and payload=="reset":
		game.touch_ux.request("RESET TEST TROPHIES?","Clears only isolated test trophy progress. Normal saves remain intact.",func():status_label.text=game.debug_action("achievement","reset");refresh_info());return
	if action in ["gold_amount","coins_remove"]:payload=int(amount.value)*(1 if action=="gold_amount" else -1);action="gold"
	if action in ["diamonds_add","diamonds_remove"]:payload=int(amount.value)*(1 if action=="diamonds_add" else -1);action="shards"
	if action=="catalog_item":
		if item_picker.selected<0:status_label.text="No matching equipment. Change the search first.";return
		action="item_id";payload=item_picker.get_item_metadata(item_picker.selected)
	if action=="exact_value":
		payload={"field":value_picker.get_item_metadata(value_picker.selected),"operation":payload,"amount":amount.value}
	var message: String = game.debug_action(action, payload)
	status_label.text = message
	refresh_info()

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	if visible:
		return
	previous_tree_pause = get_tree().paused
	visible = true
	game.touch_ux.renew_surface()
	get_tree().paused = true
	refresh_info()
	if is_instance_valid(game.owner_test_access):game.owner_test_access.update_layout()

func close() -> void:
	if not visible:
		return
	visible = false
	game.touch_ux.renew_surface()
	get_tree().paused = previous_tree_pause
	# Reopening must be available immediately, not after the quarter-second scan.
	if is_instance_valid(game.owner_test_access):game.owner_test_access.update_layout()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event is InputEventKey:
		return
	if event.pressed and not event.echo and event.keycode in [KEY_F1, KEY_ESCAPE]:
		close()
		get_viewport().set_input_as_handled()

func refresh_info() -> void:
	if game == null or info_label == null:
		return
	info_label.text = ("ISOLATED TEST PROFILE\n" if preload("res://save_scope.gd").active else "NORMAL PROFILE - COMMANDS LOCKED\n")+game.debug_snapshot()
	if god_button!=null:god_button.text="GOD ON" if game.debug_god_mode else "GOD OFF"
	if value_readout!=null:
		var field:String=str(value_picker.get_item_metadata(value_picker.selected))
		var persistence:String="Saved test profile" if field in ["gold","diamonds","scrap","sigils"] else "Temporary · this run"
		value_readout.text="Current: %s · %s\nRange: %s–%s" % [str(game.debug_value(field)),persistence,str(amount.min_value),str(amount.max_value)]

func refresh_value_bounds() -> void:
	var key:String=value_picker.get_item_metadata(value_picker.selected)
	var field:Array=VALUE_FIELDS[key]
	amount.min_value=field[1];amount.max_value=minf(field[2],game.player_max_hp) if key=="hp" else maxf(0,game.xp_needed-.01) if key=="xp" else field[2];amount.step=field[3]
	value_slider.min_value=amount.min_value;value_slider.max_value=amount.max_value;value_slider.step=amount.step
	amount.value=game.debug_value(key)
	value_slider.set_value_no_signal(amount.value)
	refresh_info()

func filter_items(query:String) -> void:
	item_picker.clear()
	for item in game.ItemCatalog.ITEMS:
		if not query.is_empty() and not (str(item.name)+" "+str(item.id)).to_lower().contains(query.to_lower()):continue
		item_picker.add_item(str(item.name));item_picker.set_item_metadata(item_picker.item_count-1,item.id)

func _process(delta: float) -> void:
	if not visible:
		return
	refresh_timer -= delta
	if refresh_timer <= 0.0:
		refresh_timer = 0.25
		refresh_info()
	if reset_armed:
		reset_timer -= delta
		if reset_timer <= 0.0:
			reset_armed = false
			reset_button.text = "RESET LOOTLINGS TEST SAVES"
			status_label.text = "Reset confirmation expired."

func _exit_tree() -> void:
	if visible and get_tree() != null:
		get_tree().paused = previous_tree_pause
	# Reopening must be available immediately, not after the quarter-second scan.
	if is_instance_valid(game.owner_test_access):game.owner_test_access.update_layout()
