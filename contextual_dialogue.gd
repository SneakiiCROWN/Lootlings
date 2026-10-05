extends RefCounted
# Independent presentation RNG. Eligible categories only; no reward/save mutation.
const PERSONALITY := {"vault_runner": "A rich vault with one exit is a trap with expensive wallpaper.", "ruin_warden": "Drink something warm. I will watch the gate.", "nightstage_drifter": "An encore is only worth it if the whole audience survives.", "velvet_astrologer": "The sky gives probabilities. I pack bandages.", "ashtrail_hunter": "Fresh tracks outside the gate. Two feet, then four. Watch the bends."}
const GREETINGS := {"Salvager": ["Set it on the bench. If the grip slips, the shine will not save you.", "Warm fire, sound hinges, sharp steel. That is a home worth keeping."], "Relic Keeper": ["Put your pack down. You do not have to be useful every waking moment.", "I will tend the shrine. You tend the bruises. Neither job needs a hero."], "Archivist": ["Tell me who you met. Ruins are full of people reduced to architecture.", "The dead rarely correct my spelling. I try not to take advantage."]}
const LINES := [
  {
    "speaker": "relic_beast",
    "text": "I brought the lost buckle back. Also this shiny thing. Also three snacks.",
    "category": "banter"
  },
  {
    "speaker": "relic_beast",
    "text": "You stayed beside me in there. Next time I carry your bag.",
    "category": "banter"
  },
  {
    "speaker": "relic_beast",
    "text": "Is that chest friendly? I can offer it a biscuit.",
    "category": "banter"
  },
  {
    "speaker": "relic_beast",
    "text": "We brought everyone home! Can we count treasure after supper?",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "relic_beast",
    "text": "I left the treasure. I did not leave you.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "emberhorn",
    "text": "I can take the next watch. Nobody goes cold while I am here.",
    "category": "banter"
  },
  {
    "speaker": "emberhorn",
    "text": "Yes, I rushed the door. No, I will not rush the next one. Probably.",
    "category": "banter"
  },
  {
    "speaker": "emberhorn",
    "text": "Patch kept the rescue furnace burning. I want to be that reliable.",
    "category": "banter"
  },
  {
    "speaker": "emberhorn",
    "text": "Everyone made it. Good. That was the part I was worried about.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "emberhorn",
    "text": "I went too fast. Next time I watch the opening before I charge.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "mosskin",
    "text": "Sit in my shade. The garden can wait a little longer.",
    "category": "banter"
  },
  {
    "speaker": "mosskin",
    "text": "I kept the way home clear. A shield is useful after the fight, too.",
    "category": "banter"
  },
  {
    "speaker": "mosskin",
    "text": "The roots broke the lock. Very slowly. I admire their method.",
    "category": "banter"
  },
  {
    "speaker": "mosskin",
    "text": "The path is safe again. Rest now; I will take the watch.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "mosskin",
    "text": "A retreat is a path home. We can grow stronger here.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "moonkip",
    "text": "I checked both exits. The treasure can wait until you are through.",
    "category": "banter"
  },
  {
    "speaker": "moonkip",
    "text": "That lock was insulting. I accepted the challenge politely.",
    "category": "banter"
  },
  {
    "speaker": "moonkip",
    "text": "I returned the key. Nobody specified which pocket.",
    "category": "banter"
  },
  {
    "speaker": "moonkip",
    "text": "Nobody saw us leave. Everybody who matters came with us.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "moonkip",
    "text": "The exit worked. Next time we avoid needing it quite so urgently.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "pebblewyrm",
    "text": "Put the heavy bag on mine. We will complain together on the way home.",
    "category": "banter"
  },
  {
    "speaker": "pebblewyrm",
    "text": "The bridge held! I knew it would. I did check twice.",
    "category": "banter"
  },
  {
    "speaker": "pebblewyrm",
    "text": "My Core came from a foundation stone. Staying put is a family talent.",
    "category": "banter"
  },
  {
    "speaker": "pebblewyrm",
    "text": "Still standing! I told you these legs were dependable.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "pebblewyrm",
    "text": "I can try again. After a sit. A very determined sit.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "glimmerfin",
    "text": "You came back! Excellent. The welcome deserves at least one chorus.",
    "category": "banter"
  },
  {
    "speaker": "glimmerfin",
    "text": "I found a shell that remembers a voice. Let us listen before we sell it.",
    "category": "banter"
  },
  {
    "speaker": "glimmerfin",
    "text": "The shrine was quiet today. I sang softly. That still counts as restraint.",
    "category": "banter"
  },
  {
    "speaker": "glimmerfin",
    "text": "A fine ending! Save the applause until the wounded have seats.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "glimmerfin",
    "text": "That performance needs rehearsal. Nobody is being replaced.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "gloomlet",
    "text": "Your bag strap was broken. It is fixed now. No public ceremony, please.",
    "category": "banter"
  },
  {
    "speaker": "gloomlet",
    "text": "I kept your seat. For tactical reasons.",
    "category": "banter"
  },
  {
    "speaker": "gloomlet",
    "text": "Yes, I came back for you. Let us never discuss this in front of the others.",
    "category": "banter"
  },
  {
    "speaker": "gloomlet",
    "text": "Everyone survived. An acceptable result. Stop smiling at me.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "gloomlet",
    "text": "You came back for me. Reckless. Appreciated. Do not quote that.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "vault_runner",
    "text": "A rich vault with one exit is a trap with expensive wallpaper.",
    "category": "banter"
  },
  {
    "speaker": "vault_runner",
    "text": "I marked the way back. Getting paid requires getting out.",
    "category": "banter"
  },
  {
    "speaker": "vault_runner",
    "text": "Paid, alive, and no doors locked behind us. I like those numbers.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "vault_runner",
    "text": "The vault keeps its treasure today. I kept the map and my legs.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "ruin_warden",
    "text": "Drink something warm. I will watch the gate.",
    "category": "banter"
  },
  {
    "speaker": "ruin_warden",
    "text": "We count people before treasure. Every time.",
    "category": "banter"
  },
  {
    "speaker": "ruin_warden",
    "text": "Everyone accounted for. Now we can count the spoils.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "ruin_warden",
    "text": "I held the retreat. We will mend the line before we return.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "nightstage_drifter",
    "text": "An encore is only worth it if the whole audience survives.",
    "category": "banter"
  },
  {
    "speaker": "nightstage_drifter",
    "text": "You kept a seat for me. That is a better welcome than applause.",
    "category": "banter"
  },
  {
    "speaker": "nightstage_drifter",
    "text": "The curtain comes down with everyone standing. That is my kind of finale.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "nightstage_drifter",
    "text": "Rough rehearsal. Keep my place; I still owe you a better ending.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "velvet_astrologer",
    "text": "The sky gives probabilities. I pack bandages.",
    "category": "banter"
  },
  {
    "speaker": "velvet_astrologer",
    "text": "I checked the route twice. Confidence should have a foundation.",
    "category": "banter"
  },
  {
    "speaker": "velvet_astrologer",
    "text": "A fortunate outcome. The spare bandages can wait another night.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "velvet_astrologer",
    "text": "I misread that opening. No stars to blame; I will mark it in my notes.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "ashtrail_hunter",
    "text": "Fresh tracks outside the gate. Two feet, then four. Watch the bends.",
    "category": "banter"
  },
  {
    "speaker": "ashtrail_hunter",
    "text": "The wind has changed. Leave after it carries our scent away.",
    "category": "banter"
  },
  {
    "speaker": "ashtrail_hunter",
    "text": "No fresh tracks behind us. We can put the packs down.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "ashtrail_hunter",
    "text": "That trail turned ugly. We take a different approach next time.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "Salvager",
    "text": "I rebuilt this gate from salvage. Good work should outlast its first owner.",
    "category": "banter"
  },
  {
    "speaker": "Salvager",
    "text": "Sera checks the Core. I check what protects it. Neither of us signs off on guesswork.",
    "category": "banter"
  },
  {
    "speaker": "Salvager",
    "text": "Ilex found the original furnace plans. Finally, instructions that fit the machine.",
    "category": "banter"
  },
  {
    "speaker": "Salvager",
    "text": "Back on your feet? Put the weapon down and tell me where it caught.",
    "category": "context",
    "event": "returning"
  },
  {
    "speaker": "Salvager",
    "text": "You kept the grip steady through a long run. Now let me check the binding.",
    "category": "context",
    "event": "returning"
  },
  {
    "speaker": "Salvager",
    "text": "You came back. That is the part I cannot replace. We will check your gear next.",
    "category": "context",
    "event": "early_defeat"
  },
  {
    "speaker": "Salvager",
    "text": "Do not buy another weapon yet. Tell me what broke your rhythm first.",
    "category": "context",
    "event": "early_defeat"
  },
  {
    "speaker": "Salvager",
    "text": "Try the grip here before taking it into a fight. Keep the receipt until it fits.",
    "category": "context",
    "event": "shop_purchase"
  },
  {
    "speaker": "Salvager",
    "text": "The new balance is deliberate. Give that movement room on your next trip.",
    "category": "context",
    "event": "forge_evolved"
  },
  {
    "speaker": "Salvager",
    "text": "Different reach, different opening. Take one clean swing before you trust it.",
    "category": "context",
    "event": "new_weapon"
  },
  {
    "speaker": "Salvager",
    "text": "Fine edge. Unusual balance. Keep the old weapon until you learn this one.",
    "category": "context",
    "event": "legendary_find"
  },
  {
    "speaker": "Salvager",
    "text": "That is a named relic. I will inspect the fittings; Ilex will want its history.",
    "category": "context",
    "event": "signature_find"
  },
  {
    "speaker": "Salvager",
    "text": "A Crownroot relic. No rushing this inspection. Power still needs a sound grip.",
    "category": "context",
    "event": "red_find"
  },
  {
    "speaker": "Salvager",
    "text": "A suspiciously generous chest? Inspect the hinge before congratulating yourself.",
    "category": "easter",
    "flag": "easter_egg"
  },
  {
    "speaker": "Salvager",
    "text": "A room full of healing supplies and an empty circle. I would sharpen something.",
    "category": "easter",
    "flag": "easter_egg"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Cores remember what they were asked to protect. Treating them as spare fuel destroys that purpose.",
    "category": "banter"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Patch keeps the furnace warm for Emberhorn. Care is often less dramatic than people expect.",
    "category": "banter"
  },
  {
    "speaker": "Relic Keeper",
    "text": "A Core can remember a promise without knowing who made it. We help it find the rest.",
    "category": "banter"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Put your pack down. A long road does not make rest optional.",
    "category": "context",
    "event": "returning"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Rest first. A living Core matters more than the treasure left behind.",
    "category": "context",
    "event": "early_defeat"
  },
  {
    "speaker": "Relic Keeper",
    "text": "The shrine can support you more steadily now. It does not ask you to prove anything.",
    "category": "context",
    "event": "shrine_upgrade"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Let the relic settle before you bind it. Strength is useful; consent matters too.",
    "category": "context",
    "event": "legendary_find"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Crownroot joins the fragments left by the Crownfall. We will tend what wakes inside it.",
    "category": "context",
    "event": "red_find"
  },
  {
    "speaker": "Relic Keeper",
    "text": "If you are saving every tonic for an emergency, tell me what you call the last fight.",
    "category": "easter",
    "flag": "easter_egg"
  },
  {
    "speaker": "Archivist",
    "text": "Starfall erased names before it erased people. I left while mine still belonged to me.",
    "category": "banter"
  },
  {
    "speaker": "Archivist",
    "text": "Record what you saw, including what you could not identify. Certainty can wait for evidence.",
    "category": "banter"
  },
  {
    "speaker": "Archivist",
    "text": "Patch repairs what remains. I record who it belonged to. We need both.",
    "category": "banter"
  },
  {
    "speaker": "Archivist",
    "text": "Tell me where you went. A map gains value from a witness who returned.",
    "category": "context",
    "event": "returning"
  },
  {
    "speaker": "Archivist",
    "text": "We have a surviving witness. Start with the attack you did not recognize.",
    "category": "context",
    "event": "early_defeat"
  },
  {
    "speaker": "Archivist",
    "text": "A named relic has a history. Your discovery belongs beside its old owners.",
    "category": "context",
    "event": "signature_find"
  },
  {
    "speaker": "Archivist",
    "text": "Collect the board reward. You did the work; the promise should be kept.",
    "category": "context",
    "event": "contract_complete"
  },
  {
    "speaker": "Archivist",
    "text": "The guardian fell. Tell me what changed around it before we count the spoils.",
    "category": "context",
    "event": "boss_defeated"
  },
  {
    "speaker": "Archivist",
    "text": "That immaculate empty hall? Architects rarely install a grand entrance for a broom cupboard.",
    "category": "easter",
    "flag": "easter_egg"
  },
  {
    "speaker": "Archivist",
    "text": "Another sealed room behind a cracked wall. The builders were less subtle than they thought.",
    "category": "easter",
    "flag": "easter_egg"
  },
  {
    "speaker": "Salvager",
    "text": "Sound footing and a clean opening. Keep doing what brought you home.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "Relic Keeper",
    "text": "You returned alive and freed something the Crown had kept. Let us tend both.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "Archivist",
    "text": "A victory with a witness. That is considerably better than a heroic rumour.",
    "category": "context",
    "outcome": "victory"
  },
  {
    "speaker": "Salvager",
    "text": "The weapon is repairable. You need a rest before another run.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "Relic Keeper",
    "text": "You survived. Let the shrine hold some of the weight tonight.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "Archivist",
    "text": "Tell me how the fight turned. A defeat can still leave a useful account.",
    "category": "context",
    "outcome": "defeat"
  },
  {
    "speaker": "Salvager",
    "text": "I will check the string and grip. The draw should pull cleanly, not fight you.",
    "category": "gameplay",
    "weapon": "bow",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Keep the bolt clear while I inspect the catch. A stiff trigger wastes your opening.",
    "category": "gameplay",
    "weapon": "crossbow",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Two blades, two hands. Recover one while the other makes its opening.",
    "category": "gameplay",
    "weapon": "daggers",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Check each fastening. A claw that turns in your palm is working for the other side.",
    "category": "gameplay",
    "weapon": "claws",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Let the charge finish before the release. Your footing matters as much as the spell.",
    "category": "gameplay",
    "weapon": "staff",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Use the reach. If the blade drags you forward, reset your stance.",
    "category": "gameplay",
    "weapon": "greatsword",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Let the head carry the blow. Then bring it home before the counterattack.",
    "category": "gameplay",
    "weapon": "maul",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Keep the point between you and the threat. Recover straight after the thrust.",
    "category": "gameplay",
    "weapon": "spear",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "A clear arc, then a clean release. Check behind you before you start the rotation.",
    "category": "gameplay",
    "weapon": "sling",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Commit to the cut, then recover your footing. Weight is useful when you control it.",
    "category": "gameplay",
    "weapon": "greataxe",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Small movement, precise aim. Keep the focus steady through the release.",
    "category": "gameplay",
    "weapon": "wand",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Salvager",
    "text": "Do not squeeze the focus. Give its charge room and guide the release.",
    "category": "gameplay",
    "weapon": "orb",
    "flag": "weapon_comment"
  },
  {
    "speaker": "Archivist",
    "text": "The Verdant Mirror diverted the forest spring. If it fell, we should check whether water reaches the gardens again.",
    "category": "context",
    "region": "mossglass_wilds",
    "outcome": "victory",
    "flag": "boss_memory"
  },
  {
    "speaker": "Relic Keeper",
    "text": "The Mirror held stolen spring water in its roots. Breaking its hold helps living things downstream.",
    "category": "context",
    "region": "mossglass_wilds",
    "event": "boss_defeated"
  },
  {
    "speaker": "Archivist",
    "text": "Moonfen lanterns lure travellers off the path. Record which lights moved before the attack.",
    "category": "gameplay",
    "region": "moonfen"
  },
  {
    "speaker": "Archivist",
    "text": "Those Gearworks machines kept working after their makers died. We should find who was chained to the engine.",
    "category": "gameplay",
    "region": "sunken_gearworks"
  },
  {
    "speaker": "Archivist",
    "text": "The Archive Redactor erases names from records. I survived by leaving Starfall before mine vanished.",
    "category": "gameplay",
    "region": "starfall_archive"
  },
  {
    "speaker": "Relic Keeper",
    "text": "You escaped with little strength left. Sit by the shrine before deciding what comes next.",
    "category": "context",
    "low_health": "yes"
  },
  {
    "speaker": "Archivist",
    "text": "You cleared the Rootglass Vault. Bring the Crownroot to Sera before we catalogue it.",
    "category": "context",
    "mode": "dungeon",
    "outcome": "victory"
  },
  {
    "speaker": "Salvager",
    "text": "You extracted from the Siege. Empty the bag before the next fight; I want to see what survived.",
    "category": "context",
    "mode": "siege",
    "outcome": "victory"
  },
  {
    "speaker": "Archivist",
    "text": "The Crownfall left living Cores inside abandoned work. A relic may remember its maker even when our books do not.",
    "category": "secret",
    "event": "archive_discovery",
    "flag": "rare_lore"
  },
  {
    "speaker": "Relic Keeper",
    "text": "A rediscovered name can help a Core recognize an old bond. Bring the Archive account to the shrine.",
    "category": "secret",
    "event": "secret_discovered",
    "flag": "secret_hint"
  },
  {
    "speaker": "Archivist",
    "text": "Some witnesses were erased twice: first from the records, then from the stories told about them. Compare the two accounts.",
    "category": "secret",
    "event": "signature_find",
    "flag": "rare_lore"
  },
  {
    "speaker": "Salvager",
    "text": "Leave the satchel here, little courier. I will mend it while you eat.",
    "category": "banter",
    "character": "relic_beast"
  },
  {
    "speaker": "Salvager",
    "text": "You do not have to rescue everyone alone, Emberhorn. That is why we keep a gate.",
    "category": "banter",
    "character": "emberhorn"
  },
  {
    "speaker": "Salvager",
    "text": "The garden can spare you for supper, Mosskin. I checked.",
    "category": "banter",
    "character": "mosskin"
  },
  {
    "speaker": "Salvager",
    "text": "Moonkip, tell me which lock failed. I want to repair it before you prove your point again.",
    "category": "banter",
    "character": "moonkip"
  },
  {
    "speaker": "Salvager",
    "text": "Pebblewyrm, put the bags down. Being dependable includes letting me carry one.",
    "category": "banter",
    "character": "pebblewyrm"
  },
  {
    "speaker": "Salvager",
    "text": "Glimmerfin, save the chorus for supper. I need to hear whether this blade rings true.",
    "category": "banter",
    "character": "glimmerfin"
  },
  {
    "speaker": "Salvager",
    "text": "Gloomlet, I left the spare binding beside your seat. No announcement required.",
    "category": "banter",
    "character": "gloomlet"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Your Core brightens near the return-gate. You know when someone is coming home.",
    "category": "banter",
    "character": "relic_beast"
  },
  {
    "speaker": "Relic Keeper",
    "text": "The rescue furnace promised shelter. You are allowed to receive that warmth too.",
    "category": "banter",
    "character": "emberhorn"
  },
  {
    "speaker": "Relic Keeper",
    "text": "A watchstone cannot protect its garden by wearing itself out. Rest with us.",
    "category": "banter",
    "character": "mosskin"
  },
  {
    "speaker": "Relic Keeper",
    "text": "You found the way out, Moonkip. That matters more than what stayed in the chest.",
    "category": "banter",
    "character": "moonkip"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Put the burden down, Pebblewyrm. We will still depend on you tomorrow.",
    "category": "banter",
    "character": "pebblewyrm"
  },
  {
    "speaker": "Relic Keeper",
    "text": "The shell remembers a voice. Let it finish before you answer with a song.",
    "category": "banter",
    "character": "glimmerfin"
  },
  {
    "speaker": "Relic Keeper",
    "text": "Your place here does not depend on being noticed, Gloomlet. I kept it for you.",
    "category": "banter",
    "character": "gloomlet"
  },
  {
    "speaker": "Archivist",
    "text": "Courier satchels carried promised returns. Yours may help us trace an old route.",
    "category": "banter",
    "character": "relic_beast"
  },
  {
    "speaker": "Archivist",
    "text": "I found a furnace record naming the workers who promised shelter. You would like them.",
    "category": "banter",
    "character": "emberhorn"
  },
  {
    "speaker": "Archivist",
    "text": "Your watchstone guarded a garden. Tell me what still grows there.",
    "category": "banter",
    "character": "mosskin"
  },
  {
    "speaker": "Archivist",
    "text": "A locked bell tower with no sign of entry. Moonkip, I would value an honest account.",
    "category": "banter",
    "character": "moonkip"
  },
  {
    "speaker": "Archivist",
    "text": "Foundation Cores supported ordinary homes. Those histories deserve names too.",
    "category": "banter",
    "character": "pebblewyrm"
  },
  {
    "speaker": "Archivist",
    "text": "We can record the drowned song together. I will not ask you to keep quiet for the whole day.",
    "category": "banter",
    "character": "glimmerfin"
  },
  {
    "speaker": "Archivist",
    "text": "You brought back an overlooked keepsake. I will record its owner, not the rescuer.",
    "category": "banter",
    "character": "gloomlet"
  }
]

var recent: Array[String]=[]
var visits: Dictionary={}
var rare_ready: Dictionary={}
var rng:=RandomNumberGenerator.new()
var last_selection: Dictionary={}
var calls:=0

func _init() -> void:
	rng.randomize()

func choose(speaker: String, facts: Dictionary) -> String:
	calls+=1
	var visit: int=int(visits.get(speaker,0)); visits[speaker]=visit+1
	var buckets: Dictionary={}
	var clock: float=Time.get_ticks_msec()/1000.0
	for entry in LINES:
		if entry.speaker!=speaker or entry.text in recent: continue
		var matches:=true
		for key in entry:
			if key in ["speaker","text","category","flag"]: continue
			if str(facts.get(key,""))!=str(entry[key]): matches=false; break
		if not matches: continue
		var category: String=entry.category
		if category in ["easter","secret"]:
			var ready: Dictionary=rare_ready.get(category,{})
			if clock<float(ready.get("time",0)) or calls<int(ready.get("call",0)): continue
		if not buckets.has(category): buckets[category]=[]
		buckets[category].append(entry)
	# Greetings are everyday lines, never an unrelated origin-story fallback.
	if not buckets.has("banter"): buckets.banter=[]
	for text in GREETINGS.get(speaker,[]):
		if not text in recent: buckets.banter.append({"speaker":speaker,"text":text,"category":"banter"})
	var category_weights: Dictionary={"context":50,"banter":25,"gameplay":15,"easter":7,"secret":3}
	var total:=0.0
	for category in buckets:
		if not buckets[category].is_empty(): total+=float(category_weights[category])
	if total<=0:
		# Exhaustion frees only this voice's oldest entry, preserving no immediate repeats.
		if recent.size()>1: recent.pop_front(); return choose(speaker,facts)
		return "The gate is open. Come back safely."
	var roll: float=rng.randf()*total
	var chosen_category: String="banter"
	for category in buckets:
		if buckets[category].is_empty(): continue
		roll-=float(category_weights[category])
		if roll<=0: chosen_category=category; break
	var candidates: Array=buckets[chosen_category]
	if chosen_category=="context":
		var specificity:=0
		for entry in candidates:
			specificity=maxi(specificity,entry.size()-4 if entry.has("flag") else entry.size()-3)
		candidates=candidates.filter(func(entry): return (entry.size()-4 if entry.has("flag") else entry.size()-3)==specificity)
	# First meeting starts grounded; later taps use the eligible weighted mix.
	if visit==0 and str(facts.get("event",""))=="" and not buckets.banter.is_empty(): candidates=buckets.banter
	var selected: Dictionary=candidates[rng.randi_range(0,candidates.size()-1)]
	last_selection=selected.duplicate(true)
	var line: String=selected.text
	recent.append(line)
	if recent.size()>12: recent.pop_front()
	if selected.category in ["easter","secret"]:
		rare_ready[selected.category]={"time":clock+(1200 if selected.category=="easter" else 1800),"call":calls+(24 if selected.category=="easter" else 40)}
	return line
