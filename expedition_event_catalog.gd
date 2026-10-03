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
}

static func roll(rng: RandomNumberGenerator, seen: Array) -> String:
	var pool: Array = EVENTS.keys().filter(func(id): return not id in seen)
	return str(pool[rng.randi_range(0,pool.size()-1)]) if not pool.is_empty() else ""
