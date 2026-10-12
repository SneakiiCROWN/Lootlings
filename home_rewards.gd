extends RefCounted
# A saved achievement is the sole entitlement. No second payout/store/currency.
const ACHIEVEMENT="hoard_dragon"
const DECOR_ID="home_dragon_keepsake"
const NAME="Dragon, Dislodged"
static func earned(game) -> bool:return game.achievements.is_unlocked(ACHIEVEMENT)
static func displayed(game) -> bool:
	return earned(game) and game.profile.get("homestead",{}).get("home_layout",{}).get("placements",{}).get("home.wall_display","")==DECOR_ID
static func preview(game) -> void:
	if not earned(game):return
	game.show_personal_home("decor")
	var home=game.personal_home
	home.draft=preload("res://home_catalog.gd").sanitize(game.profile.get("homestead",{}),str(game.profile.get("companion",{}).get("equipped_id",""))).home_layout.duplicate(true)
	home.draft.placements["home.wall_display"]=DECOR_ID;home.selected_slot="home.wall_display";home.open("decor_preview")
