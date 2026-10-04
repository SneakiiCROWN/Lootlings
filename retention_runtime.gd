extends RefCounted
const Catalog=preload("res://phase4b_catalog.gd")
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
var machine: Control
var spin_busy:=false
var spin_message:=""
var spin_kind:=""
var spin_tween: Tween
var selected_at:=0
func configure(target) -> void:
	game=target; progress.load_progress(); progress.recover(game)
	game.hideout_ui.endgame_progress=progress
	panel=game.make_panel(Rect2(28,150,424,625),Color("#101a32f5")); panel.visible=false; panel.z_index=80
	preload("res://lootlings_ui.gd").apply_material(panel,"hoard")
	title=game.make_label(panel,"RELIC SIEGE",25,Rect2(20,14,384,48),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	detail=preload("res://lootlings_ui.gd").rich_label(panel,Rect2(24,72,376,150),14,Color("#e7edff")); detail.scroll_active=true
	for index in range(5):
		var b: Button=game.make_action_button(panel,"",Vector2(24,240+index*72),Vector2(376,60),Color("#172442"),Color("#78e4ff"),func(): choose(index))
		b.add_theme_font_size_override("font_size",14); buttons.append(b)
		game.touch_ux.register_button(b)
	machine=preload("res://relic_machine.gd").new(); machine.position=Vector2(54,126); machine.size=Vector2(316,208); machine.visible=false; panel.add_child(machine)
	game.result_panel.size.y=625
	spinner_button=game.make_action_button(game.result_panel,"RELIC SPINNER",Vector2(47,557),Vector2(330,50),Color("#493052"),Color("#e2b563"),show_spinner)
	game.touch_ux.register_button(spinner_button)
	game.touch_ux.register_button(game.hideout_ui.dungeon_start_button)
	game.hideout_ui.dungeon_requested.disconnect(game.start_dungeon)
	game.hideout_ui.dungeon_requested.connect(show_modes)
	game.hideout_ui.tracked_requested.connect(func(id): progress.track(id); game.hideout_ui.phase4_message=progress.target_text(); game.hideout_ui.refresh_phase4())
func open(state: String, heading: String, line: String, choices: Array) -> void:
	spin_busy=false; machine.visible=state=="relic_spinner"
	if panel.has_node("Wallet"): panel.get_node("Wallet").visible=false
	detail.position=Vector2(24,72); detail.size=Vector2(376,150)
	for index in range(buttons.size()): buttons[index].position=Vector2(24,240+index*72)
	game.state=state; panel.visible=true; title.text=heading; detail.text=line; selected_at=Time.get_ticks_msec()
	game.pause_button.visible=false
	for index in range(buttons.size()):
		buttons[index].disabled=false; buttons[index].visible=index<choices.size(); buttons[index].text=str(choices[index]) if index<choices.size() else ""
func show_modes(tab: String="siege") -> void:
	if game.state!="hideout" or game.presentation_director.travel_active or game.presentation_director.vignette.active: return
	mode_tab=tab
	var context: String="Highest Siege round %d • best score %d" % [progress.data.highest,progress.data.best_score] if tab=="siege" else "Rootglass Vault farms Mossglass.\nRelic Route offers branching encounters."
	open("mode_menu","DUNGEONS" if tab=="dungeons" else "RELIC SIEGE","%s\nCrownroot fragments %d / %d\n%s\nOwned gear stays yours. Run enhancements expire.%s" % [context,progress.data.red_fragments,Catalog.RED_TARGET,progress.target_text(),"\nReward reserved: make room in Gear." if not progress.data.pending.is_empty() else ""],["RELIC SIEGE • endless survival","ROOTGLASS VAULT • Mossglass target dungeon","RELIC ROUTE • choose your path","TRACK / FORGE GRAVEBLOOM STAFF","‹ HIDEOUT"])
	buttons[1].disabled=not game.campaign.available("mossglass_wilds")
	buttons[2].disabled=not "act_i" in game.campaign.completed
	buttons[3].text="FORGE RED • 24 CROWNROOT FRAGMENTS" if progress.data.red_fragments>=Catalog.RED_TARGET else "TRACK GRAVEBLOOM • 24 FRAGMENTS TO FORGE"
	buttons[0].visible=tab=="siege"; buttons[1].visible=tab=="dungeons"; buttons[2].visible=tab=="dungeons"
	var visible_index:=0
	for button in buttons:
		if button.visible: button.position=Vector2(24,240+visible_index*84); visible_index+=1

func choose(index: int) -> void:
	if Time.get_ticks_msec()-selected_at<180: return
	match game.state:
		"mode_menu":
			if index==4: panel.visible=false; game.show_hideout(); return
			if index==3:
				progress.track("gravebloom_staff")
				if progress.forge_red(): progress.recover(game)
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
				var cost: int=[110,165,130][index]+mini(180,game.wave*4)
				if game.coins<cost: return
				game.coins-=cost; game.run_coins_spent+=cost
				match index:
					0: game.multi_hits=mini(6,game.multi_hits+1)
					1: game.life_steal=minf(.20,game.life_steal+.025); game.armor-=.015
					2: game.player_hp=minf(game.player_max_hp,game.player_hp+game.player_max_hp*.25)
				if index==0 and title.text=="THE QUIET MECHANISM" and game.wave>=9 and game.current_weapon_family()=="MAGE":
					game.expedition_progress.data.seen["secret:quiet_prism"]=true; game.expedition_progress.save(); escrow+=1
			panel.visible=false; next_round()
		"relic_spinner":
			if spin_busy:
				if index==2: finish_spin()
				return
			if index==0:
				var prior: int=int(progress.data.spins)
				spin_message=progress.spin(rng,game.CharacterTraits.actor_id(game.profile),str(game.inventory.equipped_item("Weapon").get("weapon_type","greatsword")))
				if int(progress.data.spins)==prior: show_spinner(spin_message); return
				spin_kind=str(progress.data.pending.back().get("kind","")) if not progress.data.pending.is_empty() else ""
				spin_message+="\n"+progress.recover(game); game.coins=int(progress.data.spin_wallet)
				spin_busy=true; buttons[0].disabled=true; buttons[1].disabled=true; buttons[2].visible=true; buttons[2].disabled=false; buttons[2].text="SKIP REVEAL"
				machine.wind_up(); detail.text="Winding up…"; game.play_audio_event("chest_windup")
				spin_tween=game.create_tween(); spin_tween.tween_interval(.85); spin_tween.tween_callback(finish_spin)
			else: panel.visible=false; machine.rolling=false; machine.set_process(false); game.state="result"

func finish_spin() -> void:
	if not spin_busy: return
	spin_busy=false
	if spin_tween!=null and spin_tween.is_valid(): spin_tween.kill()
	machine.reveal(spin_kind)
	if game.state=="relic_spinner": show_spinner(spin_message); game.play_audio_event("chest_open")

func begin() -> void:
	progress.begin(game.campaign_id); escrow=0; extracted=false; panel.visible=false
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
func finish(victory: bool) -> void:
	panel.visible=false
	if siege and extracted and victory and game.wave>=10:
		if game.wave>=20: progress.secure_red(escrow,rng)
		progress.queue_item("siege_receipt","EPIC" if game.wave>=20 else "RARE")
	elif targeted and victory:
		progress.data.dungeon_clears+=1; progress.secure_red(1,rng)
		game.expedition_progress.data.seen["dungeon:rootglass_vault"]=true; game.expedition_progress.save()
	var secured_names:=[]
	for reward in progress.data.pending:
		if reward.get("kind","")=="item" and str(reward.receipt).contains(str(progress.data.session)):
			secured_names.append(reward.item.name); game.run_notable_items.append(reward.item.duplicate(true))
	progress.settle(game.coins,game.total_kills)
	var delivery: String=progress.recover(game)
	if not secured_names.is_empty():
		game.result_summary.text=game.result_summary.text.replace("\nNone","\n"+", ".join(secured_names))
		game.result_summary.text+="\n\nKEEPSAKES\n"+", ".join(secured_names)+"\n"+delivery
	if victory and ((siege and game.wave>=20) or targeted): game.result_summary.text+="\nCrownroot fragments %d / %d" % [progress.data.red_fragments,Catalog.RED_TARGET]
	spinner_button.disabled=game.total_kills<10
func show_spinner(message: String="") -> void:
	if game.state not in ["result","relic_spinner"]: return
	var spins: int=progress.data.spins
	open("relic_spinner","RELIC ENGINE","%d %s  •  %d spins remaining" % [progress.data.spin_wallet,"Embers" if siege else "Scrip",3-spins],["SPIN • %s" % ("COMPLETE" if spins>=3 else str(Catalog.SPIN_COSTS[spins])),"‹ RESULTS"])
	var top_line: Label=game.make_label(panel,"",14,Rect2(24,70,376,32),HORIZONTAL_ALIGNMENT_CENTER,Color("#e7edff")) if not panel.has_node("Wallet") else panel.get_node("Wallet")
	top_line.name="Wallet"; top_line.text="%d %s  •  %d spins remaining" % [progress.data.spin_wallet,"Embers" if siege else "Scrip",3-spins]; top_line.visible=true
	detail.position=Vector2(24,349); detail.size=Vector2(376,116)
	detail.text=message if not message.is_empty() else "Turn leftover run currency into a local material, a recipe clue or mastery.\nNo boss seals or RED rewards."
	buttons[0].position=Vector2(24,480); buttons[1].position=Vector2(24,552); buttons[2].position=Vector2(24,552)
	buttons[0].disabled=spins>=3 or (spins<3 and progress.data.spin_wallet<Catalog.SPIN_COSTS[spins])
	buttons[1].disabled=false

func reset() -> void:
	if panel!=null: panel.visible=false
	if spin_tween!=null and spin_tween.is_valid(): spin_tween.kill()
	spin_busy=false
	if machine!=null: machine.rolling=false; machine.set_process(false)
	siege=false; targeted=false

func setup_targeted(seed_value: int) -> void:
	siege=false; targeted=true; game.expedition_tier=0; game.campaign_id="mossglass_wilds"; game.dungeon.setup(seed_value,"mossglass_wilds")
	for room in game.dungeon.map[2]: room.kind="Elite"; room.wave=8; room.title="ROOTGLASS SENTINEL"; room.desc="Region miniboss • blueprint and Rootglass."
