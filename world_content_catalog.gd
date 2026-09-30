extends RefCounted

# Replacement-ready metadata. Only Act I zones are runtime-live today.
const FUTURE_ZONES := {
	"mossglass_wilds":{"name":"MOSSGLASS WILDS", "act":"II", "status":"ASSET_NEEDED", "palette":"jade / glass cyan / soft gold", "enemies":["Mossmaw", "Glasswing", "Rootshell", "Dew Hexer", "Mirror Pup"], "boss":"The Verdant Mirror", "loot":"guard / poison / reflect"},
	"moonfen":{"name":"MOONFEN CANOPY", "act":"II", "status":"ASSET_NEEDED", "palette":"indigo / cyan / silver", "enemies":["Fen Sneak", "Lantern Toad", "Bog Archer", "Mudcloak", "Moonmoth"], "boss":"Lantern Jackal", "loot":"crit / movement / ranged"},
	"frostbell_hollows":{"name":"FROSTBELL HOLLOWS", "act":"II", "status":"ASSET_NEEDED", "palette":"ice blue / white / navy", "enemies":["Bell Bat", "Rime Pup", "Frostshell", "Icicle Imp", "Snowbound Hexer"], "boss":"The Belljaw", "loot":"frost / shield / precision"},
	"sunken_gearworks":{"name":"SUNKEN GEARWORKS", "act":"III", "status":"ASSET_NEEDED", "palette":"oxidized teal / brass / navy", "enemies":["Sluice Crab", "Pressure Sprite", "Gear Eel", "Brassback", "Valve Witch"], "boss":"The Drowned Engine", "loot":"lightning / utility / projectile"},
	"cinder_crown":{"name":"CINDER CROWN CALDERA", "act":"III", "status":"ASSET_NEEDED", "palette":"black / ember red / brass", "enemies":["Coal Pup", "Slag Knight", "Ember Wisp", "Forge Beetle", "Crown Caster"], "boss":"The Furnace Regent", "loot":"fire / heavy / armour"},
	"starfall_archive":{"name":"STARFALL ARCHIVE", "act":"IV", "status":"ASSET_NEEDED", "palette":"midnight / parchment / star gold", "enemies":["Inkling", "Margin Imp", "Glyph Knight", "Pagewyrm", "Index Witch"], "boss":"The Redactor", "loot":"spell / knowledge / reroll"},
	"nullglass_expanse":{"name":"NULLGLASS EXPANSE", "act":"IV", "status":"ASSET_NEEDED", "palette":"black glass / violet / cyan", "enemies":["Null Hound", "Echo Imp", "Glass Stalker", "Mirror Knight", "Blank Caster"], "boss":"The Unchosen", "loot":"void / echo / risk-reward"},
	"skyhook_bastion":{"name":"SKYHOOK BASTION", "act":"V", "status":"ASSET_NEEDED", "palette":"sky / white / brass", "enemies":["Hookwing", "Chain Guard", "Storm Pup", "Deck Hexer", "Sky Rat"], "boss":"The Chainwarden", "loot":"lightning / ranged / speed"},
	"first_hoard":{"name":"THE FIRST HOARD", "act":"ENDGAME", "status":"FUTURE", "palette":"obsidian / ancient gold / white Core", "enemies":["First Guard", "Crown Shard", "Vault Apostle", "Hoard Echo", "Core Warden"], "boss":"The Hollow Crown", "loot":"endgame signatures / evolved weapons"}
}

const ENCOUNTER_ARCHETYPES := {
	"solo_duelist":{"members":1, "status":"LIVE", "purpose":"readable low-noise variant showcase"},
	"heavy_solo":{"members":1, "status":"LIVE", "purpose":"impact and tempo check"},
	"skirmisher_duo":{"members":2, "status":"DEFINED_DATA", "purpose":"target handoff pressure"},
	"guard_caster":{"members":2, "status":"DEFINED_DATA", "purpose":"priority target choice"},
	"scraprat_pack":{"members":3, "status":"DEFINED_DATA", "purpose":"bounded AoE satisfaction"},
	"treasure_escape":{"members":1, "status":"DEFINED_DATA", "purpose":"optional reward chase"},
	"mimic_room":{"members":1, "status":"DEFINED_DATA", "purpose":"chest risk/reward surprise"},
	"elite_guard":{"members":2, "status":"DEFINED_DATA", "purpose":"late-run tactical spike"}
}
