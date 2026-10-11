extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
 var guide=game.contextual_guide;guide.enabled=true;guide.read_ids=["equipment","shop","forge","upgrades"];guide.practised_ids.clear();assert(guide.persist()==OK)
 game.start_run();game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.pending_items=[game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",919)];game.show_next_item()
 preload("res://save_scope.gd").transitioning=true;game.accept_item_equip();preload("res://save_scope.gd").transitioning=false;assert(not "equipment" in guide.practised_ids)
 game.accept_item_equip();assert("equipment" in guide.practised_ids)
 game.show_hideout();game.gold=0;game.buy_hideout_offer(0);assert(not "shop" in guide.practised_ids)
 game.gold=10000;game.inventory.stash.clear();game.buy_hideout_offer(0);assert("shop" in guide.practised_ids)
 game.buy_gold_upgrade("bedroll");assert("upgrades" in guide.practised_ids)
 game.inventory.equipped.Weapon=game.ItemCatalog.create_item("scrapfang_blade","COMMON",920);game.inventory.scrap=100;game.evolve_owned_weapon(-1);assert("forge" in guide.practised_ids)
 guide.enabled=false;guide.practised_ids.erase("shop");guide.observe_success("shop");assert(not "shop" in guide.practised_ids)
 guide.enabled=true;assert(guide.persist()==OK);var reloaded=load("res://contextual_guide.gd").new();reloaded.configure(game);assert("forge" in reloaded.practised_ids);reloaded.free();game.free()
 print("GUIDE PRACTICE 063 PASS: actual saved equip/shop/upgrade/evolution, rejected equip save and unaffordable/disabled guards, restart persistence; no forced actions.");quit()

