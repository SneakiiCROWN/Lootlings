extends RefCounted

# Presentation-only writing: no gameplay RNG, stats or reward changes.
const SPEAKERS := {"Salvager":"Patch Brasswick", "Archivist":"Ilex Quill", "Relic Keeper":"Sera Vey", "Mascot":"Lootling"}
const PREMISE := "The Crownfall scattered a civilisation's promises into Relic Cores. Lootlings woke around those fragments, small enough to enter the ruins and stubborn enough to bring their stories home. Treasure is useful. A forgotten promise can change the world."
const ORIGINS := {
	"relic_beast":"Found asleep in a courier's satchel after Crownfall. Curious and loyal; hates empty promises. Hunts treasure to return lost things, although snacks occasionally take priority.",
	"emberhorn":"Woke in a cold rescue furnace. Impatient, affectionate and terrified of letting others down. Collects useful metal to keep the Hideout warm; claims singed eyebrows prove good planning.",
	"mosskin":"Grew around a watchstone guarding an abandoned garden. Patient and quietly funny. Fears being too late to protect someone. Returns stolen relics to places that need them, not owners who hoard them.",
	"moonkip":"First appeared inside a locked bell tower. Proudly sneaky but unable to leave a friend behind. Collects keys and impossible locks. Calls every theft a temporary relocation.",
	"pebblewyrm":"Hatched from a quarry's discarded foundation Core. Cheerful, stubborn and afraid of deep water. Treasures well-made tools and carries everyone's bags without admitting that some are heavy.",
	"glimmerfin":"Woke when a drowned song reached the surface. Theatrical, generous and afraid of silence. Hunts relics that remember voices; announces victories as encores nobody requested.",
	"gloomlet":"Slipped out of a cracked shadow mirror. Dry, affectionate in secret and frightened of being forgotten. Collects things their owners stopped noticing. Denies every suspiciously helpful deed."
}
const NPC_NOTES := {
	"Patch Brasswick":"An adult travelling tinker who rebuilt the Hideout gate from salvage. Patch trusts Lootlings more than contracts. He sells repairs with dry humour, and keeps the old rescue furnace burning for Emberhorn.",
	"Ilex Quill":"An adult occult archivist from Starfall who fled before her name could be erased. Ilex treats Lootlings as witnesses, not curiosities. Her footnotes are precise; her jokes are not kind to tyrants.",
	"Sera Vey":"An adult relic scholar tending the crystal shrine. Sera left the Crown's scholars when they began pricing living Cores. Warm, practical and unafraid to tell ancient power to wait its turn."
}
const RESIDENT_REACTIONS := {
	"Salvager":{
		"relic_beast":"Empty the satchel before I weigh it. Snacks don't count.",
		"emberhorn":"Warm the forge, not my invoices.",
		"mosskin":"Your shield's growing leaves again. I charge for pruning.",
		"moonkip":"The keys stay on this side of the counter.",
		"pebblewyrm":"You dented the hammer? I'm almost impressed.",
		"glimmerfin":"No encores near the hot metal.",
		"gloomlet":"I saw that coin move. It wasn't the wind."
	},
	"Relic Keeper":{
		"relic_beast":"A brave Core. A suspicious number of crumbs.",
		"emberhorn":"Warmth is a gift. Burning the rug isn't.",
		"mosskin":"Even watchstones need a rest. Sit with me.",
		"moonkip":"The shrine is unlocked. You can stop looking pleased.",
		"pebblewyrm":"You don't have to carry everyone, little mountain.",
		"glimmerfin":"That old song belongs here. Sing softly.",
		"gloomlet":"I remember you. You needn't hide to stay."
	},
	"Archivist":{
		"relic_beast":"Your pawprints are now an official marginal note.",
		"emberhorn":"Ash is not an acceptable signature.",
		"mosskin":"The Archive appreciates your shade. Not your roots.",
		"moonkip":"Return the bookmark. It opens nothing. Usually.",
		"pebblewyrm":"The book was heavy. The shelf was heavier.",
		"glimmerfin":"An encore needs footnotes. Yours had twelve.",
		"gloomlet":"A blank page is not an erased name."
	}
}
const LOOTLINGS := {
	"relic_beast":["The chest sneezed. I sneezed back.", "My satchel has room. Emotionally, at least."],
	"emberhorn":["Bravery first. Singed eyebrows later.", "I warmed the treasure. You're welcome."],
	"mosskin":["Everyone behind me. Even the snacks.", "That lock needs patience. Or a very large shield."],
	"moonkip":["I borrowed the key before we needed it.", "Silent paws. Extremely loud treasure."],
	"pebblewyrm":["I can carry it. I didn't ask how big.", "The floor started it."],
	"glimmerfin":["A dramatic entrance costs nothing.", "The tide says shiny. I trust the tide."],
	"gloomlet":["No witnesses. Except that judgmental lamp.", "That coin was already following me."]
}
# Premise / midpoint / boss hook / victory / next-region hook.
const REGIONS := {
	"act_i":["Your Core remembers this road. Someone meant to come back.", "Fallen Crown. Working locks. The paperwork accepts swords.", "The Hoard Dragon stole promises. Dispute the inventory.", "The vault opens. Forgotten names see daylight again.", "Beyond the ruins, a jade pool holds the forest's lost spring."],
	"mossglass_wilds":["Roots claimed the Crown's treasure. Better landlords.", "Every leaf reflects a different sky. None of them is today's.", "The Mirror stole the spring. Downstream, nothing flowers.", "Water finds its old path. Something stolen gets to go home.", "Lanterns wait in Moonfen. Ilex has underlined 'wait'."],
	"moonfen":["Follow lanterns. Not all of them are friendly.", "The marsh keeps what the moon forgets.", "The Lantern Jackal knows your scent.", "The false lights go dark.", "A bell rings beneath the ice."],
	"frostbell_hollows":["A frozen warning still rings here.", "The ice holds unfinished songs.", "Belljaw has swallowed the last chime.", "For once, the silence is kind.", "Meltwater leads to the drowned machines."],
	"sunken_gearworks":["The shift bell rings. Nobody has answered in a century.", "Brass lungs breathe. Their makers' names have rusted away.", "The Engine has a vacancy. Its last worker is still chained.", "The shift ends. Leave the ledger open. They were owed more.", "Above the works, a furnace has awarded itself a crown."],
	"cinder_crown":["The furnace has crowned a new tyrant.", "Every tribute feeds the fire.", "The Furnace Regent accepts no refunds.", "The crown cools. The debts remain.", "A star has fallen into the Archive."],
	"starfall_archive":["Someone has been editing the stars.", "The shelves remember the missing names.", "The Redactor would erase your ending.", "Your name stays on the page.", "The missing pages reflect another world."],
	"nullglass_expanse":["Your reflection arrives a step too late.", "Don't follow the version that smiles first.", "The Unchosen wears abandoned futures.", "One reflection walks home.", "Above the glass, chains catch the sky."],
	"skyhook_bastion":["The last sky-road hangs by a chain.", "The wind carries unpaid tolls.", "The Chainwarden has locked the horizon.", "The sky-road opens again.", "All roads led to the First Hoard."],
	"first_hoard":["The first treasure was a promise, not a coin.", "Every Core remembers this light.", "The Hollow Crown still demands everything.", "A promise recovered. Not a world repaired.", "Something beyond the vault heard you."]
}

static func region_line(id: String, index: int) -> String:
	return str(REGIONS.get(id, REGIONS.act_i)[clampi(index, 0, 4)])

static func mascot_line(id: String, index: int) -> String:
	return str(LOOTLINGS.get(id, LOOTLINGS.relic_beast)[posmod(index, 2)])
