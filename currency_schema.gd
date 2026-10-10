extends RefCounted
# One-to-one names only. No price, payout, power, material or balance conversion.
const VERSION:=4
static func balances(config:ConfigFile) -> Dictionary:
 var safe=preload("res://safe_config.gd")
 # A canonical field takes precedence, never sums with its legacy mirror.
 return {"gold":clampi(safe.int_value(config.get_value("progress","lootcoins",config.get_value("progress","gold",0))),0,999999999),
 "shards":clampi(safe.int_value(config.get_value("progress","loot_diamonds",config.get_value("progress","shards",0))),0,999999)}
static func write_names(config:ConfigFile,coins:int,diamonds:int) -> void:
 config.set_value("progress","version",VERSION)
 config.set_value("progress","lootcoins",clampi(coins,0,999999999))
 config.set_value("progress","loot_diamonds",clampi(diamonds,0,999999))
 config.set_value("progress","currency_migration","gold-shards-one-to-one-v4")
