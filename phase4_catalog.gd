extends RefCounted

# New named sidegrades use supported weapon geometry and existing signature systems.
# No new anatomy, shield slot or unregistered art is implied.
const ITEMS := [
	{"id":"oath_slab","name":"Oath Slab","slot":"Weapon","weapon_type":"greatsword","family":"VANGUARD","icon":"BLADE","desc":"A heavy promise: delayed echoes reward deliberate hits.","effects":{"attack_slow":0.12,"heavy_bonus":0.14},"fixed_signature":"aftershock_receipt"},
	{"id":"root_splitter","name":"Root Splitter","slot":"Weapon","weapon_type":"greataxe","family":"VANGUARD","icon":"AXE","desc":"Survive four hits and the roots answer. A bruiser's axe, not a quick escape.","effects":{"max_hp":12.0,"attack_slow":0.08},"fixed_signature":"rooted_revenge"},
	{"id":"moonstage_shivs","name":"Moonstage Shivs","slot":"Weapon","weapon_type":"daggers","family":"ROGUE","icon":"DAGGERS","desc":"The first critical hit calls a spark. Thin armour leaves no room for stage fright.","effects":{"crit":0.08,"incoming_mult":0.08},"fixed_signature":"first_light"},
	{"id":"courier_pike","name":"Courier Pike","slot":"Weapon","weapon_type":"spear","family":"VANGUARD","icon":"BLADE","desc":"A first-hit chime buys time to carry your promise to the next door.","effects":{"attack_speed":0.06},"fixed_signature":"frostbell_chime"},
	{"id":"bellows_maul","name":"Bellows Maul","slot":"Weapon","weapon_type":"maul","family":"VANGUARD","icon":"MALLET","desc":"Heavy hits stagger; furnace heat turns the recovery beat into a burn window.","effects":{"fire_damage":0.22,"attack_slow":0.15},"fixed_signature":"burden_bell"},
	{"id":"rivet_fangs","name":"Rivet Fangs","slot":"Weapon","weapon_type":"claws","family":"ROGUE","icon":"DAGGERS","desc":"Bank a kill's impact, then spring. Close-range risk travels with the prize.","effects":{"incoming_mult":0.10,"attack_speed":0.09},"fixed_signature":"grudgekeeper"},
	{"id":"witness_bow","name":"Witness Bow","slot":"Weapon","weapon_type":"bow","family":"RANGER","projectile":"arrow","icon":"BOW","desc":"Every fifth shot calls lightning. Precision pays; haste is optional.","effects":{"crit":0.05},"fixed_signature":"crooked_constellation"},
	{"id":"coil_dispatch","name":"Coil Dispatch","slot":"Weapon","weapon_type":"crossbow","family":"RANGER","projectile":"bolt","icon":"BOW","desc":"Relic coils remember the first critical bolt against each target.","effects":{"crit":0.08,"attack_slow":0.12},"fixed_signature":"first_light"},
	{"id":"pilgrim_sling","name":"Pilgrim Sling","slot":"Weapon","weapon_type":"sling","family":"RANGER","projectile":"sling_stone","icon":"BOW","desc":"A five-shot lightning rhythm with room to carry more treasure.","effects":{"coin_mult":0.15},"fixed_signature":"crooked_constellation"},
	{"id":"marginalia_staff","name":"Marginalia Staff","slot":"Weapon","weapon_type":"staff","family":"MAGE","projectile":"magic_orb","icon":"STAFF","desc":"Mark three different foes quickly; the last gets the footnote.","effects":{"crit_lightning":0.10},"fixed_signature":"storm_receipt"},
	{"id":"hush_wand","name":"Hush Wand","slot":"Weapon","weapon_type":"wand","family":"MAGE","projectile":"wand_spark","icon":"STAFF","desc":"Silence is a first-hit delay. Poison uses the quiet time.","effects":{"poison_duration":0.25},"fixed_signature":"frostbell_chime"},
	{"id":"debt_orbit","name":"Debt Orbit","slot":"Weapon","weapon_type":"orb","family":"MAGE","projectile":"focus_shard","icon":"ORB","desc":"Cache-fed magic: the next hit gains stored force. Incoming damage rises.","effects":{"incoming_mult":0.12,"damage_mult":0.12},"fixed_signature":"mimic_appetite"},
	{"id":"second_skin","name":"Second Skin","slot":"Armour","icon":"GUARD","desc":"Critical kills grant ward. Thin fabric favors finishing before retaliation.","effects":{"max_hp":8.0,"crit":0.03},"fixed_signature":"critical_shelter"},
	{"id":"warden_warranty","name":"Warden Warranty","slot":"Armour","icon":"PLATE","desc":"Four survived hits earn a counterstroke; its weight slows attacks.","effects":{"max_hp":25.0,"attack_slow":0.08},"fixed_signature":"rooted_revenge"},
	{"id":"scarlet_margin","name":"Scarlet Margin","slot":"Armour","icon":"GUARD","desc":"Below 40% HP, your attack rhythm accelerates. The red ink is yours.","effects":{"incoming_mult":0.08,"low_health_damage":0.12},"fixed_signature":"last_laugh"},
	{"id":"keeper_coat","name":"Keeper Coat","slot":"Armour","icon":"GUARD","desc":"One fatal mistake leaves one HP. After that, the coat has no promises.","effects":{"max_hp":6.0,"coin_mult":-0.08},"fixed_signature":"last_lantern"},
	{"id":"marsh_promise","name":"Marsh Promise","slot":"Relic","icon":"LOCKET","desc":"Burn or poison wakes ward once per foe. Patient status builds keep their shelter.","effects":{"poison_duration":0.18},"fixed_signature":"bubble_bargain"},
	{"id":"receipt_ring","name":"Receipt Ring","slot":"Relic","icon":"RING","desc":"Defeated foes leave impact for the next. The ring expects you to keep moving.","effects":{"max_hp":-6.0},"fixed_signature":"grudgekeeper"},
	{"id":"safe_aperture","name":"Safe Aperture","slot":"Relic","icon":"LOCKET","desc":"Critical finishes store ward. A measured shot earns a safer next room.","effects":{"crit":0.05},"fixed_signature":"critical_shelter"},
	{"id":"coffer_key","name":"Coffer Key","slot":"Relic","icon":"RING","desc":"Cache openings prime the next hit; carrying its fortune also invites sharper blows.","effects":{"coin_mult":0.12,"incoming_mult":0.08},"fixed_signature":"mimic_appetite"},
	{"id":"threefold_ink","name":"Threefold Ink","slot":"Rune","icon":"SPARK","desc":"Three distinct targets make a lightning circuit. Solo duels need another plan.","effects":{},"fixed_signature":"storm_receipt"},
	{"id":"fault_script","name":"Fault Script","slot":"Rune","icon":"SLAM","desc":"Heavy hits echo to the same foe. Slow beats can tell the story twice.","effects":{},"fixed_signature":"aftershock_receipt"},
	{"id":"shelter_script","name":"Shelter Script","slot":"Rune","icon":"SPARK","desc":"Burn and poison wake ward. It rewards application, not an endless shield.","effects":{"fire_damage":0.10},"fixed_signature":"bubble_bargain"},
	{"id":"winter_clause","name":"Winter Clause","slot":"Rune","icon":"SPARK","desc":"First-hit chimes shatter under a heavy follow-up. Timing is the signature.","effects":{"heavy_bonus":0.08},"fixed_signature":"frostbell_shatter"}
]
const FARMS := {
	"act_i":{"material":"Promise Brass","items":["oath_slab","courier_pike","warden_warranty"]},
	"mossglass_wilds":{"material":"Rootglass","items":["root_splitter","marsh_promise","second_skin"]},
	"moonfen":{"material":"Moonthread","items":["moonstage_shivs","witness_bow","safe_aperture"]},
	"frostbell_hollows":{"material":"Chime Ice","items":["winter_clause","keeper_coat"]},
	"sunken_gearworks":{"material":"Coil Teeth","items":["coil_dispatch","rivet_fangs","fault_script"]},
	"cinder_crown":{"material":"Crown Ember","items":["bellows_maul","scarlet_margin","shelter_script"]},
	"starfall_archive":{"material":"Living Ink","items":["marginalia_staff","threefold_ink"]},
	"nullglass_expanse":{"material":"Nullglass","items":["debt_orbit","receipt_ring"]},
	"skyhook_bastion":{"material":"Skywire","items":["pilgrim_sling","hush_wand"]},
	"first_hoard":{"material":"First Gold","items":["coffer_key","oath_slab","keeper_coat"]}
}
const HUMANS := {
	"vault_runner":{"role":"Agile courier","affinity":"daggers / spear","mastery":"Doors Left Open","bio":"Compact routes taught her to travel light and carry heavy promises. She collects broken keys, not excuses."},
	"velvet_astrologer":{"role":"Precision arcanist","affinity":"bow / wand","mastery":"The Unwritten Star","bio":"A careful reader of unstable skies. Her forecasts name possibilities, never debts owed by the future."},
	"ruin_warden":{"role":"Heavy guardian","affinity":"greatsword / maul","mastery":"Nobody Left Behind","bio":"He stayed when the Crown's patrol withdrew. His coat remembers every person who made it home."},
	"ashtrail_hunter":{"role":"Relic-coil marksman","affinity":"crossbow / sling","mastery":"Tracks Through Ash","bio":"He follows ruined mechanisms like other hunters follow tracks. A good bolt is cheaper than a bad bargain."},
	"nightstage_drifter":{"role":"Close-range finisher","affinity":"daggers / claws","mastery":"One More Encore","bio":"The old stage is rubble. The audience is hostile. Leaving a memorable last line still matters."}
}
const TIERS := [
	{"name":"Trail","rank":1,"text":"Original region rules • all broad farm sources available"},
	{"name":"Hardened","rank":2,"text":"More regional elites • extra boss harvest • extra blueprint progress"},
	{"name":"Strange","rank":3,"text":"Regional elite pressure • faster foes • richer discoveries"}
]
static func home_for(item: String) -> String:
	for region in FARMS:
		if item in FARMS[region].items: return region
	return ""
