extends SceneTree
const Items=preload("res://item_catalog.gd")
const Weapons=preload("res://weapon_catalog.gd")
const Mythical=preload("res://mythical_collection.gd")
var game
var rows:Array=[]
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(250).timeout.connect(func():push_error("High rarity lab timeout");quit(1));call_deferred("review")
func prepare(weapon:String,rarity:String,shield:String,actor:String,sample:int,mode:String) -> void:
 game.inventory.reset_to_starter()
 game.inventory.equip(Items.create_affixed_item(weapon,rarity,66001,["keen","ruinous"]))
 game.inventory.equip(Items.create_affixed_item("mossguard_harness","LEGENDARY",66002,["warded"]))
 game.inventory.equip(Items.create_affixed_item("toxic_burst","RED",66003,["venomous"]))
 game.inventory.equip(Items.create_item(shield,"MYTHICAL SHINY" if shield in Mythical.IDS else "LEGENDARY",66004))
 game.meta_power=2;game.gold_upgrades={"bedroll":3,"whetstone":3,"heartprism":3,"mending":3,"wardweave":3}
 game.profile.avatar_mode="lootling" if preload("res://lootling_catalog.gd").ENTRIES.has(actor) else "wanderer"
 game.profile.current_lootling_id=actor;game.profile.wanderer.preset_id=actor
 game.debug_god_mode=false;game.grouped_patrols=false;game.retention.siege=mode=="Siege"
 game.campaign_id="first_hoard";game.dungeon.active=false;game.retention.rift_pending=false
 game.rift_progress=preload("res://rift_progress.gd").defaults()
 if mode in ["Dungeon","Prism Rift"]:
  game.dungeon.setup(66000+sample,"first_hoard")
  game.retention.rift_pending=mode=="Prism Rift";game.rift_progress.sigils=100
 game.rng.seed=66000+sample;game.loot_system.rng.seed=66100+sample;game.visual_rng.seed=66200+sample;seed(66300+sample)
 game.start_run();game.set_process(false)
 assert(game.inventory.save("user://high-rarity.cfg")==OK)
 var restored=preload("res://inventory_system.gd").new();restored.load("user://high-rarity.cfg")
 if not equivalent(restored.equipped,game.inventory.equipped):
  var f=FileAccess.open("res://.godot_test_data/high-rarity-mismatch.json",FileAccess.WRITE);f.store_string(JSON.stringify({"expected":game.inventory.equipped,"restored":restored.equipped},"  "));f.close()
  push_error("Named high-rarity save mismatch");quit(1);return
func equivalent(a:Variant,b:Variant) -> bool:
 if a is float or b is float:
  if not ((a is float or a is int) and (b is float or b is int)):return false
  return absf(float(a)-float(b))<.00000001
 if a is Dictionary:
  if not b is Dictionary or a.size()!=b.size():return false
  for key in a:
   if not b.has(key) or not equivalent(a[key],b[key]):return false
  return true
 if a is Array:
  if not b is Array or a.size()!=b.size():return false
  for i in range(a.size()):
   if not equivalent(a[i],b[i]):return false
  return true
 return a==b
func presets(kind:String) -> void:
 var picks:Array=["damage","damage","damage","damage","multi","multi","speed","speed"]
 if kind=="sustain":picks=["vamp","vamp","regen","regen","armor","armor","damage","multi"]
 if kind=="elemental":picks=["venom","venom","plague","plague","ignite","ignite","vamp","regen"]
 for id in picks:
  for upgrade in game.GameCatalog.UPGRADES:
   if upgrade.id==id:game.apply_upgrade_effect(upgrade);break
func fight(seconds:float) -> Dictionary:
 game.player_x=game.target_player_x();game.enemy_entry_anim=0;game.wave_banner_timer=0
 var initial:float=game.enemy_hp;var elapsed:=0.0;var taps:=0.0
 while game.state=="playing" and game.enemy_alive and elapsed<seconds:
  game._process(.05);elapsed+=.05;taps+=.05
  if taps>=.25:taps-=.25;game.request_tap_attack()
 assert(is_finite(game.player_hp) and is_finite(game.enemy_hp) and game.player_hp<=game.player_max_hp)
 return {"seconds":elapsed,"target":game.enemy_name,"initial_hp":initial,"hp_removed":initial-maxf(0,game.enemy_hp),"target_defeated":not game.enemy_alive,"state":game.state,"player_hp":game.player_hp,"damage_taken":game.run_damage_taken,"ward":game.player_ward,"crit":game.effective_crit_chance(),"interval":game.current_attack_interval(),"poison_stacks":game.enemy_poison_stacks}
func write_results() -> void:
 var f=FileAccess.open("res://.godot_test_data/high-rarity-066.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"rows":rows,"balance_accepted":false,"scope":"Named equipped gear, real damage and incoming attacks, saved gear roundtrip. Controlled final-boss pressure, not complete modes: no intervening rooms, perk draft, reward utility or route attrition. Fixed four taps/sec and eight prescribed perks; no human-competence claim."},"  "));f.close()
func review() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.set_process(false)
 var actors:Array=preload("res://lootling_catalog.gd").selectable_ids();actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
 for family in Weapons.live_ids():
  for rarity in ["LEGENDARY","RED"]:
   var weapon:String=Weapons.STARTERS[family].id if Weapons.STARTERS.has(family) else ""
   if weapon.is_empty():
    for item in Items.ITEMS:
     if item.get("weapon_type","")==family:weapon=item.id;break
   assert(not weapon.is_empty())
   prepare(weapon,rarity,"lucky_bell",actors[Weapons.live_ids().find(family)],0,"stationary")
   presets("offensive");game.enemy_hp=1000000;game.enemy_max_hp=1000000;game.enemy_attack_clock=100000;game.enemy_hit_multiplier=1;game.enemy_variant_guarded=false
   var row:=fight(12);row.family=family;row.rarity=rarity;row.item=weapon;row.actor=actors[Weapons.live_ids().find(family)];row.mode="stationary";row.actual_hp_removed_dps=row.hp_removed/row.seconds
   assert(row.hp_removed>0 and row.crit<=.85 and row.interval>=.16);rows.append(row)
 for id in Mythical.IDS:
  var item:Dictionary=Items.create_item(id,"MYTHICAL SHINY",66010)
  assert(preload("res://inventory_system.gd").sanitize_saved_item(item)==item and not item.signature_hooks.is_empty())
 for mode in ["Dungeon","Prism Rift","Siege"]:
  for sample in range(2):
   for set_index in range(2):
    var weapon:String=["dawnweave","prismsong"][set_index];var shield:String=["hearthpearl","bloomward"][set_index]
    for kind in ["offensive","sustain","elemental"]:
     prepare(weapon,"MYTHICAL SHINY",shield,["relic_beast","velvet_astrologer"][set_index],sample,mode);presets(kind)
     game.wave=30 if mode=="Siege" else 19 if mode=="Prism Rift" else 15
     if game.dungeon.active:game.dungeon.depth=7;game.dungeon.room=game.dungeon.map[7][0].duplicate(true);game.dungeon.room.wave=game.wave
     if mode=="Siege":game.retention.round_rule=game.retention.Catalog.round_rule(30,game.retention.rng)
     game.wave_kills=0
     if game.dungeon.active:game.enter_route_room()
     else:game.spawn_enemy()
     assert(game.state=="playing" and game.enemy_is_boss)
     var row:=fight(120);row.mode=mode;row.sample=sample;row.item=weapon;row.shield=shield;row.strategy=kind
     assert(row.seconds>0 and row.hp_removed>0)
     rows.append(row);write_results()
 assert(rows.size()==60)
 # The remaining named Mythical bow/spear and floating shields also fight.
 for pair in [["tidestar","mirrorwake"],["aurora_thread","starfold"]]:
  prepare(pair[0],"MYTHICAL SHINY",pair[1],"relic_beast",0,"stationary");presets("offensive");game.enemy_hp=1000000;game.enemy_max_hp=1000000;game.enemy_attack_clock=100000;game.enemy_hit_multiplier=1
  var row:=fight(12);row.mode="stationary";row.item=pair[0];row.shield=pair[1];row.actual_hp_removed_dps=row.hp_removed/row.seconds;assert(row.hp_removed>0);rows.append(row)
 write_results();game.free();print("HIGH RARITY 066 PASS: 26 real stationary damage samples, all 12 families/actors, Legendary/RED affixed named gear, all eight Mythicals; 36 matched controlled Dungeon/Rift/Siege boss pressure samples. Saves roundtrip; overall balance and complete mode acceptance remain open.");quit()
