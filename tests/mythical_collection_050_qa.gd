extends SceneTree
const Collection=preload("res://mythical_collection.gd")
const Catalog=preload("res://item_catalog.gd")
const Rift=preload("res://rift_progress.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var weapons:=0;var shields:=0
 for id in Collection.IDS:
  var item:Dictionary=Catalog.create_item(id,"MYTHICAL SHINY",50)
  assert(not item.is_empty() and not item.signature_hooks.is_empty() and item.rarity=="MYTHICAL SHINY")
  assert(Catalog.rarity_rank(item.rarity)>Catalog.rarity_rank("RED") and Catalog.scrap_value(item)==90)
  assert(preload("res://inventory_system.gd").sanitize_saved_item(item)==item)
  assert(Collection.texture(id)!=null and preload("res://lootlings_ui.gd").raw_item_texture(item)==Collection.texture(id))
  if item.slot=="Weapon":weapons+=1
  else:shields+=1;assert(item.slot=="Relic" and Collection.is_shield(id))
 assert(weapons==4 and shields==4)
 var loot=preload("res://loot_system.gd").new(5050);var shop=preload("res://hideout_shop_system.gd").new(5050)
 for i in range(1000):
  assert(not loot.generate_shop_item().id in Collection.IDS)
  shop.refresh_stock()
  for item in shop.stock:assert(not item.id in Collection.IDS)
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout()
 game.gold=1000;game.meta_shards=82;game.rift_progress.sigils=1000;assert(game.save_hideout_economy())
 var seen:Array=[]
 for run in range(192):
  assert(Rift.enter(game,"entry"+str(run)))
  Rift.settle(game,"qualified-clear"+str(run),true,14,true)
  var reserved:int=game.rift_progress.pending.size()
  Rift.settle(game,"qualified-clear"+str(run),true,14,true);assert(game.rift_progress.pending.size()==reserved)
  var deliveries:Array=Rift.recover(game)
  for reward in deliveries:
   if seen.size()<8:assert(not reward.item.id in seen);seen.append(reward.item.id)
  assert(game.rift_progress.pity<24)
  if seen.size()==8:break
 assert(seen==Collection.IDS and game.rift_progress.collection>=8)
 # Full stash retains a guaranteed reward; no dropped item or duplicate delivery.
 game.rift_progress.pending.append({"id":"dawnweave","receipt":"mythical:full-stash"});game.inventory.stash_capacity=game.inventory.stash.size();assert(game.save_hideout_economy())
 assert(Rift.recover(game).is_empty() and game.rift_progress.pending.size()==1)
 game.inventory.stash_capacity+=1;assert(game.save_hideout_economy());var before:int=game.inventory.stash.size()
 assert(Rift.recover(game).size()==1 and game.inventory.stash.size()==before+1);assert(Rift.recover(game).is_empty())
 game.load_meta();assert(game.rift_progress.pending.is_empty() and game.rift_progress.collection>=8)
 for id in Collection.IDS:
  var item:Dictionary=Catalog.create_item(id,"MYTHICAL SHINY",50);game.inventory.equipped[item.slot]=item;assert(game.inventory.has_signature(item.signature_hooks[0]))
 game.retention.rift_active=true;game.dungeon.setup(1);game.dungeon.depth=7;game.dungeon.room=game.dungeon.map[7][0];game.dungeon.room.wave=19;game.wave=19;game.spawn_enemy();assert(game.enemy_is_boss)
 print("MYTHICAL COLLECTION PASS: exactly four weapons/four shields, live signatures, custom icons, above-RED tier, guaranteed eight unique finds within 192 clears, no repeated settlement, full-stash recovery and actual elite boss at wave 19")
 game.free();quit()
