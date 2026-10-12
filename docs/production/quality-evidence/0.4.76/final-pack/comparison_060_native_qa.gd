extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0761/phase4b_native_qa.gd"
const Compare=preload("res://equipment_comparison.gd")
const Inv=preload("res://inventory_system.gd")
const Scope=preload("res://save_scope.gd")
func review() -> void:
 var cases:int=0
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0761/compare060/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false;game.start_run();game.set_process(false);game.presentation_director.finish_travel();game.presentation_director.vignette.finish()
  for id in ["dawnweave","tidestar","aurora_thread","prismsong","hearthpearl","mirrorwake","bloomward","starfold","ironpaw_plate","stormspark"]:
   var item:Dictionary=game.ItemCatalog.create_item(id,"MYTHICAL SHINY" if id in preload("res://mythical_collection.gd").IDS else "RED",600+cases)
   var before:String=JSON.stringify(game.inventory.equipped);var rng:int=game.rng.state;var hp:float=game.player_hp
   var text:String=game.build_item_comparison(item,game.inventory.equipped_item(item.slot))
   assert(text.contains("CURRENTLY EQUIPPED") and text.contains("INSPECTING") and text.contains("Auto-attack delay") and not text.contains("DPS"))
   for effect in item.effects:assert(text.contains(str(effect).replace("_"," ").capitalize()))
   assert(JSON.stringify(game.inventory.equipped)==before and game.rng.state==rng and game.player_hp==hp)
   var clone=Inv.new();clone.equipped=game.inventory.equipped.duplicate(true);var now:Dictionary=Compare.stats(game,clone)
   assert(is_equal_approx(now["Base strike power"],game.base_damage*game.equipment_damage_multiplier()) and is_equal_approx(now["Auto-attack delay"],game.current_attack_interval()) and is_equal_approx(now["Critical chance"],game.effective_crit_chance()*100))
   clone.equipped[item.slot]=item;var projected:Dictionary=Compare.stats(game,clone)
   var old_equipment:Dictionary=game.inventory.equipped.duplicate(true);var old_max:float=game.player_max_hp;var old_bonus:float=game.equipment_hp_bonus
   game.inventory.equipped=clone.equipped.duplicate(true);game.refresh_equipment_health()
   assert(is_equal_approx(projected["Base strike power"],game.base_damage*game.equipment_damage_multiplier()) and is_equal_approx(projected["Auto-attack delay"],game.current_attack_interval()) and is_equal_approx(projected["Critical chance"],game.effective_crit_chance()*100) and is_equal_approx(projected["Maximum HP"],game.player_max_hp))
   game.inventory.equipped=old_equipment;game.player_max_hp=old_max;game.equipment_hp_bonus=old_bonus;game.player_hp=hp;cases+=1
   if id in ["dawnweave","mirrorwake","ironpaw_plate","stormspark"]:
    game.pending_items=[item];game.show_next_item();await capture("comparison_"+str(item.slot));var quick=game.item_compare.get_meta("quick_comparison");var header_position:Vector2=quick.position;assert(quick.rows.size()==6 and quick.found.name==item.name)
    assert(quick.effects_button.is_visible_in_tree());await tap(quick.effects_button);assert(quick.showing_effects and game.item_compare.is_visible_in_tree())
    assert(game.item_compare.get_v_scroll_bar().value<1)
    var attacks_before:int=game.attack_sequence
    await swipe(game.item_compare);game.touch_ux.inertia=null;await process_frame
    assert(game.state=="item" and game.attack_sequence==attacks_before)
    game.item_compare.get_v_scroll_bar().value=game.item_compare.get_v_scroll_bar().max_value
    assert(quick.position==header_position and quick.visible)
    await capture("comparison_"+str(item.slot)+"_all_effects")
  # Refused persistence cannot change gear, overflow salvage, HP or rewards.
  game.current_item=game.ItemCatalog.create_item("tidestar","MYTHICAL SHINY",6060);game.state="item"
  game.inventory.equipped.Weapon=game.ItemCatalog.create_item("scrapfang_blade","RED",6061)
  game.inventory.stash.clear()
  for n in range(game.inventory.stash_capacity):game.inventory.stash.append(game.ItemCatalog.create_item("scrapfang_blade","RARE",7000+n))
  assert(game.build_item_comparison(game.current_item,game.inventory.equipped.Weapon).contains("FULL STASH"))
  var scrap_before:int=game.inventory.scrap
  game.inventory.save(game.INVENTORY_SAVE_PATH)
  var saved:String=FileAccess.get_sha256(game.INVENTORY_SAVE_PATH);var inventory_before:String=JSON.stringify(game.inventory.equipped);var records_before:String=JSON.stringify(game.inventory.stash);var kept_before:String=JSON.stringify(game.run_kept_loot)
  Scope.transitioning=true;game.accept_item_equip();Scope.transitioning=false
  assert(game.inventory.scrap==scrap_before and game.state=="item" and JSON.stringify(game.inventory.equipped)==inventory_before and JSON.stringify(game.inventory.stash)==records_before and JSON.stringify(game.run_kept_loot)==kept_before and FileAccess.get_sha256(game.INVENTORY_SAVE_PATH)==saved)
  var full_stash:Array=game.inventory.stash.duplicate(true)
  game.inventory.stash.clear();game.inventory.save(game.INVENTORY_SAVE_PATH)
  saved=FileAccess.get_sha256(game.INVENTORY_SAVE_PATH)
  for action in ["keep","scrap"]:
   Scope.transitioning=true
   if action=="keep":game.accept_item_keep()
   else:game.accept_item_scrap()
   Scope.transitioning=false
   assert(game.state=="item" and not game.current_item.is_empty() and game.inventory.stash.is_empty() and game.inventory.scrap==scrap_before and JSON.stringify(game.run_kept_loot)==kept_before and FileAccess.get_sha256(game.INVENTORY_SAVE_PATH)==saved and game.item_compare.text.contains("not been consumed"))
  game.inventory.stash=full_stash
  game.show_hideout();game.hideout_ui.show_forge();await capture("forge_full_preview")
  game.gold=100000;game.refresh_hideout();game.hideout_ui.show_shop();await tap(game.hideout_ui.shop_offer_buttons[0])
  assert(game.hideout_ui.shop_buy_button.disabled and game.hideout_ui.shop_buy_button.text.contains("IS FULL"))
  await capture("shop_full_stash_block")
  game.inventory.stash.clear();game.refresh_hideout();await tap(game.hideout_ui.shop_offer_buttons[0]);assert(game.hideout_ui.shop_buy_button.text.contains("LOOTCOINS") and not game.hideout_ui.shop_buy_button.text.contains("SCRAP") and game.hideout_ui.shop_detail.text.contains("Remaining after purchase"));await capture("shop_full_preview")
  game.free();await process_frame
 print("COMPARISON 060 NATIVE PASS: %d fixed-canon items across four slots and four layouts, complete untruncated effect keys/signatures, real formula-equivalent stat previews, no preview mutation/RNG, refused equip-save rollback. Visual/route/cost acceptance remains scoped." % cases);quit()
