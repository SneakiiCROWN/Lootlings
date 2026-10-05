"""Build the authored dialogue bank. UTF-8; presentation only, no game RNG."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
greetings='const GREETINGS := '+json.dumps({
 'Salvager':['Set it on the bench. If the grip slips, the shine will not save you.','Warm fire, sound hinges, sharp steel. That is a home worth keeping.'],
 'Relic Keeper':['Put your pack down. You do not have to be useful every waking moment.','I will tend the shrine. You tend the bruises. Neither job needs a hero.'],
 'Archivist':['Tell me who you met. Ruins are full of people reduced to architecture.','The dead rarely correct my spelling. I try not to take advantage.']},ensure_ascii=False)+'\n'
voices={
 'relic_beast':['I brought the lost buckle back. Also this shiny thing. Also three snacks.','You stayed beside me in there. Next time I carry your bag.','Is that chest friendly? I can offer it a biscuit.'],
 'emberhorn':['I can take the next watch. Nobody goes cold while I am here.','Yes, I rushed the door. No, I will not rush the next one. Probably.','Patch kept the rescue furnace burning. I want to be that reliable.'],
 'mosskin':['Sit in my shade. The garden can wait a little longer.','I kept the way home clear. A shield is useful after the fight, too.','The roots broke the lock. Very slowly. I admire their method.'],
 'moonkip':['I checked both exits. The treasure can wait until you are through.','That lock was insulting. I accepted the challenge politely.','I returned the key. Nobody specified which pocket.'],
 'pebblewyrm':['Put the heavy bag on mine. We will complain together on the way home.','The bridge held! I knew it would. I did check twice.','My Core came from a foundation stone. Staying put is a family talent.'],
 'glimmerfin':['You came back! Excellent. The welcome deserves at least one chorus.','I found a shell that remembers a voice. Let us listen before we sell it.','The shrine was quiet today. I sang softly. That still counts as restraint.'],
 'gloomlet':['Your bag strap was broken. It is fixed now. No public ceremony, please.','I kept your seat. For tactical reasons.','Yes, I came back for you. Let us never discuss this in front of the others.'],
 'vault_runner':['A rich vault with one exit is a trap with expensive wallpaper.','I marked the way back. Getting paid requires getting out.'],
 'ruin_warden':['Drink something warm. I will watch the gate.','We count people before treasure. Every time.'],
 'nightstage_drifter':['An encore is only worth it if the whole audience survives.','You kept a seat for me. That is a better welcome than applause.'],
 'velvet_astrologer':['The sky gives probabilities. I bring a spare string.','I checked the route twice. Confidence should have a foundation.'],
 'ashtrail_hunter':['Fresh tracks outside the gate. Two feet, then four. Watch the bends.','The wind has changed. Leave after it carries our scent away.']}
entries=[]
def line(speaker,text,category='context',**conditions):
 entries.append(dict(speaker=speaker,text=text,category=category,**conditions))
for who,lines in voices.items():
 for text in lines: line(who,text,'banter')
 for outcome,text in [('victory',{'relic_beast':'We brought everyone home! Can we count treasure after supper?','emberhorn':'Everyone made it. Good. That was the part I was worried about.','mosskin':'The path is safe again. Rest now; I will take the watch.','moonkip':'Nobody saw us leave. Everybody who matters came with us.','pebblewyrm':'Still standing! I told you these legs were dependable.','glimmerfin':'A fine ending! Save the applause until the wounded have seats.','gloomlet':'Everyone survived. An acceptable result. Stop smiling at me.'}.get(who,'We made it back together. Keep that habit.')),
                      ('defeat',{'relic_beast':'I left the treasure. I did not leave you.','emberhorn':'I went too fast. Next time I watch the opening before I charge.','mosskin':'A retreat is a path home. We can grow stronger here.','moonkip':'The exit worked. Next time we avoid needing it quite so urgently.','pebblewyrm':'I can try again. After a sit. A very determined sit.','glimmerfin':'That performance needs rehearsal. Nobody is being replaced.','gloomlet':'You came back for me. Reckless. Appreciated. Do not quote that.'}.get(who,'We have another chance because we came home.'))]:
  line(who,text,outcome=outcome)
bank={
 'Salvager':{
 'banter':['I rebuilt this gate from salvage. Good work should outlast its first owner.','Sera checks the Core. I check what protects it. Neither of us signs off on guesswork.','Ilex found the original furnace plans. Finally, instructions that fit the machine.'],
 'returning':['Back on your feet? Put the weapon down and tell me where it caught.','You kept the grip steady through a long run. Now let me check the binding.'],
 'early_defeat':['You came back. That is the part I cannot replace. We will check your gear next.','Do not buy another weapon yet. Tell me what broke your rhythm first.'],
 'shop_purchase':['Try the grip here before taking it into a fight. Keep the receipt until it fits.'],
 'forge_evolved':['The new balance is deliberate. Give that movement room on your next trip.'],
 'new_weapon':['Different reach, different opening. Take one clean swing before you trust it.'],
 'legendary_find':['Fine edge. Unusual balance. Keep the old weapon until you learn this one.'],
 'signature_find':['That is a named relic. I will inspect the fittings; Ilex will want its history.'],
 'red_find':['A Crownroot relic. No rushing this inspection. Power still needs a sound grip.'],
 'easter':['A suspiciously generous chest? Inspect the hinge before congratulating yourself.','A room full of healing supplies and an empty circle. I would sharpen something.']},
 'Relic Keeper':{
 'banter':['Cores remember what they were asked to protect. Treating them as spare fuel destroys that purpose.','Patch keeps the furnace warm for Emberhorn. Care is often less dramatic than people expect.','A Core can remember a promise without knowing who made it. We help it find the rest.'],
 'returning':['Put your pack down. A long road does not make rest optional.'],
 'early_defeat':['Rest first. A living Core matters more than the treasure left behind.'],
 'shrine_upgrade':['The shrine can support you more steadily now. It does not ask you to prove anything.'],
 'legendary_find':['Let the relic settle before you bind it. Strength is useful; consent matters too.'],
 'red_find':['Crownroot joins the fragments left by the Crownfall. We will tend what wakes inside it.'],
 'easter':['If you are saving every tonic for an emergency, tell me what you call the last fight.']},
 'Archivist':{
 'banter':['Starfall erased names before it erased people. I left while mine still belonged to me.','Record what you saw, including what you could not identify. Certainty can wait for evidence.','Patch repairs what remains. I record who it belonged to. We need both.'],
 'returning':['Tell me where you went. A map gains value from a witness who returned.'],
 'early_defeat':['We have a surviving witness. Start with the attack you did not recognize.'],
 'signature_find':['A named relic has a history. Your discovery belongs beside its old owners.'],
 'contract_complete':['Collect the board reward. You did the work; the promise should be kept.'],
 'boss_defeated':['The guardian fell. Tell me what changed around it before we count the spoils.'],
 'easter':['That immaculate empty hall? Architects rarely install a grand entrance for a broom cupboard.','Another sealed room behind a cracked wall. The builders were less subtle than they thought.']}}
for speaker,groups in bank.items():
 for event,lines in groups.items():
  for text in lines:
   if event=='banter': line(speaker,text,'banter')
   elif event=='easter': line(speaker,text,'easter',flag='easter_egg')
   else: line(speaker,text,event=event)
for speaker,text in [('Salvager','Sound footing and a clean opening. Keep doing what brought you home.'),('Relic Keeper','You returned alive and freed something the Crown had kept. Let us tend both.'),('Archivist','A victory with a witness. That is considerably better than a heroic rumour.')]: line(speaker,text,outcome='victory')
for speaker,text in [('Salvager','The weapon is repairable. You need a rest before another run.'),('Relic Keeper','You survived. Let the shrine hold some of the weight tonight.'),('Archivist','Tell me how the fight turned. A defeat can still leave a useful account.')]: line(speaker,text,outcome='defeat')
for weapon,text in {
 'bow':'I will check the string and grip. The draw should pull cleanly, not fight you.',
 'crossbow':'Keep the bolt clear while I inspect the catch. A stiff trigger wastes your opening.',
 'daggers':'Two blades, two hands. Recover one while the other makes its opening.',
 'claws':'Check each fastening. A claw that turns in your palm is working for the other side.',
 'staff':'Let the charge finish before the release. Your footing matters as much as the spell.',
 'greatsword':'Use the reach. If the blade drags you forward, reset your stance.',
 'maul':'Let the head carry the blow. Then bring it home before the counterattack.',
 'spear':'Keep the point between you and the threat. Recover straight after the thrust.',
 'sling':'A clear arc, then a clean release. Check behind you before you start the rotation.',
 'greataxe':'Commit to the cut, then recover your footing. Weight is useful when you control it.',
 'wand':'Small movement, precise aim. Keep the focus steady through the release.',
 'orb':'Do not squeeze the focus. Give its charge room and guide the release.'}.items(): line('Salvager',text,'gameplay',weapon=weapon,flag='weapon_comment')
line('Archivist','The Verdant Mirror diverted the forest spring. If it fell, we should check whether water reaches the gardens again.',region='mossglass_wilds',outcome='victory',flag='boss_memory')
line('Relic Keeper','The Mirror held stolen spring water in its roots. Breaking its hold helps living things downstream.',region='mossglass_wilds',event='boss_defeated')
line('Archivist','Moonfen lanterns lure travellers off the path. Record which lights moved before the attack.', 'gameplay',region='moonfen')
line('Archivist','Those Gearworks machines kept working after their makers died. We should find who was chained to the engine.', 'gameplay',region='sunken_gearworks')
line('Archivist','The Archive Redactor erases names from records. I survived by leaving Starfall before mine vanished.', 'gameplay',region='starfall_archive')
line('Relic Keeper','You escaped with little strength left. Sit by the shrine before deciding what comes next.',low_health='yes')
line('Archivist','You cleared the Rootglass Vault. Bring the Crownroot to Sera before we catalogue it.',mode='dungeon',outcome='victory')
line('Salvager','You extracted from the Siege. Empty the bag before the next fight; I want to see what survived.',mode='siege',outcome='victory')
line('Archivist','The Crownfall left living Cores inside abandoned work. A relic may remember its maker even when our books do not.','secret',event='archive_discovery',flag='rare_lore')
line('Relic Keeper','A rediscovered name can help a Core recognize an old bond. Bring the Archive account to the shrine.','secret',event='secret_discovered',flag='secret_hint')
line('Archivist','Some witnesses were erased twice: first from the records, then from the stories told about them. Compare the two accounts.','secret',event='signature_find',flag='rare_lore')
for who,lines in {
 'Salvager':['Leave the satchel here, little courier. I will mend it while you eat.','You do not have to rescue everyone alone, Emberhorn. That is why we keep a gate.','The garden can spare you for supper, Mosskin. I checked.','Moonkip, tell me which lock failed. I want to repair it before you prove your point again.','Pebblewyrm, put the bags down. Being dependable includes letting me carry one.','Glimmerfin, save the chorus for supper. I need to hear whether this blade rings true.','Gloomlet, I left the spare binding beside your seat. No announcement required.'],
 'Relic Keeper':['Your Core brightens near the return-gate. You know when someone is coming home.','The rescue furnace promised shelter. You are allowed to receive that warmth too.','A watchstone cannot protect its garden by wearing itself out. Rest with us.','You found the way out, Moonkip. That matters more than what stayed in the chest.','Put the burden down, Pebblewyrm. We will still depend on you tomorrow.','The shell remembers a voice. Let it finish before you answer with a song.','Your place here does not depend on being noticed, Gloomlet. I kept it for you.'],
 'Archivist':['Courier satchels carried promised returns. Yours may help us trace an old route.','I found a furnace record naming the workers who promised shelter. You would like them.','Your watchstone guarded a garden. Tell me what still grows there.','A locked bell tower with no sign of entry. Moonkip, I would value an honest account.','Foundation Cores supported ordinary homes. Those histories deserve names too.','We can record the drowned song together. I will not ask you to keep quiet for the whole day.','You brought back an overlooked keepsake. I will record its owner, not the rescuer.']}.items():
 for character,text in zip(['relic_beast','emberhorn','mosskin','moonkip','pebblewyrm','glimmerfin','gloomlet'],lines): line(who,text,'banter',character=character)
logic='''
var recent: Array[String]=[]
var visits: Dictionary={}
var rare_ready: Dictionary={}
var rng:=RandomNumberGenerator.new()
var last_selection: Dictionary={}
var calls:=0

func _init() -> void:
\trng.randomize()

func choose(speaker: String, facts: Dictionary) -> String:
\tcalls+=1
\tvar visit: int=int(visits.get(speaker,0)); visits[speaker]=visit+1
\tvar buckets: Dictionary={}
\tvar clock: float=Time.get_ticks_msec()/1000.0
\tfor entry in LINES:
\t\tif entry.speaker!=speaker or entry.text in recent: continue
\t\tvar matches:=true
\t\tfor key in entry:
\t\t\tif key in ["speaker","text","category","flag"]: continue
\t\t\tif str(facts.get(key,""))!=str(entry[key]): matches=false; break
\t\tif not matches: continue
\t\tvar category: String=entry.category
\t\tif category in ["easter","secret"]:
\t\t\tvar ready: Dictionary=rare_ready.get(category,{})
\t\t\tif clock<float(ready.get("time",0)) or calls<int(ready.get("call",0)): continue
\t\tif not buckets.has(category): buckets[category]=[]
\t\tbuckets[category].append(entry)
\t# Greetings are everyday lines, never an unrelated origin-story fallback.
\tif not buckets.has("banter"): buckets.banter=[]
\tfor text in GREETINGS.get(speaker,[]):
\t\tif not text in recent: buckets.banter.append({"speaker":speaker,"text":text,"category":"banter"})
\tvar category_weights: Dictionary={"context":50,"banter":25,"gameplay":15,"easter":7,"secret":3}
\tvar total:=0.0
\tfor category in buckets:
\t\tif not buckets[category].is_empty(): total+=float(category_weights[category])
\tif total<=0:
\t\t# Exhaustion frees only this voice's oldest entry, preserving no immediate repeats.
\t\tif recent.size()>1: recent.pop_front(); return choose(speaker,facts)
\t\treturn "The gate is open. Come back safely."
\tvar roll: float=rng.randf()*total
\tvar chosen_category: String="banter"
\tfor category in buckets:
\t\tif buckets[category].is_empty(): continue
\t\troll-=float(category_weights[category])
\t\tif roll<=0: chosen_category=category; break
\tvar candidates: Array=buckets[chosen_category]
\tif chosen_category=="context":
\t\tvar specificity:=0
\t\tfor entry in candidates:
\t\t\tspecificity=maxi(specificity,entry.size()-4 if entry.has("flag") else entry.size()-3)
\t\tcandidates=candidates.filter(func(entry): return (entry.size()-4 if entry.has("flag") else entry.size()-3)==specificity)
\t# First meeting starts grounded; later taps use the eligible weighted mix.
\tif visit==0 and str(facts.get("event",""))=="" and not buckets.banter.is_empty(): candidates=buckets.banter
\tvar selected: Dictionary=candidates[rng.randi_range(0,candidates.size()-1)]
\tlast_selection=selected.duplicate(true)
\tvar line: String=selected.text
\trecent.append(line)
\tif recent.size()>12: recent.pop_front()
\tif selected.category in ["easter","secret"]:
\t\trare_ready[selected.category]={"time":clock+(1200 if selected.category=="easter" else 1800),"call":calls+(24 if selected.category=="easter" else 40)}
\treturn line
'''
(root/'contextual_dialogue.gd').write_text('extends RefCounted\n# Independent presentation RNG. Eligible categories only; no reward/save mutation.\nconst PERSONALITY := '+json.dumps({k:v[0] for k,v in voices.items() if k in ['vault_runner','ruin_warden','nightstage_drifter','velvet_astrologer','ashtrail_hunter']},ensure_ascii=False)+'\n'+greetings+'const LINES := '+json.dumps(entries,ensure_ascii=False,indent=2)+'\n'+logic,encoding='utf-8')
print('Authored lines:',len(entries))
