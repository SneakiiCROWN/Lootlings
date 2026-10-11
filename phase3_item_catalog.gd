extends RefCounted

# Named variants reuse canonical category/weapon art. No invented final art.
# Signature hooks are explicit and inspectable, never implied by flavour.
const ITEMS := [
	{"id":"thorn_receipt","name":"Thorn Receipt","slot":"Armour","icon":"GUARD","desc":"The fourth hit you survive earns a thorn in reply.","effects":{"max_hp":20.0},"fixed_signature":"rooted_revenge"},
	{"id":"promise_bubble","name":"Promise Bubble","slot":"Relic","icon":"LOCKET","desc":"The first burn or poison on each foe grants 3 ward. Ward holds at most 15.","effects":{},"fixed_signature":"bubble_bargain"},
	{"id":"echo_invoice","name":"Echo Invoice","slot":"Rune","icon":"SLAM","desc":"Heavy hits return 25% base power after a short beat. The echo stays with its target.","effects":{},"fixed_signature":"aftershock_receipt"},
	{"id":"courier_appetite","name":"Courier's Appetite","slot":"Relic","icon":"RING","desc":"Opening a courier cache primes the next hit for +40% power. Does not stack.","effects":{},"fixed_signature":"mimic_appetite"},
	{"id":"storm_ledger","name":"Storm Ledger","slot":"Rune","icon":"SPARK","desc":"Hit three different foes within 4 seconds to spark the third for 60% base power.","effects":{},"fixed_signature":"storm_receipt"},
	{"id":"frostbell_seal","name":"Frostbell Seal","slot":"Rune","icon":"SPARK","desc":"The first hit delays each foe. A heavy follow-up shatters the chime for 25% base power.","effects":{},"fixed_signature":"frostbell_shatter"},
	{"id":"gilded_debt","name":"Gilded Debt","slot":"Relic","icon":"RING","desc":"Bonus expedition XP and stronger hits. Incoming damage rises 15%. Read the terms.","effects":{"coin_mult":0.35,"damage_mult":0.18,"incoming_mult":0.15}},
	{"id":"burden_bell","name":"Burden Bell","slot":"Weapon","family":"VANGUARD","weapon_type":"maul","icon":"MALLET","desc":"A slow bell-maul. Every heavy hit delays its target by 0.25s.","effects":{"damage_mult":0.28,"attack_slow":0.25},"fixed_signature":"burden_bell"},
	{"id":"lanternstring","name":"Lanternstring","slot":"Weapon","family":"RANGER","weapon_type":"bow","projectile":"arrow","icon":"BOW","desc":"Each foe's first critical hit calls a spark. Fast shots, no free shelter.","effects":{"attack_speed":0.08},"fixed_signature":"first_light"},
	{"id":"returning_thorn","name":"Returning Thorn","slot":"Weapon","family":"MAGE","weapon_type":"staff","projectile":"magic_orb","icon":"STAFF","desc":"A staff that remembers rough treatment. Every fourth hit taken answers with a thorn.","effects":{"max_hp":10.0,"poison_duration":0.20},"fixed_signature":"rooted_revenge"},
	{"id":"last_page","name":"Last Page","slot":"Armour","icon":"GUARD","desc":"Once per run, fatal damage leaves one HP. A narrow margin, not an extra life.","effects":{"max_hp":12.0},"fixed_signature":"last_lantern"},
	{"id":"quiet_chime","name":"Quiet Chime","slot":"Relic","icon":"LOCKET","desc":"Each critical kill restores 4 ward, up to 15. Finish cleanly; carry the shelter.","effects":{"crit":0.03},"fixed_signature":"critical_shelter"},
]

const BOSS_ONLY := ["storm_ledger","frostbell_seal","last_page","lanternstring"]

const BOSS_POOLS := {
	"act_i":["burden_bell","courier_appetite","gilded_debt"],
	"mossglass_wilds":["thorn_receipt","returning_thorn","promise_bubble"],
	"moonfen":["lanternstring","quiet_chime","last_page"],
	"frostbell_hollows":["frostbell_seal","quiet_chime","promise_bubble"],
	"sunken_gearworks":["storm_ledger","echo_invoice","burden_bell"],
	"cinder_crown":["burden_bell","gilded_debt","echo_invoice"],
	"starfall_archive":["last_page","storm_ledger","echo_invoice"],
	"nullglass_expanse":["promise_bubble","gilded_debt","quiet_chime"],
	"skyhook_bastion":["lanternstring","storm_ledger","courier_appetite"],
	"first_hoard":["gilded_debt","last_page","courier_appetite"],
}
