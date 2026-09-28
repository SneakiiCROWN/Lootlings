extends RefCounted

const IDENTITIES := ["Fire", "Lightning", "Poison", "Physical"]
const COLORS := {
	"Neutral": Color("#ffbd45"),
	"Fire": Color("#ff784f"),
	"Lightning": Color("#73dfff"),
	"Poison": Color("#8ee05a"),
	"Physical": Color("#ffc85a")
}
const DARK_COLORS := {
	"Neutral": Color("#6f452d"),
	"Fire": Color("#8c2731"),
	"Lightning": Color("#28549b"),
	"Poison": Color("#376b38"),
	"Physical": Color("#8d5930")
}
const CLASS_INFLUENCES := {
	"Neutral": "Main Mascot RelicBeast",
	"Fire": "Emberhorn",
	"Lightning": "Moonkip",
	"Poison": "Mosskin",
	"Physical": "Pebblewyrm"
}

var tags := {}
var last_identity := "Neutral"
var upgrade_total := 0

func _init() -> void:
	reset()

func reset() -> void:
	tags.clear()
	for identity in IDENTITIES:
		tags[identity] = 0
	last_identity = "Neutral"
	upgrade_total = 0

func add_upgrade(upgrade: Dictionary) -> void:
	upgrade_total += 1
	for identity in upgrade.get("tags", []):
		if identity in IDENTITIES:
			tags[identity] = int(tags.get(identity, 0)) + 1
			last_identity = identity

func count(identity: String) -> int:
	return int(tags.get(identity, 0))

func dominant() -> String:
	var winner := "Neutral"
	var best := 0
	for identity in IDENTITIES:
		var value := count(identity)
		if value > best or (value == best and value > 0 and identity == last_identity):
			best = value
			winner = identity
	return winner

func tier(identity: String = dominant()) -> int:
	var value := count(identity)
	if value >= 5:
		return 2
	if value >= 2:
		return 1
	return 0

func tier_name(identity: String = dominant()) -> String:
	match tier(identity):
		2: return "ASCENDED"
		1: return "AWAKENED"
		_: return "SPARK"

func weapon_tier() -> int:
	if upgrade_total >= 7:
		return 2
	if upgrade_total >= 3:
		return 1
	return 0

func color(identity: String = dominant()) -> Color:
	return COLORS.get(identity, COLORS.Neutral)

func dark_color(identity: String = dominant()) -> Color:
	return DARK_COLORS.get(identity, DARK_COLORS.Neutral)

func class_influence(identity: String = dominant()) -> String:
	return CLASS_INFLUENCES.get(identity, "Main Mascot RelicBeast")

func short_summary() -> String:
	var parts: Array[String] = []
	for identity in IDENTITIES:
		if count(identity) > 0:
			parts.append("%s %d" % [identity, count(identity)])
	return "  /  ".join(parts) if not parts.is_empty() else "Relic Core dormant"
