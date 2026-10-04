extends RefCounted
# Presentation-only facts/history. Never draws from gameplay RNG.
const GREETINGS := {
	"Salvager":["Set it on the bench. If the grip slips, the shine won't save you.","Warm fire, sound hinges, sharp steel. That's a home worth keeping."],
	"Relic Keeper":["Put your pack down. You don't have to be useful every waking moment.","I'll tend the shrine. You tend the bruises. Neither job needs a hero."],
	"Archivist":["Tell me who you met. Ruins are full of people reduced to architecture.","The dead rarely correct my spelling. I try not to take advantage."],
	"vault_runner":["Count the exits before the coins. Then you get to spend them.","That door sticks. A useful fact when someone is chasing you."],
	"ruin_warden":["Eat while it's warm. I'll take the first watch.","Check the straps. A loose buckle shouldn't decide who comes home."],
	"nightstage_drifter":["Stay close. I like an audience that makes it home.","You kept me a seat? Careful. I'll start coming back for more than treasure."],
	"velvet_astrologer":["An uncertain sky is no excuse for an unprepared departure.","I trust the calculations. I still check the bowstring."],
	"ashtrail_hunter":["Three fresh tracks by the gate. One limps.","Wind's turning. We should leave before it carries our scent."]
}
const PERSONALITY := {
	"vault_runner":"Exit first. Treasure second. That's how you get to spend it.",
	"ruin_warden":"Keep behind my shoulder. Nobody gets left at the gate.",
	"nightstage_drifter":"Stay close. I like an audience that makes it home.",
	"velvet_astrologer":"The pattern is clear. The risk isn't. I brought a contingency.",
	"ashtrail_hunter":"Fresh tracks. One limps. We leave before the wind turns."
}
const LINES := [
	{"speaker":"Salvager","event":"forge_evolved","text":"The balance has changed. Give the new movement room on your next trip."},
	{"speaker":"Salvager","event":"early_defeat","text":"You came back. That's the part I can't replace. We'll check your gear next."},
	{"speaker":"Salvager","event":"legendary_find","text":"Fine edge. Unusual balance. Keep the old weapon until you know what this one asks of you."},
	{"speaker":"Relic Keeper","event":"early_defeat","text":"Rest first. A living Core is worth more than the treasure left behind."},
	{"speaker":"Relic Keeper","event":"victory","text":"You returned with something the Crown couldn't keep. We'll give it a home."},
	{"speaker":"Archivist","event":"boss_defeated","text":"The guardian is gone. Tell me its name before we count the spoils."},
	{"speaker":"Archivist","event":"signature_find","text":"A named relic carries a witness. I'll record yours beside it."},
	{"speaker":"Archivist","event":"contract_complete","text":"The board owes you a reward. Collect it before generosity becomes a historical footnote."},
	{"speaker":"Archivist","mode":"siege","outcome":"victory","text":"You left the Siege alive. A satisfying ending. The Crown prefers its stories unfinished."},
	{"speaker":"Relic Keeper","mode":"dungeon","outcome":"victory","text":"Another Crownroot from the Vault. Small returns can restore something whole."},
	{"speaker":"Salvager","weapon":"bow","text":"I'll check the string and grip. A bow should pull cleanly, not fight its bearer."},
	{"speaker":"Salvager","weapon":"crossbow","text":"Let me inspect the catch before you head out. Keep the bolt clear of the mechanism."}
	,{"speaker":"Salvager","activity":"working","text":"An old edge, made sound again. Leave yours on the bench; I'll check its balance."}
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
