extends RefCounted
# Optional entry ledger lives in the same atomic snapshot as both permanent wallets.
const ENTRY_COST=2
const BONUS_COINS=250
const BONUS_DIAMONDS=20
static func defaults() -> Dictionary:return {"sigils":0,"receipts":[],"entry":"","clears":0,"pity":0,"collection":0,"pending":[]}
static func sanitize(value: Dictionary) -> Dictionary:
 var result:=defaults()
 result.sigils=clampi(preload("res://safe_config.gd").int_value(value.get("sigils",0)),0,999999)
 for key in ["clears","pity","collection"]:result[key]=clampi(preload("res://safe_config.gd").int_value(value.get(key,0)),0,999999)
 var pending=value.get("pending",[])
 if pending is Array:
  for reward in pending:
   if reward is Dictionary and reward.get("id","") in preload("res://mythical_collection.gd").IDS and reward.get("receipt",null) is String:result.pending.append(reward.duplicate(true))
 var receipts=value.get("receipts",[])
 if receipts is Array:
  for receipt in receipts:
   if receipt is String and receipt.length()<240 and not receipt in result.receipts:result.receipts.append(receipt)
  if result.receipts.size()>128:result.receipts=result.receipts.slice(-128)
 var entry=value.get("entry","")
 if entry is String and entry.length()<240:result.entry=entry
 return result
static func enter(game, token: String) -> bool:
 if token.is_empty() or not game.rift_progress.entry.is_empty() or game.rift_progress.sigils<ENTRY_COST:return false
 game.rift_progress.sigils-=ENTRY_COST;game.rift_progress.entry=token
 return game.save_hideout_economy()
static func settle(game, token: String, victory: bool, kills: int, elite: bool) -> String:
 var receipt="rift:"+token
 if token.is_empty() or receipt in game.rift_progress.receipts:return ""
 # An empty/short route cannot farm Sigils or claim elite victory bonuses.
 var qualified= victory and kills>=8
 var sigils=1 if qualified else 0
 var coins=BONUS_COINS if qualified and elite and not game.rift_progress.entry.is_empty() else 0
 var diamonds=BONUS_DIAMONDS if coins>0 else 0
 game.rift_progress.sigils=mini(999999,game.rift_progress.sigils+sigils)
 game.gold+=coins;game.meta_shards+=diamonds
 game.rift_progress.receipts.append(receipt)
 if game.rift_progress.receipts.size()>128:game.rift_progress.receipts.pop_front()
 if coins>0:
  game.rift_progress.clears+=1;game.rift_progress.pity+=1
  # 1% per eligible clear; at most 24 clears between finds. Cycle the initial
  # eight-item collection before repeats, so no duplicate blocks completion.
  if game.rift_progress.pity>=24 or absi(hash(receipt))%1000<10:
   var id: String=preload("res://mythical_collection.gd").IDS[int(game.rift_progress.collection)%8]
   game.rift_progress.collection+=1;game.rift_progress.pity=0
   game.rift_progress.pending.append({"id":id,"receipt":"mythical:"+receipt})
 game.rift_progress.entry=""
 if not game.save_hideout_economy():return "Rift reward could not be saved. No additional currency was charged."
 return ("RIFT REWARDS â€¢ +%d Sigil â€¢ +%d Lootcoins â€¢ +%d Diamonds" % [sigils,coins,diamonds]) if coins>0 else ("+1 RIFT SIGIL â€¢ optional elite entry costs 2" if sigils>0 else "")

static func recover(game) -> Array:
 var delivered:Array=[]
 while not game.rift_progress.pending.is_empty():
  var reward:Dictionary=game.rift_progress.pending[0]
  var item:Dictionary=preload("res://item_catalog.gd").create_item(reward.id,"MYTHICAL SHINY",int(hash(reward.receipt)))
  if not reward.receipt in game.inventory.craft_receipts:
   if game.inventory.stash.size()>=game.inventory.stash_capacity:break
   if not game.inventory.keep(item):break
   game.inventory.craft_receipts.append(reward.receipt)
  game.rift_progress.pending.pop_front()
  if not game.save_hideout_economy():break
  delivered.append({"kind":"item","rarity":"MYTHICAL SHINY","item":item,"receipt":reward.receipt})
 return delivered
