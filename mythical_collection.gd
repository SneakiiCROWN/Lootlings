extends RefCounted
# Magical shields use the existing Charm slot; both hands remain free.
const IDS=["dawnweave", "tidestar", "aurora_thread", "prismsong", "hearthpearl", "mirrorwake", "bloomward", "starfold"]
const ITEMS=[
 {
  "id": "dawnweave",
  "name": "Dawnweave",
  "slot": "Weapon",
  "family": "VANGUARD",
  "weapon_type": "greatsword",
  "icon": "BLADE",
  "desc": "A first sunrise woven into a blade. Heavy hits echo after impact.",
  "effects": {
   "damage_mult": 0.12
  },
  "fixed_signature": "aftershock_receipt"
 },
 {
  "id": "tidestar",
  "name": "Tidestar",
  "slot": "Weapon",
  "family": "VANGUARD",
  "weapon_type": "spear",
  "icon": "BLADE",
  "desc": "A star rescued from the moon tide. Opening hits delay each foe.",
  "effects": {
   "boss_damage": 0.12
  },
  "fixed_signature": "frostbell_chime"
 },
 {
  "id": "aurora_thread",
  "name": "Aurora Thread",
  "slot": "Weapon",
  "family": "RANGER",
  "weapon_type": "bow",
  "icon": "BOW",
  "desc": "Its bowstring carries the northern lights. Every fifth shot arcs lightning.",
  "effects": {
   "crit": 0.045
  },
  "fixed_signature": "crooked_constellation",
  "projectile": "arrow"
 },
 {
  "id": "prismsong",
  "name": "Prismsong",
  "slot": "Weapon",
  "family": "MAGE",
  "weapon_type": "staff",
  "icon": "STAFF",
  "desc": "Eight colours sing one promise. The first critical hit on each foe calls a spark.",
  "effects": {
   "attack_speed": 0.06
  },
  "fixed_signature": "first_light",
  "projectile": "magic_orb"
 },
 {
  "id": "hearthpearl",
  "name": "Hearthpearl",
  "slot": "Relic",
  "icon": "GUARD",
  "desc": "Floating magical shield - Charm slot; hands stay free. Once per run, survive fatal damage at 1 HP. A keepsake of every welcoming hearth.",
  "effects": {
   "max_hp": 12
  },
  "fixed_signature": "last_lantern"
 },
 {
  "id": "mirrorwake",
  "name": "Mirrorwake",
  "slot": "Relic",
  "icon": "GUARD",
  "desc": "Floating magical shield - Charm slot; hands stay free. Critical kills restore 4 Ward (cap 15). The tide remembers your brightest strikes.",
  "effects": {
   "armor": 0.03
  },
  "fixed_signature": "critical_shelter"
 },
 {
  "id": "bloomward",
  "name": "Bloomward",
  "slot": "Relic",
  "icon": "GUARD",
  "desc": "Floating magical shield - Charm slot; hands stay free. First burn or poison on each foe grants 3 Ward (cap 15). Kindness grows fierce roots.",
  "effects": {
   "poison_duration": 0.12
  },
  "fixed_signature": "bubble_bargain"
 },
 {
  "id": "starfold",
  "name": "Starfold",
  "slot": "Relic",
  "icon": "GUARD",
  "desc": "Floating magical shield - Charm slot; hands stay free. A defeated foe banks power for the next encounter. Folded starlight keeps a patient grudge.",
  "effects": {
   "boss_damage": 0.08
  },
  "fixed_signature": "grudgekeeper"
 }
]
const GRIPS={"dawnweave":Vector2(.50,.85),"tidestar":Vector2(.50,.81),"aurora_thread":Vector2(.60,.50),"prismsong":Vector2(.51,.72)}
const SOCKETS={"dawnweave":Vector2(.50,.04),"tidestar":Vector2(.50,.06),"aurora_thread":Vector2(.14,.50),"prismsong":Vector2(.51,.17)}
static var cache:Dictionary={}
static func texture(id: String) -> Texture2D:
 if not id in IDS:return null
 if not cache.has(id):cache[id]=load("res://art/production/phase4e/items/mythical_050/%s.png" % id)
 return cache[id]
static func is_shield(id: String) -> bool:return id in IDS.slice(4)
