extends RefCounted

# Regional travel has its own atmosphere; boss and Act I cues retain their
# established score and transitions. No profile, progression or RNG changes.
const CUES := {
    "mossglass_wilds":"MOSSGLASS_WILDS",
    "frostbell_hollows":"FROSTBELL_HOLLOWS",
    "sunken_gearworks":"SUNKEN_GEARWORKS",
    "nullglass_expanse":"NULLGLASS_EXPANSE"
}

static func combat_cue(region: String, zone: String, boss: bool) -> String:
    if boss: return "BOSS"
    if CUES.has(region): return CUES[region]
    return "SALVAGE_WARRENS" if zone=="emberworks" else "HOARD_DEPTHS" if zone=="hoard_depths" else "OUTER_RUINS"
