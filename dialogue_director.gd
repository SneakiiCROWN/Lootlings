extends RefCounted

const RECENT_LIMIT := 6
const SPEAKER_COOLDOWN := 4.5

const POOLS := {
	"forge_evolved":[
		{"speaker":"Salvager", "text":"Same blade. Better argument. Mind the new edge.", "weight":3.0},
		{"speaker":"Salvager", "text":"I taught the metal some manners. Mostly bad ones.", "weight":2.0}
	],
	"new_weapon":[
		{"speaker":"Salvager", "text":"A fresh weapon! No warranty on ghosts.", "weight":3.0},
		{"speaker":"Mascot", "text":"New gear smell. Old treasure intentions.", "weight":2.0}
	],
	"contract_complete":[
		{"speaker":"Archivist", "text":"Job done. Gold counted. Your handwriting remains a crime.", "weight":3.0},
		{"speaker":"Salvager", "text":"Honest payment. I'll try not to make a habit of it.", "weight":2.0}
	],
	"idle":[
		{"speaker":"Salvager", "text":"If it sparks, it's either valuable or educational.", "weight":3.0},
		{"speaker":"Salvager", "text":"That dent? Structural personality.", "weight":2.0},
		{"speaker":"Salvager", "text":"If it rattles, it is either valuable or awake.", "weight":3.0},
		{"speaker":"Salvager", "text":"I sorted the Scrap. It immediately unsorted itself.", "weight":2.0},
		{"speaker":"Archivist", "text":"Today's footnotes contain more teeth than expected.", "weight":3.0},
		{"speaker":"Archivist", "text":"The quiet books are always the suspicious ones.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"The Core is humming. Politely, for once.", "weight":3.0},
		{"speaker":"Relic Keeper", "text":"Ancient power also needs dusting.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"A bright relic is not necessarily a kind one.", "weight":2.0},
		{"speaker":"Archivist", "text":"History is mostly people opening things labelled DO NOT OPEN.", "weight":2.0},
		{"speaker":"Mascot", "text":"Treasure first. Snack inventory second.", "weight":2.0}
	],
	"tapped":[
		{"speaker":"Salvager", "text":"Careful! I just convinced that part to stay attached.", "weight":3.0},
		{"speaker":"Salvager", "text":"Need gear, gossip, or a professionally dented spoon?", "weight":2.0},
		{"speaker":"Archivist", "text":"Yes, I recorded the incident. No, you may not edit it.", "weight":3.0},
		{"speaker":"Archivist", "text":"One tap means hello. Two taps means citation needed.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"Soft paws near the relics, please.", "weight":3.0},
		{"speaker":"Relic Keeper", "text":"Listen closely. The crystal remembers brave things.", "weight":2.0},
		{"speaker":"Mascot", "text":"Ready! Probably. Point me toward the shiny danger.", "weight":3.0},
		{"speaker":"Mascot", "text":"I was not sitting on that coin. It chose me.", "weight":2.0}
	],
	"returning":[
		{"speaker":"Salvager", "text":"Back already? Excellent. The repair bill was lonely.", "weight":2.0},
		{"speaker":"Archivist", "text":"Welcome back. Try to describe the screaming alphabetically.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"The gate dimmed when you returned. A good sign.", "weight":3.0}
	],
	"early_defeat":[
		{"speaker":"Salvager", "text":"A tactical retreat! With bonus bruises.", "weight":3.0},
		{"speaker":"Archivist", "text":"A short chapter can still contain useful warnings.", "weight":2.0},
		{"speaker":"Mascot", "text":"I found the floor. Very thoroughly.", "weight":3.0}
	],
	"victory":[
		{"speaker":"Salvager", "text":"You won! Put the treasure down gently. Near my counter.", "weight":3.0},
		{"speaker":"Archivist", "text":"Victory recorded. Embellishments pending.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"The Core burns brighter after a worthy return.", "weight":3.0},
		{"speaker":"Mascot", "text":"Hoard conquered. Snack barrel, prepare yourself.", "weight":2.0}
	],
	"epic_find":[
		{"speaker":"Salvager", "text":"Epic salvage! Even the dents look expensive.", "weight":3.0},
		{"speaker":"Archivist", "text":"Purple rarity. Historically associated with showing off.", "weight":2.0},
		{"speaker":"Mascot", "text":"It glows! That means it likes me.", "weight":3.0}
	],
	"legendary_find":[
		{"speaker":"Salvager", "text":"Legendary! Nobody breathe on it until I price the shine.", "weight":3.0},
		{"speaker":"Archivist", "text":"A true Legendary. The Archive just made room by itself.", "weight":3.0},
		{"speaker":"Relic Keeper", "text":"Old power recognizes old power.", "weight":2.0},
		{"speaker":"Mascot", "text":"Mine has more sparkles than the moon.", "weight":2.0}
	],
	"boss_defeated":[
		{"speaker":"Archivist", "text":"The Hoard Dragon falls. Ink, please. The dramatic ink.", "weight":3.0},
		{"speaker":"Salvager", "text":"Dragon-grade dents! My favourite kind.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"The deep vault is quiet. For now.", "weight":3.0}
	],
	"travel":[
		{"speaker":"Mascot", "text":"Oversized weapons are a feature, not a workplace incident.", "weight":2.0},
		{"speaker":"Archivist", "text":"Take the old road. The new one has started answering back.", "weight":2.0},
		{"speaker":"Salvager", "text":"Run Scrip disappears after a run. Spend it or enjoy the memory.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"If something sparkles in Hoard Depths, assume it has opinions.", "weight":2.0}
	],
	"variant_seen":[
		{"speaker":"Archivist", "text":"Variant sighted. I discovered paperwork.", "weight":3.0},
		{"speaker":"Mascot", "text":"Weird usually means important. Or bitey.", "weight":2.0}
	],
	"cache_opened":[
		{"speaker":"Salvager", "text":"A fine cache. The lock only bit me once.", "weight":3.0},
		{"speaker":"Mascot", "text":"Box opened. Treasure confirmed. Excellent box.", "weight":2.0},
		{"speaker":"Archivist", "text":"Cache contents logged under fortunate rummaging.", "weight":2.0}
	],
	"shop_purchase":[
		{"speaker":"Salvager", "text":"Sold! No refunds if it develops opinions.", "weight":3.0},
		{"speaker":"Salvager", "text":"Good choice. I tightened the important-looking screws.", "weight":2.0},
		{"speaker":"Mascot", "text":"New gear smell! Mostly brass and mystery.", "weight":2.0}
	],
	"shrine_upgrade":[
		{"speaker":"Relic Keeper", "text":"There. The Core remembers a little more of itself.", "weight":3.0},
		{"speaker":"Relic Keeper", "text":"Power settles best when paws remain off the altar.", "weight":2.0},
		{"speaker":"Mascot", "text":"I feel shinier. Also slightly tingly.", "weight":2.0}
	],
	"large_hoard":[
		{"speaker":"Salvager", "text":"That is not a pile. That is a structural concern.", "weight":3.0},
		{"speaker":"Archivist", "text":"The hoard now requires its own appendix.", "weight":2.0},
		{"speaker":"Mascot", "text":"We may need a bigger satchel. And floor.", "weight":3.0}
	],
	"first_visit":[
		{"speaker":"Archivist", "text":"Welcome to the Hideout. Every treasure has a story—or teeth.", "weight":3.0},
		{"speaker":"Salvager", "text":"New paws! Keep them clear of the sorting hammer.", "weight":2.0},
		{"speaker":"Relic Keeper", "text":"Your Relic Core has found its way home.", "weight":3.0}
	],
	"rare":[
		{"speaker":"Archivist", "text":"Between us, the moon owes the Salvager three coins.", "weight":1.0},
		{"speaker":"Salvager", "text":"The left lantern is haunted. The right one is just rude.", "weight":1.0},
		{"speaker":"Relic Keeper", "text":"Sometimes the Core dreams in colours without names.", "weight":1.0}
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
