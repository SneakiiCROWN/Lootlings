extends RefCounted

# Run-only identities. No save-schema changes or weapon restrictions.
const TRAITS := {
	"relic_beast":{"name":"Pocket Promise", "text":"Each fifth foe leaves 8 extra Run Scrip. Any weapon; no combat penalty.", "starter":"scrapfang_blade", "hp":0, "move":1.0, "perk":"scavenger"},
	"emberhorn":{"name":"Rescue Furnace", "text":"Every fourth attack kindles a short burn. 10 less HP; burns reward steady pressure.", "starter":"scrap_axe", "hp":-10, "move":1.0, "perk":"kindle"},
	"mosskin":{"name":"Patient Shelter", "text":"Recover 2 HP after each nonfatal enemy hit. 15 more HP; approach 15% slower.", "starter":"glimmerstaff", "hp":15, "move":0.85, "perk":"shelter"},
	"moonkip":{"name":"Moonlit Opening", "text":"Each foe's first hit deals 25% more damage. 12 less HP; approach 15% faster.", "starter":"moonbite_daggers", "hp":-12, "move":1.15, "perk":"opening"},
	"pebblewyrm":{"name":"Load-Bearing Confidence", "text":"Every fifth attack delays the foe by 0.25s. 12 more HP; approach 12% slower.", "starter":"mimic_mallet", "hp":12, "move":0.88, "perk":"stagger"},
	"glimmerfin":{"name":"Unrequested Encore", "text":"Every sixth attack echoes for 35% power. 8 less HP; rewards fast weapons.", "starter":"glimmerstaff", "hp":-8, "move":1.0, "perk":"encore"},
	"gloomlet":{"name":"Affectionate Denial", "text":"The first enemy hit per foe is 30% weaker. 8 less HP; short fights favour you.", "starter":"moonbite_daggers", "hp":-8, "move":1.1, "perk":"veil"},
	"vault_runner":{"name":"Courier's Advance", "text":"Each kill stores 10% power for the next foe. 8 less HP; approach 12% faster.", "starter":"bonebow", "hp":-8, "move":1.12, "perk":"advance"},
	"ruin_warden":{"name":"Stand Together", "text":"Enemy hits above 15 damage are softened 15%. 8 more HP; approach 10% slower.", "starter":"scrapfang_blade", "hp":8, "move":0.9, "perk":"brace"},
	"nightstage_drifter":{"name":"Final Bow", "text":"Hits deal 15% more power below 35% foe HP. 10 less HP; strong finishes.", "starter":"moonbite_daggers", "hp":-10, "move":1.1, "perk":"finish"},
	"velvet_astrologer":{"name":"Read the Stars", "text":"Every fifth attack restores 2 HP. 8 less HP; attack rhythm sustains you.", "starter":"glimmerstaff", "hp":-8, "move":1.0, "perk":"renew"},
	"ashtrail_hunter":{"name":"Patient Aim", "text":"Each foe's first critical hit adds 30% power. 5 less HP; steady critical builds.", "starter":"bonebow", "hp":-5, "move":1.0, "perk":"aim"},
}

static func actor_id(profile: Dictionary) -> String:
	return str(profile.get("wanderer",{}).get("preset_id","vault_runner")) if profile.get("avatar_mode","lootling") == "wanderer" else str(profile.get("current_lootling_id","relic_beast"))

static func definition(profile: Dictionary) -> Dictionary:
	return TRAITS.get(actor_id(profile),TRAITS.relic_beast)
