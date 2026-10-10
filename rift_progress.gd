extends RefCounted
# Optional entry ledger lives in the same atomic snapshot as both permanent wallets.
const ENTRY_COST=2
const BONUS_COINS=250
const BONUS_DIAMONDS=20
static func defaults() -> Dictionary:return {"sigils":0,"receipts":[],"entry":""}
static func sanitize(value: Dictionary) -> Dictionary:
 var result:=defaults()
 result.sigils=clampi(preload("res://safe_config.gd").int_value(value.get("sigils",0)),0,999999)
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
 game.rift_progress.entry=""
 if not game.save_hideout_economy():return "Rift reward could not be saved. No additional currency was charged."
 return ("RIFT REWARDS • +%d Sigil • +%d Lootcoins • +%d Diamonds" % [sigils,coins,diamonds]) if coins>0 else ("+1 RIFT SIGIL • optional elite entry costs 2" if sigils>0 else "")
