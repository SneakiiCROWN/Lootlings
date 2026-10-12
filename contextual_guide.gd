extends Control
# Optional help never pauses or interrupts the game until deliberately opened.
const PATH := "user://lootlings_tutorials.cfg"
const TOPICS := {
	"welcome":["A way home", "Tap the glowing Gate to begin an expedition. Home is your personal den; the Hub is where you meet people and prepare. You can explore at your own pace."],
	"combat":["Your first strike", "Tap ATTACK or the arena for an extra strike. Auto-attacks continue between taps. Menus and the HUD never attack. In a group encounter, tap a foe to choose your target."],
	"health":["HP and Ward", "HP is your health; the amber trail shows recent damage. Ward absorbs incoming damage before HP. Armour reduces damage. Healing restores HP, while XP leads to a run upgrade."],
	"boss":["Read the warning", "The foe's attack cue fills before it strikes. Bosses have distinct attacks and recovery openings. Watch the named cue, choose upgrades that keep you alive, and strike during the opening."],
	"equipment":["Compare before you swap", "Read CURRENT versus INSPECTING, including gained and lost effects. Equip swaps gear, Keep stores the find, and Scrap converts it into crafting material. Make room in a full stash first. Leaving a find behind is allowed."],
	"shop":["Patch's shelves", "Lootcoins buy permanent gear and supplies at the Hub shop. Inspect a row, compare it, then confirm its price. Buying and equipping are separate decisions. The Pack Peddler during a run offers a free supply choice and one redraw."],
	"currencies":["Three treasures, three purposes", "Lootcoins pay for gear and everyday permanent improvements. Rarer Loot Diamonds buy capped Shrine Prisms. Earned Rift Sigils open optional elite Prism Rifts; ordinary dungeons remain free. Scrap is crafting material, not another coin wallet."],
	"upgrades":["Power that stays", "Shrine improvements persist between expeditions. Read the cost, benefit and rank cap before buying. Run-level perks last for this expedition; they are a different choice. No purchase is required to continue."],
	"forge":["Keep the good parts", "The Forge uses existing gear and Scrap for upgrades or recipes. Select a recipe or item and read its requirements and outcome before confirming. A higher rarity alone does not tell you how a weapon fits your build."],
	"home":["Your own little den", "Use the actual stash, preparation area and displays. Decor changes use Apply or Cancel. Companions can follow you or stay Home; they are cosmetic and never change combat stats."],
	"archive":["Stories worth keeping", "The Archive holds memories, trophies and discoveries. Story replays can be skipped and never grant duplicate rewards. Character choices keep their established traits and identities."],
	"dungeons":["Choose your expedition", "Read the destination, difficulty and reward pool before entering. Ordinary dungeons are free. Targeted routes help you pursue a particular family of loot; they do not guarantee every rare item."],
	"rift":["An optional harder path", "Elite Prism Rift entry costs 2 earned Sigils. A qualified victory grants the disclosed Lootcoins, Diamonds and a Sigil. Mythical Shiny discoveries are rare earned rewards with guaranteed progress; entry is not a purchase of Mythical gear."],
	"siege":["Hold the line", "Siege is a separate repeatable mode. Read checkpoint choices and its mode rewards. Secured progression and the current run's choices are distinct. Return safely when your build needs a different plan."],
	"relic":["The Relic Engine", "Use earned spins, read the possible rewards, and let the reels reveal the recorded outcome. Skipping the animation never changes the prize or pays it twice. Crownroot progress and Gravebloom dungeon rewards are different systems."],
	"rewards":["Bring it home", "Inspect loot before choosing what to keep. Currency rewards are secured through the existing save receipts. Rarity colours are a clue; signatures and full equipment comparisons explain what an item actually does."],
	"return":["Another trip, wiser paws", "Defeat is a reason to adjust your build, not to lose your saved collection. Return to the Hub, inspect equipment and permanent upgrades, then try again. Abandoning an unfinished run can lose unsecured run rewards."],
	"comfort":["Make it yours", "Settings let you mix music, effects and ambience separately, reduce story motion, and customise combat numbers. Guides are optional: disable contextual suggestions below, or replay any topic here whenever you like."]
}
var game
var panel:Panel
var chip:Button
var picker:OptionButton
var body:RichTextLabel
var reading_state:Label
var toggle:CheckButton
var read_ids:Array=[]
var practised_ids:Array=[]
var enabled:=true
var context:="welcome"
var previous_pause:=false
var last_context:=""
var context_attack:=0
func configure(target) -> void:
	game=target;z_index=950;process_mode=Node.PROCESS_MODE_ALWAYS;mouse_filter=Control.MOUSE_FILTER_IGNORE
	var saved:=ConfigFile.new()
	if preload("res://safe_config.gd").load_config(saved,PATH,"guide")==OK:
		enabled=saved.get_value("guide","enabled",true)==true
		for key in ["read","practised"]:
			var values=saved.get_value("guide",key,[])
			if values is Array:
				for id in values:
					if id is String and TOPICS.has(id) and not id in (read_ids if key=="read" else practised_ids):(read_ids if key=="read" else practised_ids).append(id)
	chip=Button.new();chip.position=Vector2(350,802);chip.size=Vector2(114,44);chip.text="GUIDE";chip.tooltip_text="Optional contextual help";chip.add_theme_font_size_override("font_size",13);chip.pressed.connect(func():open(context));add_child(chip)
	preload("res://utility_presentation.gd").button(chip)
	panel=Panel.new();panel.size=Vector2(480,854);panel.mouse_filter=Control.MOUSE_FILTER_STOP;panel.visible=false;add_child(panel)
	preload("res://utility_presentation.gd").decorate(panel,"THE FIELD GUIDE","A little guidance, whenever you need it.","res://art/production/phase4e/items/recipe_scroll.png")
	picker=OptionButton.new();picker.position=Vector2(28,140);picker.size=Vector2(424,60);picker.add_theme_font_size_override("font_size",17);panel.add_child(picker)
	for id in TOPICS:picker.add_item(TOPICS[id][0]);picker.set_item_metadata(picker.item_count-1,id)
	picker.get_popup().max_size=Vector2i(424,480)
	picker.item_selected.connect(func(_i):refresh())
	preload("res://utility_presentation.gd").inset(panel,Rect2(28,212,424,304))
	body=RichTextLabel.new();body.position=Vector2(44,228);body.size=Vector2(392,242);body.add_theme_font_size_override("normal_font_size",19);body.add_theme_color_override("default_color",Color("#e6edf8"));body.scroll_active=true;panel.add_child(body)
	reading_state=Label.new();reading_state.position=Vector2(44,478);reading_state.size=Vector2(392,24);reading_state.add_theme_font_size_override("font_size",13);reading_state.add_theme_color_override("font_color",Color("#cbb684"));reading_state.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.add_child(reading_state)
	toggle=CheckButton.new();toggle.text="Suggest guides in the world";toggle.position=Vector2(28,532);toggle.size=Vector2(424,60);toggle.add_theme_font_size_override("font_size",17);toggle.button_pressed=enabled;panel.add_child(toggle)
	toggle.toggled.connect(func(value):var old:=enabled;enabled=value;if persist()!=OK:enabled=old;toggle.set_pressed_no_signal(old);body.text="Could not save this preference. Your previous setting is retained.")
	var done:=Button.new();done.text="GOT IT · RETURN";done.position=Vector2(28,626);done.size=Vector2(424,60);done.pressed.connect(acknowledge);panel.add_child(done)
	preload("res://utility_presentation.gd").button(done,true)
	var close_button:=Button.new();close_button.text="RETURN · READ LATER";close_button.position=Vector2(28,704);close_button.size=Vector2(424,60);close_button.add_theme_font_size_override("font_size",15);close_button.pressed.connect(close);panel.add_child(close_button)
	preload("res://utility_presentation.gd").button(close_button)
func persist() -> Error:
	var config:=ConfigFile.new();config.set_value("guide","version",1);config.set_value("guide","enabled",enabled);config.set_value("guide","read",read_ids);config.set_value("guide","practised",practised_ids)
	return preload("res://safe_config.gd").save_config(config,PATH)
func topic() -> String:
	if game.state=="playing":return "boss" if game.enemy_is_boss or game.enemy_is_miniboss else "health" if game.player_ward>0 or game.player_hp<game.player_max_hp*.5 else "combat"
	if game.state=="personal_home":return "home"
	if game.state=="hideout":return {"home":"welcome","shop":"shop","forge":"forge","stash":"equipment","upgrades":"upgrades","archive":"archive"}.get(game.hideout_ui.current_screen,"currencies")
	return {"merchant":"shop","item":"equipment","boss_reward":"rewards","upgrade":"upgrades","result":"return","relic_spinner":"relic","mode_menu":"dungeons","siege_service":"siege","siege_checkpoint":"siege"}.get(game.state,"comfort")
func _process(_delta:float) -> void:
	if game==null:return
	context=topic()
	if context!=last_context:last_context=context;context_attack=game.attack_sequence
	if context=="combat" and game.attack_sequence>context_attack and "combat" in read_ids and not "combat" in practised_ids:
		practised_ids.append("combat")
		if persist()!=OK:practised_ids.erase("combat")
	chip.visible=enabled and not context in read_ids and game.state in ["playing","personal_home"] or enabled and not context in read_ids and game.state=="hideout" and game.hideout_ui.current_screen=="home"
	if game.startup_ui.visible or (is_instance_valid(game.debug_panel) and game.debug_panel.visible) or game.touch_ux!=null and is_instance_valid(game.touch_ux.dialog):chip.visible=false
	if is_instance_valid(game.hideout_ui) and is_instance_valid(game.hideout_ui.speech_panel) and game.hideout_ui.speech_panel.is_visible_in_tree():chip.visible=false
	# A hidden suggestion must never be adopted by a disposable confirmation dialog.
	if not panel.visible and chip.visible:
		var target:Control=game.input_surface()
		if target==null:target=game
		if chip.get_parent()!=target:chip.reparent(target)
		# Hub footer already owns Home / Character / Main menu. Keep optional
		# help below the header, above the portal, without intercepting that dock.
		chip.position=Vector2(350,58) if game.state=="hideout" else Vector2(350,802)
	if panel.visible:chip.hide()
	if game.state=="playing" and chip.visible:game.help_label.size.x=320
	else:game.help_label.size.x=440
func open(id:String="") -> void:
	if panel.visible:return
	previous_pause=get_tree().paused;get_tree().paused=true;panel.show();chip.hide();game.touch_ux.renew_surface()
	for index in range(picker.item_count):
		if picker.get_item_metadata(index)==(context if id.is_empty() else id):picker.select(index)
	refresh()
func refresh() -> void:
	var id:String=picker.get_item_metadata(picker.selected)
	body.text=TOPICS[id][1]
	reading_state.text="Practised in game · replay anytime" if id in practised_ids else "Read before · replay anytime" if id in read_ids else "New topic · optional, no rewards required"
	body.scroll_to_line(0)
func acknowledge() -> void:
	var id:String=picker.get_item_metadata(picker.selected)
	if not id in read_ids:
		read_ids.append(id)
		if persist()!=OK:read_ids.erase(id);body.text="Could not save guide progress. Your game progress is unchanged. You can return with Back.";return
	close()
func close() -> void:
	if not panel.visible:return
	panel.hide();get_tree().paused=previous_pause;game.touch_ux.renew_surface()

func _exit_tree() -> void:
	if is_instance_valid(chip):chip.queue_free()

# Called only after an existing gameplay action has succeeded and saved.
func observe_success(id:String) -> void:
	if not enabled or not TOPICS.has(id) or not id in read_ids or id in practised_ids:return
	practised_ids.append(id)
	if persist()!=OK:practised_ids.erase(id)
