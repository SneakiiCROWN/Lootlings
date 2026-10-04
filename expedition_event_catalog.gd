extends RefCounted

# Optional choices disclose all costs. Skip always preserves current state.
# Only two scheduled opportunities per expedition; no mid-fight popups.
const EVENTS := {
	"wounded_courier":{"title":"A LIGHT STILL MOVING", "line":"A Compact courier is pinned beneath a fallen sign. Their satchel is intact.", "choices":[{"name":"Lift the sign", "desc":"Lose 8 HP, gain 45 Run Scrip.", "hp":-8,"scrip":45},{"name":"Share supplies", "desc":"Spend 30 Run Scrip, recover 18 HP.","hp":18,"scrip":-30}]},
	"promise_shrine":{"title":"THE UNFINISHED PROMISE", "line":"The Core hums beside an empty cradle. Sera's words return: ask before taking.", "choices":[{"name":"Leave a useful offering", "desc":"Spend 40 Run Scrip for a run upgrade.","scrip":-40,"upgrade":true},{"name":"Keep its light safe", "desc":"Recover 12 HP. Leave the relic where it belongs.","hp":12}]},
	"sealed_cache":{"title":"A LOCK WITH OPINIONS", "line":"Three hinges. Two warnings. One promise of something worth the trouble.", "choices":[{"name":"Break the seal", "desc":"Lose 12 HP for one Rare+ item.","hp":-12,"loot":"RARE"},{"name":"Pick the quiet latch", "desc":"Gain 25 Run Scrip. Leave the dangerous seal alone.","scrip":25}]},
	"lantern_bargain":{"title":"THE LONG WAY HOME", "line":"Merrow has a spare lantern and absolutely no explanation for the teeth marks.", "choices":[{"name":"Buy the lantern", "desc":"Spend 45 Run Scrip for 12 ward.","scrip":-45,"ward":12},{"name":"Sell the dented bracket", "desc":"Gain 20 Run Scrip.","scrip":20}]},
	"ink_witness":{"title":"SOMEONE WAS HERE", "line":"A name survives beneath a Crown correction. Ilex left room in her ledger.", "choices":[{"name":"Make a careful copy", "desc":"Gain 30 XP and recover 8 HP.","xp":30,"hp":8},{"name":"Recover the metal seal", "desc":"Gain 35 Run Scrip. Preserve the page.","scrip":35}]},
	"cursed_coffer":{"title":"INTEREST DUE", "line":"A courier coffer offers treasure today. The scarred latch explains the terms.", "choices":[{"name":"Accept the debt", "desc":"One Epic+ item. Next foe deals 20% more damage.","loot":"EPIC","risk":1.2},{"name":"Break the contract", "desc":"Gain 20 Run Scrip. No curse.","scrip":20}]},
	"mirror_pool":{"title":"THE WRONG REFLECTION", "line":"Your reflection reaches for the treasure first. It has always been rude.", "choices":[{"name":"Take the measured risk", "desc":"Lose 10 HP. Next foe takes 25% more hit damage.","hp":-10,"power":1.25},{"name":"Leave a ripple", "desc":"Recover 10 HP.","hp":10}]},
	"patch_warranty":{"title":"ONE CAREFUL OWNER", "line":"Patch's discarded warranty reads: valid until the first interesting noise.", "choices":[{"name":"Trade for repairs", "desc":"Spend 25 Run Scrip, recover 25 HP.","scrip":-25,"hp":25},{"name":"Collect the useful bits", "desc":"Gain 25 Run Scrip.","scrip":25}]},
	"secret_bell":{"title":"THE BELL THAT DIDN'T RING","line":"Three scratches point beneath a bridge. Someone left the latch warm. Follow the quiet, not the gold.","choices":[{"name":"Open the quiet door","desc":"Lose 10 HP for one Epic+ find. Record the bell-door clue.","hp":-10,"loot":"EPIC"},{"name":"Copy the hinge marks","desc":"Gain 30 XP; keep the clue in your field collection.","xp":30}]},
	"wandering_smith":{"title":"A FORGE ON TWO FEET","line":"A travelling Compact smith has a fireproof backpack and very little patience for your nickname.","choices":[{"name":"Commission a road find","desc":"Spend 180 Run Scrip for one Epic+ item.","scrip":-180,"loot":"EPIC"},{"name":"Share a good route","desc":"Recover 12 HP. No payment.","hp":12}]},
	"mimic_parley":{"title":"TEETH BEHIND THE RECEIPT","line":"The chest clears its throat. It offers a polite bargain before resorting to the old impolite one.","choices":[{"name":"Accept the tooth tax","desc":"One Epic+ item; next foe deals 20% more damage.","loot":"EPIC","risk":1.2},{"name":"Trade an honest story","desc":"Gain 35 XP. Leave its lunch alone.","xp":35}]},
}

static func choices_for(id: String, wave: int) -> Array:
	var choices: Array = EVENTS[id].choices.duplicate(true)
	if wave >= 12 and id == "sealed_cache":
		choices[1] = {"name":"Pay the locksmith", "desc":"Spend 220 Run Scrip for one Epic+ item. No HP lost.","scrip":-220,"loot":"EPIC"}
	elif wave >= 12 and id == "cursed_coffer":
		choices[1] = {"name":"Buy out the debt", "desc":"Spend 280 Run Scrip for one Epic+ item. No curse.","scrip":-280,"loot":"EPIC"}
	return choices

static func roll(rng: RandomNumberGenerator, seen: Array) -> String:
	var pool: Array = EVENTS.keys().filter(func(id): return not id in ["secret_bell","wandering_smith","mimic_parley"] and not id in seen)
	if pool.is_empty(): return ""
	var weights := PackedFloat32Array()
	for id in pool: weights.append(.5 if id == "cursed_coffer" else .75 if id == "mirror_pool" else 1.0)
	return str(pool[rng.rand_weighted(weights)])
