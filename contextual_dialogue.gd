extends RefCounted
# Presentation-only facts/history. Never draws from gameplay RNG.
const GREETINGS := {
	"Salvager":["Bring the weapon over. I'll check the edge before we change anything.","A good grip matters more than a bright finish. Let's see what you're carrying."],
	"Relic Keeper":["Put your pack down. Nothing here needs to be earned twice.","The shrine is ready when you are. There is no hurry at home."],
	"Archivist":["Tell me who you met. Places keep their names when someone remembers.","I've kept your place in the record. Start with what you actually saw."]
}
const PERSONALITY := {
	"vault_runner":"One safe way out. Two profitable ways in. I'll take a look.",
	"ruin_warden":"We go together. We come home together.",
	"nightstage_drifter":"Clean boots, sharp steel. Let's make an entrance worth leaving.",
	"velvet_astrologer":"A promising alignment. Naturally, I've brought a contingency.",
	"ashtrail_hunter":"Fresh tracks past the gate. We leave before the wind turns."
}
const LINES := [
	{"speaker":"Salvager","event":"forge_evolved","text":"The balance has changed. Give the new movement room on your next trip."},
	{"speaker":"Salvager","event":"early_defeat","text":"You came back. That's the part I can't replace. We'll check your gear next."},
	{"speaker":"Salvager","event":"legendary_find","text":"That edge was made for a particular job. Read its effect before you trade away your old weapon."},
	{"speaker":"Relic Keeper","event":"early_defeat","text":"Rest first. A living Core is worth more than the treasure left behind."},
	{"speaker":"Relic Keeper","event":"victory","text":"You returned with something the Crown couldn't keep. We'll give it a home."},
	{"speaker":"Archivist","event":"boss_defeated","text":"The guardian is gone. Tell me its name before we count the spoils."},
	{"speaker":"Archivist","event":"signature_find","text":"A named relic carries a witness. I'll record yours beside it."},
	{"speaker":"Archivist","event":"contract_complete","text":"The work is recorded. Your reward is waiting at the board."},
	{"speaker":"Archivist","mode":"siege","outcome":"victory","text":"You chose a way home from the Siege. The highest round is recorded; the choice is yours."},
	{"speaker":"Relic Keeper","mode":"dungeon","outcome":"victory","text":"Another Crownroot from the Vault. Small returns can restore something whole."},
	{"speaker":"Salvager","weapon":"bow","text":"I'll check the string and grip. A bow should pull cleanly, not fight its bearer."},
	{"speaker":"Salvager","weapon":"crossbow","text":"Let me inspect the catch before you head out. Keep the bolt clear of the mechanism."}
	,{"speaker":"Salvager","activity":"working","text":"I'm dressing an old edge. Leave your weapon on the bench; I'll check its balance next."}
	,{"speaker":"Archivist","activity":"reading","text":"This account names the people who built the vault. I'd like your next journey to add a witness."}
	,{"speaker":"Relic Keeper","activity":"inspecting","text":"I'm checking the shrine bindings. Your Core can rest here while I finish."}
]
var recent: Array[String]=[]
var visits: Dictionary={}
func choose(speaker: String, facts: Dictionary) -> String:
	var candidates: Array[String]=[]; var best: int=-1
	for entry in LINES:
		if entry.speaker!=speaker: continue
		var matches:=true; var score:=0
		for key in entry:
			if key in ["speaker","text"]: continue
			if str(facts.get(key,""))!=str(entry[key]): matches=false; break
			score+=2 if key in ["event","outcome"] else 1
		if not matches: continue
		if score>best: best=score; candidates.clear()
		if score==best: candidates.append(entry.text)
	if candidates.is_empty(): candidates.assign(GREETINGS.get(speaker,["The gate is waiting."]))
	var index: int=int(visits.get(speaker,0)); visits[speaker]=index+1
	var line: String=candidates[index%candidates.size()]
	for candidate in candidates:
		if not candidate in recent: line=candidate; break
	recent.append(line)
	if recent.size()>6: recent.pop_front()
	return line
