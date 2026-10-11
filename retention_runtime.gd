extends RefCounted
const Catalog=preload("res://phase4b_catalog.gd")
const SpinCatalog=preload("res://relic_spin_catalog.gd")
var rift_pending := false
var rift_active := false
var game
var progress=preload("res://endgame_progress.gd").new()
var rng:=RandomNumberGenerator.new()
var siege:=false
var targeted:=false
var round_rule: Dictionary={}
var escrow:=0
var extracted:=false
var panel: Panel
var title: Label
var detail: RichTextLabel
var buttons: Array[Button]=[]
var spinner_button: Button
var mode_tab:="siege"
var mode_parent:="home"
var machine: Control
var spin_busy:=false
var spin_message:=""
var spin_kind:=""
var spin_tween: Tween
var selected_at:=0
var spin_reward: Dictionary={}
var spinner_from_modes:=false
var dimmer: ColorRect
var chase: Label
var chase_bar: Control
var pool_panel: Panel
var mode_art: TextureRect
var mythical_chase: Control
var spinner_from_home:=false
var mode_tabs: Array[Button]=[]
func configure(target) -> void:
	game=target; progress.load_progress(); progress.recover(game)
	# Combat runs are not resumable: refund an interrupted optional entry once.
	if not game.rift_progress.entry.is_empty():
		game.rift_progress.sigils=mini(999999,int(game.rift_progress.sigils)+2);game.rift_progress.entry=""
		game.save_hideout_economy()
	game.hideout_ui.endgame_progress=progress
	panel=game.make_panel(Rect2(28,150,424,625),Color("#101a32f5")); panel.visible=false; panel.z_index=80
	preload("res://lootlings_ui.gd").apply_material(panel,"hoard")
	title=game.make_label(panel,"RELIC SIEGE",25,Rect2(20,14,384,48),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	detail=preload("res://lootlings_ui.gd").rich_label(panel,Rect2(24,72,376,150),14,Color("#e7edff")); detail.scroll_active=true
	mode_art=TextureRect.new(); mode_art.position=Vector2(24,70); mode_art.size=Vector2(376,118); mode_art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; mode_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED; mode_art.mouse_filter=Control.MOUSE_FILTER_IGNORE; mode_art.visible=false; panel.add_child(mode_art)
	mythical_chase=preload("res://mythical_chase_view.gd").new(); mythical_chase.game=game; mythical_chase.position=Vector2(24,153); mythical_chase.size=Vector2(376,91); mythical_chase.visible=false; panel.add_child(mythical_chase)
	for tab in ["REGIONS","SIEGE","DUNGEONS"]:
		var b: Button=game.make_action_button(panel,tab,Vector2(24+mode_tabs.size()*128,64),Vector2(120,48),Color("#172442"),Color("#b8a476"),func():
			if tab=="REGIONS":panel.visible=false;game.show_hideout();game.hideout_ui.show_campaign()
			else:show_modes("siege" if tab=="SIEGE" else "dungeons"))
		b.add_theme_font_size_override("font_size",13);mode_tabs.append(b)
	for index in range(6):
		var b: Button=game.make_action_button(panel,"",Vector2(24,240+index*72),Vector2(376,60),Color("#172442"),Color("#78e4ff"),func(): choose(index))
		b.add_theme_font_size_override("font_size",14); b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.clip_text=true; buttons.append(b)
		game.touch_ux.register_button(b)
	machine=preload("res://relic_machine.gd").new(); machine.position=Vector2(54,126); machine.size=Vector2(316,208); machine.visible=false; panel.add_child(machine)
	machine.locked.connect(lock_spin); machine.completed.connect(finish_spin); machine.cue.connect(game.play_audio_event)
	dimmer=ColorRect.new(); dimmer.color=Color(0.01,.02,.05,.74); dimmer.position=Vector2.ZERO; dimmer.size=Vector2(480,854); dimmer.z_index=79; dimmer.mouse_filter=Control.MOUSE_FILTER_STOP; dimmer.visible=false; panel.get_parent().add_child(dimmer)
	# Control hit testing follows tree order, independently of visual z_index.
	# Keep the blocking world veil behind the machine controls for real mouse clicks.
	panel.get_parent().move_child(dimmer,panel.get_index())
	chase=game.make_label(panel,"",13,Rect2(24,92,376,38),HORIZONTAL_ALIGNMENT_CENTER,Color("#ff9baa")); chase.visible=false
	chase_bar=preload("res://relic_chase_meter.gd").new(); chase_bar.position=Vector2(24,132); chase_bar.size=Vector2(376,8); chase_bar.max_value=Catalog.RED_TARGET*SpinCatalog.SPARK_TARGET; panel.add_child(chase_bar); chase_bar.visible=false
	pool_panel=game.make_panel(Rect2(28,110,424,690),Color("#081226")); pool_panel.z_index=82; pool_panel.visible=false
	preload("res://lootlings_ui.gd").apply_material(pool_panel,"hoard")
	game.make_label(pool_panel,"THE REWARD POOL",22,Rect2(20,20,384,40),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	preload("res://lootlings_ui.gd").rich_label(pool_panel,Rect2(24,76,376,510),16,Color("#e7edff")).text=SpinCatalog.pool_text()
	for child in pool_panel.get_children():
		if child is RichTextLabel:child.scroll_active=true
	var close_pool: Button=game.make_action_button(pool_panel,"‹ RELIC ENGINE",Vector2(24,606),Vector2(376,54),Color("#172442"),Color("#78e4ff"),func(): pool_panel.visible=false)
	game.touch_ux.register_button(close_pool)
	var reveal_light:=preload("res://relic_reveal_fx.gd").new()
	reveal_light.machine=machine; reveal_light.panel=panel; reveal_light.card=detail
	reveal_light.size=Vector2(480,854); reveal_light.z_index=79; panel.get_parent().add_child(reveal_light)
	game.result_panel.size.y=625
	spinner_button=game.make_action_button(game.result_panel,"RELIC SPINNER",Vector2(47,557),Vector2(330,50),Color("#493052"),Color("#e2b563"),show_spinner)
	game.touch_ux.register_button(spinner_button)
	game.touch_ux.register_button(game.hideout_ui.dungeon_start_button)
	game.hideout_ui.dungeon_requested.disconnect(game.start_dungeon)
	game.hideout_ui.dungeon_requested.connect(show_modes)
	game.hideout_ui.engine_requested.connect(show_earned_spinner)
	game.hideout_ui.tracked_requested.connect(func(id): progress.track(id); game.hideout_ui.phase4_message=progress.target_text(); game.hideout_ui.refresh_phase4())
func open(state: String, heading: String, line: String, choices: Array) -> void:
	spin_busy=false; machine.visible=state=="relic_spinner"
	mode_art.visible=false; mythical_chase.visible=false
	dimmer.visible=state=="relic_spinner"; chase.visible=false; chase_bar.visible=false; pool_panel.visible=false
	panel.position=Vector2(28,150); panel.size=Vector2(424,625)
	title.position.y=14; detail.add_theme_font_size_override("normal_font_size",14); detail.add_theme_color_override("default_color",Color("#e7edff"))
	if panel.has_node("Wallet"): panel.get_node("Wallet").visible=false
	detail.position=Vector2(24,72); detail.size=Vector2(376,150)
	for index in range(buttons.size()): buttons[index].position=Vector2(24,240+index*72); buttons[index].size=Vector2(376,60)
	game.state=state; panel.visible=true; title.text=heading; detail.text=line; selected_at=Time.get_ticks_msec()
	game.hideout_ui.dismiss_dialogue();game.hideout_ui.visible=false;game.result_panel.visible=false
	for tab in mode_tabs:tab.visible=state=="mode_menu"
	game.pause_button.visible=false
	for index in range(buttons.size()):
		buttons[index].icon=null
		buttons[index].disabled=false; buttons[index].visible=index<choices.size(); buttons[index].text=str(choices[index]) if index<choices.size() else ""
	if state=="siege_service":
		for index in range(3):
			buttons[index].icon=preload("res://bible_runtime_art.gd").texture(["crystal_ward","fire_arc","healing_wreath"][index])
			buttons[index].expand_icon=true;buttons[index].add_theme_constant_override("icon_max_width",28)
func show_modes(tab: String="siege") -> void:
	if game.state=="hideout":mode_parent=game.hideout_ui.current_screen
	if game.state not in ["hideout","mode_menu"] or game.presentation_director.travel_active or game.presentation_director.vignette.active: return
	mode_tab=tab
	var context: String="Highest Siege round %d • best score %d" % [progress.data.highest,progress.data.best_score] if tab=="siege" else "Rootglass Vault farms Mossglass.\nRelic Route offers branching encounters."
	open("mode_menu","DUNGEONS" if tab=="dungeons" else "RELIC SIEGE","%s\nCrownroot fragments %d / %d\n%s\nOwned gear stays yours. Run enhancements expire.%s" % [context,progress.data.red_fragments,Catalog.RED_TARGET,progress.target_text(),"\nReward reserved: make room in Gear." if not progress.data.pending.is_empty() else ""],["RELIC SIEGE • endless survival","ROOTGLASS VAULT / TARGETED LOOT","RELIC ROUTE • choose your path","TRACK / FORGE GRAVEBLOOM STAFF","‹ REGIONS" if mode_parent=="campaign" else "‹ HUB","PRISM RIFT • 2 SIGILS"])
	buttons[1].disabled=not game.campaign.available("mossglass_wilds")
	buttons[2].disabled=not "act_i" in game.campaign.completed
	if buttons[1].disabled:buttons[1].text="ROOTGLASS VAULT • LOCKED"
	if buttons[2].disabled:buttons[2].text="RELIC ROUTE • LOCKED"
	buttons[3].text="FORGE GRAVEBLOOM STAFF" if progress.data.red_fragments>=Catalog.RED_TARGET else "TRACK GRAVEBLOOM | %d / 24 CROWNROOT" % progress.data.red_fragments
	buttons[5].visible=tab=="dungeons"
	buttons[5].disabled=not "act_i" in game.campaign.completed or int(game.rift_progress.sigils)<2
	buttons[5].text="PRISM RIFT • %d / 2 SIGILS" % int(game.rift_progress.sigils)
	if not "act_i" in game.campaign.completed:buttons[5].text="PRISM RIFT • CLEAR TREASURE RUINS"
	buttons[0].visible=tab=="siege"; buttons[1].visible=tab=="dungeons"; buttons[2].visible=tab=="dungeons"
	mode_art.visible=true; mode_art.texture=preload("res://beta_art_catalog.gd").FIRST_HOARD if tab=="siege" else preload("res://beta_art_catalog.gd").GROVE
	mode_art.position.y=126;mode_art.size.y=118
	detail.position=Vector2(24,258); detail.size=Vector2(376,84)
	for button in mode_tabs:
		game.hideout_ui.apply_display_button_style(button,Color("#b8a476"),button.text==("SIEGE" if tab=="siege" else "DUNGEONS"))
	var mode_line: String="Escalating survival • extract from round 10.\nPush past round 20 to chase Crownroot.\nBest: round %d • score %d" % [progress.data.highest,progress.data.best_score] if tab=="siege" else "Rootglass Vault: targeted Mossglass rewards.\nRelic Route: branching rooms and encounters.\nChoose your route; keep your owned gear."
	if tab=="dungeons" and buttons[1].disabled and buttons[2].disabled:mode_line="Rootglass Vault: targeted Mossglass rewards.\nRelic Route: branching rooms and encounters.\nClear Treasure Ruins to unlock both routes."
	detail.text="%s\nCrownroot fragments: %d / %d → Gravebloom Staff\nRun enhancements expire on return.\nRift Sigils: %d • earn one per clear (8+ foes)." % [mode_line,progress.data.red_fragments,Catalog.RED_TARGET,int(game.rift_progress.sigils)]
	mythical_chase.visible=tab=="dungeons";mythical_chase.refresh(game.rift_progress)
	if tab=="dungeons":
		detail.text="Rootglass: local loot. Relic Route: branching rooms.\nRift Sigils: %d | earn 1 per clear with 8+ foes.\nPrism Rift: costs 2; optional harder encounters.\nMythical: 1%% per elite clear; first 8 finds are unique." % int(game.rift_progress.sigils)
	else:
		detail.text+="\nPrism Rift and Mythical collection: see Dungeons."

	if not game.rift_progress.pending.is_empty():detail.text+="\nMythical reward saved: make room in Gear."
	if not progress.data.pending.is_empty(): detail.text+="\nReward saved: make room in Gear."
	var visible_index:=0
	for index in [0,1,2,5,3,4]:
		var button: Button=buttons[index]
		if button.visible:
			button.position=Vector2(24,354+visible_index*54); button.size.y=50; visible_index+=1
			var primary: bool=button==buttons[0] or (tab=="dungeons" and button==buttons[1])
			button.set_meta("ui_intent","primary" if primary else "secondary")
			preload("res://lootlings_ui.gd").apply_button(button,Color("#172442"),Color("#d4ad65"))
			button.add_theme_font_size_override("font_size",17 if primary else 13)

func choose(index: int) -> void:
	if Time.get_ticks_msec()-selected_at<180: return
	match game.state:
		"mode_menu":
			if index==4: close_modes(); return
			if index==5:
				if not "act_i" in game.campaign.completed or game.rift_progress.sigils<2:return
				game.touch_ux.request("Enter the Prism Rift?","Costs 2 Rift Sigils when combat begins. Eight harder branching rooms. Clear with at least eight foes defeated: +250 Lootcoins, +20 Diamonds, +1 Sigil, plus guardian loot. Mythical Shiny: 1% per clear; guaranteed by clear 24 since the last find. Eight unique finds before repeats. Defeat gives no bonus. Regular dungeons remain free.",func():
					panel.visible=false;game.state="hideout";siege=false;targeted=false;rift_pending=true;game.expedition_tier=0;game.campaign_id="act_i"
					game.dungeon.setup(int(Time.get_ticks_msec()),"act_i")
					for layer in game.dungeon.map:
						for room in layer:
							room.wave=mini(20,int(room.wave)+4)
							if room.kind=="Combat":room.kind="Risk";room.title="RIFT PATROL"
					game.request_start_run())
				return
			rift_pending=false
			if index==3:
				progress.track("gravebloom_staff")
				if progress.forge_red():
					spin_reward=progress.data.pending.back().duplicate(true); spin_message=progress.recover(game)
					game.state="result"; show_spinner(); spinner_from_modes=true; buttons[1].text="‹ MODES"; start_reveal(false); return
				game.state="hideout"; show_modes(mode_tab); return
			panel.visible=false; game.state="hideout"
			if index==0:
				siege=true; targeted=false; game.dungeon.active=false; game.expedition_tier=0; game.campaign_id="act_i"; game.request_start_run()
			elif index==1:
				setup_targeted(int(Time.get_ticks_msec()))
				game.request_start_run()
			else: siege=false; targeted=false; game.start_dungeon()
		"siege_checkpoint":
			if index==0: extracted=true; panel.visible=false; game.end_run(true)
			else: panel.visible=false; next_round()
		"siege_service":
			if index<3:
				if (index==0 and game.multi_hits>=6) or (index==1 and game.life_steal>=.20) or (index==2 and game.player_hp>=game.player_max_hp):return
				var cost: int=[110,165,130][index]+mini(180,game.wave*4)
				if game.coins<cost: return
				game.coins-=cost; game.run_coins_spent+=cost
				match index:
					0: game.multi_hits=mini(6,game.multi_hits+1)
					1: game.life_steal=minf(.20,game.life_steal+.025); game.armor-=.015
					2: game.player_hp=minf(game.player_max_hp,game.player_hp+game.player_max_hp*.25)
				if index==0 and title.text=="THE QUIET MECHANISM" and game.wave>=9 and game.current_weapon_family()=="MAGE":
					game.expedition_progress.data.seen["secret:quiet_prism"]=true; game.expedition_progress.save(); escrow+=1;progress.earn_spin("secret")
			panel.visible=false; next_round()
		"relic_spinner":
			if spin_busy:
				if index==2 and machine.skip(): finish_spin()
				return
			if index==3: pool_panel.visible=true; return
			if index==4:
				if progress.forge_red():
					spin_reward=progress.data.pending.back().duplicate(true); spin_message=progress.recover(game); start_reveal(false)
				return
			if index==0:
				if not can_spin():return
				var prior: int=int(progress.data.spins)
				var free_before: int=int(progress.data.get("free_spins",0))
				var using_free: bool=free_before>0
				var actor: String=game.CharacterTraits.actor_id(game.profile)
				var family: String=str(game.inventory.equipped_item("Weapon").get("weapon_type","greatsword"))
				spin_message=progress.free_spin(rng,actor,family) if using_free else progress.spin(rng,actor,family)
				if int(progress.data.spins)==prior and int(progress.data.get("free_spins",0))==free_before: show_spinner(spin_message); return
				spin_reward=progress.data.pending.back().duplicate(true)
				if spin_reward.kind=="blueprint" and preload("res://phase4_catalog.gd").FARMS[progress.data.region].items.all(func(id): return int(game.expedition_progress.data.fragments.get(id,0))>=3):
					spin_reward.display_name=preload("res://phase4_catalog.gd").FARMS[progress.data.region].material; spin_reward.display_amount=2; spin_reward.converted=true
				spin_message=("No currency charged.\n" if using_free else "")+progress.recover(game)+"\n"+("+1 Crownroot fragment!" if progress.data.spin_sparks==0 else "+1 Crownroot spark.")
				panel.get_node("Wallet").text=wallet_text()
				start_reveal(prior>0 or machine.stage=="settled")
			else: close_spinner()

func start_reveal(quick: bool) -> void:
	game.touch_ux.renew_surface()
	spin_kind=str(spin_reward.get("kind","material"))
	var rarity: String=str(spin_reward.get("rarity",spin_reward.get("item",{}).get("rarity","COMMON")))
	spin_busy=true; selected_at=Time.get_ticks_msec(); buttons[0].disabled=true; buttons[1].disabled=true; buttons[3].disabled=true; buttons[4].disabled=true
	buttons[2].visible=true; buttons[2].disabled=false; buttons[2].text="REVEAL NOW"
	buttons[2].position=Vector2(24,606); buttons[2].size=Vector2(376,50); buttons[1].visible=false; buttons[3].visible=false; buttons[4].visible=false
	update_chase(); detail.text="The seals are turning…\nReward reserved. Nothing is lost if you leave."; detail.add_theme_color_override("default_color",Color("#e7edff"))
	detail.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	machine.reduced_motion=game.audio_settings.get("cinematic_reduced_motion",false)
	machine.reward_texture=preload("res://lootlings_ui.gd").raw_item_texture(spin_reward.get("item",{})) if spin_kind=="item" else null
	machine.wind_up(spin_kind,rarity,quick)
	if SpinCatalog.tier(rarity)>=3 and game.audio_manager!=null: game.audio_manager.duck_music()

func lock_spin() -> void:
	if game.state!="relic_spinner": return
	var rarity: String=machine.rarity
	var name: String=SpinCatalog.reward_name(spin_reward,progress.data.region)
	var amount: int=int(spin_reward.get("display_amount",spin_reward.get("amount",1)))
	detail.add_theme_color_override("default_color",SpinCatalog.color(rarity))
	detail.add_theme_stylebox_override("normal",SpinCatalog.flat_style(SpinCatalog.color(rarity).darkened(.88),SpinCatalog.color(rarity).darkened(.25),10))
	detail.text="[center][b]%s\n%s%s[/b]\n%s[/center]" % ["YOU WON! • GRAVEBLOOM RELIC" if rarity=="RED" else "YOU WON! • "+rarity,name," × %d" % amount if spin_kind!="item" else "",spin_message]

func finish_spin() -> void:
	if not spin_busy: return
	spin_busy=false
	game.touch_ux.renew_surface()
	if spin_tween!=null and spin_tween.is_valid(): spin_tween.kill()
	if machine.stage!="settled": machine.reveal(spin_kind)
	if game.state=="relic_spinner":
		buttons[2].visible=false; buttons[1].visible=true; buttons[1].disabled=false; buttons[3].visible=true; buttons[3].disabled=false
		buttons[0].disabled=not can_spin()
		buttons[0].text=spin_text(true)
		# Keep the revealed card unobstructed. Forge remains in Modes and on
		# reopening this engine, with a dedicated row before the next spin.
		buttons[4].visible=false; detail.size.y=130
		selected_at=Time.get_ticks_msec()

func close_spinner() -> void:
	if pool_panel.visible: pool_panel.visible=false; return
	# Leaving never cancels the already committed reward. Return to its real origin.
	if spin_busy:
		if machine.stage in ["rolling","anticipation"]:machine.skip()
		finish_spin()
	spin_busy=false; machine.stop(); panel.visible=false; dimmer.visible=false
	if spinner_from_home:
		spinner_from_home=false;game.show_hideout()
	elif spinner_from_modes:
		spinner_from_modes=false; game.state="hideout"; show_modes(mode_tab)
	else: game.state="result";game.result_panel.visible=true

func update_chase() -> void:
	chase.visible=true; chase_bar.visible=true
	chase.text="GRAVEBLOOM • %d / 24 Crownroot fragments\nSPARKS %d / 12 • each earned spin advances" % [progress.data.red_fragments,progress.data.spin_sparks]
	chase_bar.value=mini(Catalog.RED_TARGET,progress.data.red_fragments)*SpinCatalog.SPARK_TARGET+progress.data.spin_sparks

func begin() -> void:
	progress.begin(game.campaign_id); escrow=0; extracted=false; panel.visible=false; dimmer.visible=false; spinner_from_modes=false; spin_reward.clear()
	if siege:
		rng.seed=hash("siege:%d" % game.rng.seed); round_rule=Catalog.round_rule(1,rng); game.coins=0; game.grouped_patrols=false
func elite_id() -> String:
	if not siege or not round_rule.elite or game.wave_kills>0: return ""
	var pool:= ["hasty","overcharged","leeching","rootbound","enraged","gilded"]
	return pool[rng.randi_range(0,pool.size()-1)]
func next_round() -> void:
	game.wave+=1; game.wave_kills=0; game.wave_composition_wave=-1
	round_rule=Catalog.round_rule(game.wave,rng); game.state="playing"; game.item_review_due=true
	game.wave_banner_text="ROUND %d • %s" % [game.wave,"BOSS" if round_rule.boss else "ELITE PRESSURE" if round_rule.elite else "RELIC SIEGE"]
	game.wave_banner_timer=1.35
func killed() -> void:
	if game.wave_kills<int(round_rule.count): return
	progress.data.highest=maxi(progress.data.highest,game.wave)
	progress.data.best_score=maxi(progress.data.best_score,game.total_kills*10+game.wave*40); progress.save()
	if round_rule.boss:
		if game.wave>=20: escrow+=1+game.wave/20
		open("siege_checkpoint","ROUND %d SECURED?" % game.wave,"Boss defeated. Unsecured keepsake + %d Crownroot fragments.\nEXTRACT secures the bundle. CONTINUE raises elite pressure and reward harvest. Death loses this bundle, never owned gear.\nMastery and ordinary regional materials are already saved." % escrow,["EXTRACT • secure and end","CONTINUE • ten more rounds"])
	elif round_rule.event:
		var name: String=["PRISM ENGINE","BLOODFIRE SHRINE","THE QUIET MECHANISM"][rng.randi_range(0,2)]
		game.expedition_progress.record_event("siege_"+name.to_lower().replace(" ","_"),false)
		open("siege_service",name,"Siege Embers %d • one service, or keep moving.\nAll enhancements expire. No owned equipment is replaced.%s" % [game.coins,"\nIts glass roots stir near a drawn staff. Nine rounds have warmed the circuit." if name=="THE QUIET MECHANISM" else ""],["PRISM SPLIT • +1 hit • %d Embers" % (110+mini(180,game.wave*4)),"BLOODFIRE • +2.5%% leech / -1.5%% armour • %d" % (165+mini(180,game.wave*4)),"PATCH UP • restore 25%% HP • %d Embers" % (130+mini(180,game.wave*4)),"KEEP MOVING"])
	else: next_round()
	if game.state=="siege_service":
		detail.text+="\nCURRENT: %d hits / %.1f%% leech / %.1f%% armour\nHP %.0f / %.0f. Choose a boost or LEAVE." % [game.multi_hits,game.life_steal*100,game.armor*100,game.player_hp,game.player_max_hp]
		buttons[0].disabled=game.multi_hits>=6;buttons[1].disabled=game.life_steal>=.20;buttons[2].disabled=game.player_hp>=game.player_max_hp
		buttons[0].text="NEW BOOST / hits %d to %d / %d Embers" % [game.multi_hits,mini(6,game.multi_hits+1),110+mini(180,game.wave*4)]
		buttons[1].text="NEW BOOST / leech %.1f to %.1f%%\narmour %.1f to %.1f%% / %d Embers" % [game.life_steal*100,minf(.20,game.life_steal+.025)*100,game.armor*100,(game.armor-.015)*100,165+mini(180,game.wave*4)]
		buttons[2].text="HEAL / HP %.0f to %.0f / %d Embers" % [game.player_hp,minf(game.player_max_hp,game.player_hp+game.player_max_hp*.25),130+mini(180,game.wave*4)]
func finish(victory: bool) -> void:
	panel.visible=false
	if siege and extracted and victory and game.wave>=10:
		if game.wave>=20: progress.secure_red(escrow,rng)
		progress.queue_item("siege_receipt","EPIC" if game.wave>=20 else "RARE")
	elif targeted and victory:
		progress.data.dungeon_clears+=1; progress.secure_red(1,rng)
		game.expedition_progress.data.seen["dungeon:rootglass_vault"]=true; game.expedition_progress.save()
	var secured_names:=[]
	var red_drop: Dictionary={}
	for reward in progress.data.pending:
		if reward.get("kind","")=="item" and str(reward.receipt).contains(str(progress.data.session)):
			secured_names.append(reward.item.name); game.run_notable_items.append(reward.item.duplicate(true))
			if reward.item.get("rarity","")=="RED": red_drop=reward.duplicate(true)
	progress.settle(game.coins,game.total_kills)
	var delivery: String=progress.recover(game)
	if not secured_names.is_empty():
		game.result_summary.text=game.result_summary.text.replace("\nNone","\n"+", ".join(secured_names))
		game.result_summary.text+="\n\nKEEPSAKES\n"+", ".join(secured_names)+"\n"+delivery
	if victory and ((siege and game.wave>=20) or targeted): game.result_summary.text+="\nCrownroot fragments %d / %d" % [progress.data.red_fragments,Catalog.RED_TARGET]
	if victory and (not siege or extracted):progress.earn_spin("extraction")
	spinner_button.disabled=int(progress.data.get("free_spins",0))+int(progress.data.get("legacy_spins",0))==0
	spinner_button.text="FREE EARNED SPIN / NOW OR LATER" if int(progress.data.get("free_spins",0))>0 else "RELIC ENGINE"
	game.result_summary.text+="\n\nEARNED SPINS: %d stored. Spin now or later at the Hub.\nNo currency charged." % int(progress.data.get("free_spins",0))
	if not red_drop.is_empty(): call_deferred("present_red_drop",red_drop,delivery)
func present_red_drop(reward: Dictionary, delivery: String) -> void:
	if game.state!="result": return
	show_spinner(); spin_reward=reward; spin_message=delivery; start_reveal(false)
func show_spinner(message: String="") -> void:
	if game.state not in ["result","relic_spinner"]: return
	if spin_busy: return
	if game.state=="result": spinner_from_modes=false
	var spins: int=progress.data.spins
	open("relic_spinner","RELIC ENGINE","",["EARNED SPIN","‹ RESULTS","","POOL & ODDS","FORGE GRAVEBLOOM"])
	panel.position=Vector2(28,110); panel.size=Vector2(424,690); title.position.y=8
	var top_line: Label=game.make_label(panel,"",14,Rect2(24,70,376,32),HORIZONTAL_ALIGNMENT_CENTER,Color("#e7edff")) if not panel.has_node("Wallet") else panel.get_node("Wallet")
	top_line.name="Wallet";top_line.position.y=54;top_line.text=wallet_text();top_line.visible=true
	update_chase(); machine.position=Vector2(24,154); machine.size=Vector2(376,224)
	detail.position=Vector2(24,394); detail.size=Vector2(376,130); detail.add_theme_font_size_override("normal_font_size",16)
	detail.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	detail.text=message if not message.is_empty() else "[center]Useful spoils on every spin.\nEpic + Legendary bundles get a full reveal.\n12 sparks earn 1 Crownroot fragment.\n24 fragments forge the Gravebloom Staff.[/center]"
	buttons[0].position=Vector2(24,534); buttons[0].size=Vector2(376,58)
	buttons[1].position=Vector2(24,606); buttons[1].size=Vector2(178,50); buttons[1].text="‹ MODES" if spinner_from_modes else "‹ RESULTS"
	buttons[3].position=Vector2(214,606); buttons[3].size=Vector2(186,50)
	buttons[2].visible=false; buttons[4].visible=progress.data.red_fragments>=Catalog.RED_TARGET
	buttons[4].position=Vector2(24,476); buttons[4].size=Vector2(376,48); buttons[4].disabled=not progress.data.pending.is_empty()
	if buttons[4].visible: detail.size.y=76
	buttons[1].disabled=false
	buttons[0].disabled=not can_spin();buttons[0].text=spin_text(false)
	for index in [0,1,2,3,4]:
		buttons[index].set_meta("ui_intent","primary" if index in [0,4] else "secondary")
		preload("res://lootlings_ui.gd").apply_button(buttons[index],Color("#172442"),Color("#d4ad65"))
	top_line.text=wallet_text()
	buttons[1].text="‹ HUB" if spinner_from_home else "LATER / RESULTS" if not spinner_from_modes else "LATER / MODES"

func can_spin() -> bool:
	if not progress.data.pending.is_empty() or not progress.data.quarantined_rewards.is_empty():return false
	return int(progress.data.get("free_spins",0))+int(progress.data.get("legacy_spins",0))>0
func spin_text(_quick: bool) -> String:
	if not progress.data.pending.is_empty():return "REWARD DELIVERY PENDING"
	var count: int=int(progress.data.get("free_spins",0))+int(progress.data.get("legacy_spins",0))
	return "FREE SPIN / %d EARNED" % count if count>0 else "EARN SPINS ON EXPEDITIONS"
func wallet_text() -> String:
	var count: int=int(progress.data.get("free_spins",0))
	var legacy: int=int(progress.data.get("legacy_spins",0))
	return "%d EARNED / %d SAVED LEGACY SPINS" % [count,legacy] if legacy>0 else "%d EARNED %s / NO CURRENCY COST" % [count,"SPIN" if count==1 else "SPINS"]
func show_earned_spinner() -> void:
	if game.state!="hideout":return
	spinner_from_home=true;spinner_from_modes=false;game.state="result";show_spinner()
	spinner_from_home=true;buttons[1].text="‹ HUB";buttons[0].disabled=not can_spin()
	if not can_spin() and progress.data.pending.is_empty():
		detail.text="[center][b]Your earned spins are stored here.[/b]\nEarn them from bosses, elites, 30 kills, secrets or extraction.\nReturn to the Hub and enter the Gate. No currency is charged.[/center]"

func reset() -> void:
	spinner_from_home=false;spinner_from_modes=false
	if panel!=null: panel.visible=false
	if dimmer!=null: dimmer.visible=false
	if pool_panel!=null: pool_panel.visible=false
	if spin_tween!=null and spin_tween.is_valid(): spin_tween.kill()
	spin_busy=false
	game.touch_ux.renew_surface()
	if machine!=null: machine.stop()
	siege=false; targeted=false

func setup_targeted(seed_value: int) -> void:
	siege=false; targeted=true; game.expedition_tier=0; game.campaign_id="mossglass_wilds"; game.dungeon.setup(seed_value,"mossglass_wilds")
	for room in game.dungeon.map[2]: room.kind="Elite"; room.wave=8; room.title="ROOTGLASS SENTINEL"; room.desc="Region miniboss • blueprint and Rootglass."

func close_modes() -> void:
	var parent_screen:=mode_parent
	panel.visible=false;game.show_hideout()
	if parent_screen=="campaign":game.hideout_ui.show_campaign()
