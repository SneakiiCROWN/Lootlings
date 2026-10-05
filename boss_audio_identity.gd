extends RefCounted
# Sound follows the executed action, never a random cosmetic/QA facing flag.
static func event(region: String, action: String) -> String:
	if action in ["RECOVER","COOLING"]: return "" # silence exposes the opening
	match region:
		"moonfen": return "boss_reflection" if action=="LANTERN BITE" else "boss_prowler"
		"frostbell_hollows": return "boss_chime" if action=="CHIME" else "boss_chain" if action=="BELL STRIKE" else "boss_reflection"
		"sunken_gearworks": return "boss_steam" if action in ["STEAM VENT","PRESSURE RISE"] else "boss_chain"
		"cinder_crown": return "boss_chain" if action=="HAMMER" else "boss_furnace"
		"starfall_archive": return "weapon_daggers" if action=="PAGE CUT" else "boss_reflection" if action=="ERASE" else "boss_ink"
		"nullglass_expanse": return "contact_glass" if action=="GLASS CUT" else "boss_reflection"
		"skyhook_bastion": return "weapon_maul" if action=="ANCHOR SLAM" else "boss_chain"
		"first_hoard": return "boss_chain" if action=="CROWN STRIKE" else "boss_crown"
		"act_i": return "boss_furnace" if action=="COIN BREATH" else "boss_prowler"
	return ""
