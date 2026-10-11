extends RefCounted
# Rewards, disclosed probabilities and presentation are one source of truth.
const TIERS := ["COMMON","UNCOMMON","RARE","EPIC","LEGENDARY","RED","MYTHICAL SHINY"]
const COLORS := [Color("#899db5"),Color("#79df92"),Color("#69bbff"),Color("#c287ff"),Color("#ffda72"),Color("#ff526a"),Color("#d4fff4")]
const SPARK_TARGET := 12
const POOL := [
	{"rarity":"COMMON","kind":"material","amount":2,"weight":42},
	{"rarity":"UNCOMMON","kind":"mastery","amount":6,"weight":35},
	{"rarity":"RARE","kind":"blueprint","amount":1,"weight":15},
	{"rarity":"EPIC","kind":"material","amount":5,"weight":6},
	{"rarity":"LEGENDARY","kind":"material","amount":8,"weight":2}
]
static func roll(rng: RandomNumberGenerator) -> Dictionary:
	var value := rng.randf()*100.0
	var edge := 0.0
	for reward in POOL:
		edge += reward.weight
		if value < edge: return reward.duplicate(true)
	return POOL.back().duplicate(true)
static func tier(rarity: String) -> int: return maxi(0,TIERS.find(rarity))
static func color(rarity: String) -> Color: return COLORS[tier(rarity)]
static func icon_for(kind: String) -> String:
	return {"material":"currency_scrap","mastery":"currency_star_shard","blueprint":"gear_rune","item":"res://art/sprites/weapons/mage_staff.png"}.get(kind,"gear_charm")
static func flat_style(fill: Color, edge: Color, radius: int=8) -> StyleBoxFlat:
	var style:=StyleBoxFlat.new(); style.bg_color=fill; style.border_color=edge
	style.set_border_width_all(1); style.set_corner_radius_all(radius)
	style.content_margin_left=10; style.content_margin_right=10; style.content_margin_top=8; style.content_margin_bottom=8
	return style
static func spin_seconds(rarity: String, fast: bool) -> float:
	return .75 if fast and tier(rarity)<3 else 1.65+tier(rarity)*.18
static func anticipation(rarity: String) -> float: return [.12,.16,.22,.38,.50,.65,.80][tier(rarity)]
static func reveal_seconds(rarity: String) -> float: return [.28,.40,.52,.75,.95,1.25,1.55][tier(rarity)]
static func sound(rarity: String) -> String:
	return ["resource_pickup","rarity_reveal","rare_reveal","epic_reveal","legendary_reveal","relic_red","spinner_jackpot"][tier(rarity)]
static func reward_name(reward: Dictionary, region: String) -> String:
	if reward.has("display_name"): return reward.display_name
	if reward.get("kind","")=="item": return str(reward.get("item",{}).get("name","Relic"))
	return {"material":preload("res://phase4_catalog.gd").FARMS[region].material,"mastery":"Actor + weapon mastery","blueprint":"Regional recipe clue"}.get(reward.get("kind",""),"Reward")
static func pool_text() -> String:
	return "[color=#899db5][b]COMMON 42%[/b][/color]\n2 local materials\n\n[color=#79df92][b]UNCOMMON 35%[/b][/color]\n6 actor + weapon mastery\n\n[color=#69bbff][b]RARE 15%[/b][/color]\n1 regional recipe clue\n\n[color=#c287ff][b]EPIC 6%[/b][/color]\n5 local materials\n\n[color=#ffda72][b]LEGENDARY 2%[/b][/color]\n8 local materials\n\n[color=#ff526a][b]CROWNROOT CHASE[/b][/color]\n1 earned spin = 1 Spark\n12 Sparks = 1 fragment\n24 fragments = RED forge\n\n[b]FREE EARNED SPINS[/b]\nBoss, elite, 30 kills, secret or extraction.\nOne per reason / up to 3 per run.\nBank holds 12. Use now or later.\nNo currency charge.\n\n[font_size=12]Rewards save immediately. Reels are presentation only. Completed recipes convert clues to 2 materials. RED is a guaranteed forge, not a random spin.[/font_size]"
