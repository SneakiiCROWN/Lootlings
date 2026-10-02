extends RefCounted

const RECENT_LIMIT := 6
const SPEAKER_COOLDOWN := 4.5

const POOLS := {
	"signature_find":[
		{"speaker": "Archivist", "text": "A named relic. Read its signature before you equip it; old bargains rarely use small print.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "Someone carried this through the Crownfall. We owe it more than a price tag.", "weight": 2.0}
	],
	"trophy_earned":[
		{"speaker": "Archivist", "text": "Filed under improbable achievements. That shelf is becoming a problem.", "weight": 2.0},
		{"speaker": "Salvager", "text": "A trophy! Finally, a dent nobody expects me to repair.", "weight": 2.0}
	],
	"forge_evolved":[
		{"speaker": "Salvager", "text": "Same weapon, new behaviour. Try it on something that is not my door.", "weight": 2.0},
		{"speaker": "Salvager", "text": "Evolution complete. The warranty has fled into the hills.", "weight": 2.0}
	],
	"new_weapon":[
		{"speaker": "Salvager", "text": "Check the weapon family before you swap. A bigger number is not the whole build.", "weight": 2.0},
		{"speaker": "Mascot", "text": "New weapon. Same suspiciously confident paws.", "weight": 2.0}
	],
	"contract_complete":[
		{"speaker": "Archivist", "text": "Contract complete. Claim your payment at Local Contracts; admiration is not legal tender.", "weight": 2.0},
		{"speaker": "Salvager", "text": "You did the job. Collect the Gold before somebody invents a processing fee.", "weight": 2.0}
	],
	"idle":[
		{"speaker": "Salvager", "text": "I tested that hinge. It passed. The wall is appealing.", "weight": 2.0},
		{"speaker": "Salvager", "text": "Repair, reuse, occasionally run away. Sustainable business.", "weight": 2.0},
		{"speaker": "Archivist", "text": "The Crown indexed every relic and forgot every person. We are correcting the catalogue.", "weight": 2.0},
		{"speaker": "Archivist", "text": "The forbidden shelf is locked. This has mainly improved its marketing.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "A Core is a promise someone kept alive. Listen before you decide what it is worth.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "You may rest here. The world will remain inconvenient tomorrow.", "weight": 2.0},
		{"speaker": "Mascot", "text": "I packed provisions. Most of them are provisions for me.", "weight": 2.0}
	],
	"tapped":[
		{"speaker": "Salvager", "text": "Need gear? Shop is to my right. Unsolicited repair advice is regrettably free.", "weight": 2.0},
		{"speaker": "Salvager", "text": "That lever is decorative. This warning is based on several experiments.", "weight": 2.0},
		{"speaker": "Archivist", "text": "Trophies, notes and memories are in the Archive. Yes, we keep the embarrassing ones.", "weight": 2.0},
		{"speaker": "Archivist", "text": "You may revise your plan. You may not revise the witness statement.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "The shrine spends Star Shards on permanent power. Gold pays for Hideout improvements.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "You are allowed to put the satchel down. That is not a defeat condition.", "weight": 2.0},
		{"speaker": "Mascot", "text": "Point me at the ruins. I have a sword and a deeply unearned sense of readiness.", "weight": 2.0}
	],
	"returning":[
		{"speaker": "Salvager", "text": "Back in one piece. Excellent. I am charging for fewer pieces this week.", "weight": 2.0},
		{"speaker": "Archivist", "text": "Tell me what happened before the version with dramatic lighting.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "The gate brought you home. That matters more than what was in your hands.", "weight": 2.0}
	],
	"early_defeat":[
		{"speaker": "Salvager", "text": "Gold and Shards earned are yours. Try armour or healing upgrades before the next trip.", "weight": 2.0},
		{"speaker": "Archivist", "text": "A failed expedition is still evidence. The floor supplied most of it.", "weight": 2.0},
		{"speaker": "Mascot", "text": "I have assessed the situation. The situation has a very hard floor.", "weight": 2.0}
	],
	"victory":[
		{"speaker": "Salvager", "text": "Boss down, gear secured. Check your stash before spending the celebration fund.", "weight": 2.0},
		{"speaker": "Archivist", "text": "The vault is open. Its history is not finished with us.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "You brought a forgotten promise home. For tonight, that is enough.", "weight": 2.0},
		{"speaker": "Mascot", "text": "We won. I would like the victory feast to begin before the credits.", "weight": 2.0}
	],
	"epic_find":[
		{"speaker": "Salvager", "text": "Epic gear. Compare the effects before the colour makes the decision for you.", "weight": 2.0},
		{"speaker": "Archivist", "text": "A valuable find. Please resist using it to point at the valuable find.", "weight": 2.0},
		{"speaker": "Mascot", "text": "Purple. Very dignified. I shall ruin that immediately.", "weight": 2.0}
	],
	"legendary_find":[
		{"speaker": "Salvager", "text": "Legendary. Read the signature; that is where the interesting trouble lives.", "weight": 2.0},
		{"speaker": "Archivist", "text": "A relic survived the fall of an empire. You have survived carrying it across the room.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "This Core remembers its maker. Be gentle with that memory.", "weight": 2.0},
		{"speaker": "Mascot", "text": "Legendary acquired. Modesty has been unequipped.", "weight": 2.0}
	],
	"boss_defeated":[
		{"speaker": "Archivist", "text": "The guardian has fallen. Take the treasure; leave the names on the walls.", "weight": 2.0},
		{"speaker": "Salvager", "text": "Boss-grade salvage. My insurance company has gone very quiet.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "The vault has stopped holding its breath. Listen.", "weight": 2.0}
	],
	"travel":[
		{"speaker": "Mascot", "text": "Small paws. Large sword. The staircase has filed a complaint.", "weight": 2.0},
		{"speaker": "Archivist", "text": "A named windup means an attack is coming. Keep your eyes on the foe, not the coin shower.", "weight": 2.0},
		{"speaker": "Salvager", "text": "Spend Run Scrip at roadside merchants. Unspent Scrip expires when the expedition ends.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "Healing and armour keep ambitious builds alive. Power without a way home is a poor bargain.", "weight": 2.0},
		{"speaker": "Archivist", "text": "Tap the arena for extra strikes. Menus and the HUD are safe to touch.", "weight": 2.0},
		{"speaker": "Mascot", "text": "If a corridor feels suspiciously generous, check whether it has teeth.", "weight": 2.0}
	],
	"variant_seen":[
		{"speaker": "Archivist", "text": "That foe has a modifier. Read the badge; the usual assumptions may be expensive.", "weight": 2.0},
		{"speaker": "Mascot", "text": "New variety of bad idea. I was hoping for a new variety of biscuit.", "weight": 2.0}
	],
	"cache_opened":[
		{"speaker": "Salvager", "text": "Cache opened. Contents are yours; equipping them is a separate decision.", "weight": 2.0},
		{"speaker": "Mascot", "text": "An actual chest! I appreciate a container that respects the job description.", "weight": 2.0},
		{"speaker": "Archivist", "text": "Recovered from a sealed cache. Previous owner: conspicuously absent.", "weight": 2.0}
	],
	"shop_purchase":[
		{"speaker": "Salvager", "text": "Sold. Inspect the effects, then equip or store it. Regret is sold separately.", "weight": 2.0},
		{"speaker": "Salvager", "text": "I checked the straps. The curse department has not returned my call.", "weight": 2.0},
		{"speaker": "Mascot", "text": "A sensible purchase. Somebody write that down before it stops being true.", "weight": 2.0}
	],
	"shrine_upgrade":[
		{"speaker": "Relic Keeper", "text": "That power stays with you between expeditions. The Core remembers.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "There. Stronger, not invincible. Please do not test the difference on my roof.", "weight": 2.0},
		{"speaker": "Mascot", "text": "Permanent upgrade. Temporary urge to lift the furniture.", "weight": 2.0}
	],
	"large_hoard":[
		{"speaker": "Salvager", "text": "The hoard needs another shelf. The shelf needs hazard pay.", "weight": 2.0},
		{"speaker": "Archivist", "text": "Your collection now has a table of contents. It is mostly warnings.", "weight": 2.0},
		{"speaker": "Mascot", "text": "Enough treasure to swim in. I have been advised to try a chair instead.", "weight": 2.0}
	],
	"first_visit":[
		{"speaker": "Archivist", "text": "Begin Expedition takes you into the ruins. Gear, upgrades and the Archive can wait until you return.", "weight": 2.0},
		{"speaker": "Salvager", "text": "Welcome home. Gold buys supplies; Scrap feeds the Forge. Keep both away from my lunch.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "A safe gate, warm lanterns, people who remember your name. We start there.", "weight": 2.0}
	],
	"rare":[
		{"speaker": "Archivist", "text": "The old vault map says HERE BE ACCOUNTANTS. We have found worse things.", "weight": 2.0},
		{"speaker": "Salvager", "text": "A prophecy predicted my success. Very little was said about the overheads.", "weight": 2.0},
		{"speaker": "Relic Keeper", "text": "Sometimes the Core remembers a sky we have never seen. Those are the quiet nights.", "weight": 2.0}
	]
}

var rng := RandomNumberGenerator.new()
var clock := 0.0
var recent: Array[String] = []
var speaker_ready := {}

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value

func update(delta: float) -> void:
	clock += maxf(0.0, delta)

func choose(context: String, requested_speaker: String = "", ignore_cooldown: bool = false) -> Dictionary:
	var source: Array = POOLS.get(context, POOLS.idle)
	var candidates: Array = []
	for entry in source:
		var speaker := str(entry.speaker)
		var text := str(entry.text)
		if not requested_speaker.is_empty() and speaker != requested_speaker:
			continue
		if not ignore_cooldown and clock < float(speaker_ready.get(speaker, 0.0)):
			continue
		if text in recent:
			continue
		candidates.append(entry)
	if candidates.is_empty():
		for entry in source:
			var speaker := str(entry.speaker)
			if (requested_speaker.is_empty() or speaker == requested_speaker) and (ignore_cooldown or clock >= float(speaker_ready.get(speaker, 0.0))):
				candidates.append(entry)
	if candidates.is_empty():
		return {}
	var total := 0.0
	for entry in candidates:
		total += float(entry.get("weight", 1.0))
	var roll := rng.randf() * total
	var chosen: Dictionary = candidates.back()
	for entry in candidates:
		roll -= float(entry.get("weight", 1.0))
		if roll <= 0.0:
			chosen = entry
			break
	var chosen_text := str(chosen.text)
	recent.append(chosen_text)
	while recent.size() > RECENT_LIMIT:
		recent.pop_front()
	speaker_ready[str(chosen.speaker)] = clock + SPEAKER_COOLDOWN
	return chosen.duplicate(true)

func recent_contains(text: String) -> bool:
	return text in recent
