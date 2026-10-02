"""Focused presentation-only writing pass. IDs, probabilities and mechanics stay put."""
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[1]
POOLS={
'signature_find':[('Archivist','A named relic. Read its signature before you equip it; old bargains rarely use small print.'),('Relic Keeper','Someone carried this through the Crownfall. We owe it more than a price tag.')],
'trophy_earned':[('Archivist','Filed under improbable achievements. That shelf is becoming a problem.'),('Salvager','A trophy! Finally, a dent nobody expects me to repair.')],
'forge_evolved':[('Salvager','Same weapon, new behaviour. Try it on something that is not my door.'),('Salvager','Evolution complete. The warranty has fled into the hills.')],
'new_weapon':[('Salvager','Check the weapon family before you swap. A bigger number is not the whole build.'),('Mascot','New weapon. Same suspiciously confident paws.')],
'contract_complete':[('Archivist','Contract complete. Claim your payment at Local Contracts; admiration is not legal tender.'),('Salvager','You did the job. Collect the Gold before somebody invents a processing fee.')],
'idle':[('Salvager','I tested that hinge. It passed. The wall is appealing.'),('Salvager','Repair, reuse, occasionally run away. Sustainable business.'),('Archivist','The Crown indexed every relic and forgot every person. We are correcting the catalogue.'),('Archivist','The forbidden shelf is locked. This has mainly improved its marketing.'),('Relic Keeper','A Core is a promise someone kept alive. Listen before you decide what it is worth.'),('Relic Keeper','You may rest here. The world will remain inconvenient tomorrow.'),('Mascot','I packed provisions. Most of them are provisions for me.')],
'tapped':[('Salvager','Need gear? Shop is to my right. Unsolicited repair advice is regrettably free.'),('Salvager','That lever is decorative. This warning is based on several experiments.'),('Archivist','Trophies, notes and memories are in the Archive. Yes, we keep the embarrassing ones.'),('Archivist','You may revise your plan. You may not revise the witness statement.'),('Relic Keeper','The shrine spends Star Shards on permanent power. Gold pays for Hideout improvements.'),('Relic Keeper','You are allowed to put the satchel down. That is not a defeat condition.'),('Mascot','Point me at the ruins. I have a sword and a deeply unearned sense of readiness.')],
'returning':[('Salvager','Back in one piece. Excellent. I am charging for fewer pieces this week.'),('Archivist','Tell me what happened before the version with dramatic lighting.'),('Relic Keeper','The gate brought you home. That matters more than what was in your hands.')],
'early_defeat':[('Salvager','Gold and Shards earned are yours. Try armour or healing upgrades before the next trip.'),('Archivist','A failed expedition is still evidence. The floor supplied most of it.'),('Mascot','I have assessed the situation. The situation has a very hard floor.')],
'victory':[('Salvager','Boss down, gear secured. Check your stash before spending the celebration fund.'),('Archivist','The vault is open. Its history is not finished with us.'),('Relic Keeper','You brought a forgotten promise home. For tonight, that is enough.'),('Mascot','We won. I would like the victory feast to begin before the credits.')],
'epic_find':[('Salvager','Epic gear. Compare the effects before the colour makes the decision for you.'),('Archivist','A valuable find. Please resist using it to point at the valuable find.'),('Mascot','Purple. Very dignified. I shall ruin that immediately.')],
'legendary_find':[('Salvager','Legendary. Read the signature; that is where the interesting trouble lives.'),('Archivist','A relic survived the fall of an empire. You have survived carrying it across the room.'),('Relic Keeper','This Core remembers its maker. Be gentle with that memory.'),('Mascot','Legendary acquired. Modesty has been unequipped.')],
'boss_defeated':[('Archivist','The guardian has fallen. Take the treasure; leave the names on the walls.'),('Salvager','Boss-grade salvage. My insurance company has gone very quiet.'),('Relic Keeper','The vault has stopped holding its breath. Listen.')],
'travel':[('Mascot','Small paws. Large sword. The staircase has filed a complaint.'),('Archivist','A named windup means an attack is coming. Keep your eyes on the foe, not the coin shower.'),('Salvager','Spend Run Scrip at roadside merchants. Unspent Scrip expires when the expedition ends.'),('Relic Keeper','Healing and armour keep ambitious builds alive. Power without a way home is a poor bargain.'),('Archivist','Tap the arena for extra strikes. Menus and the HUD are safe to touch.'),('Mascot','If a corridor feels suspiciously generous, check whether it has teeth.')],
'variant_seen':[('Archivist','That foe has a modifier. Read the badge; the usual assumptions may be expensive.'),('Mascot','New variety of bad idea. I was hoping for a new variety of biscuit.')],
'cache_opened':[('Salvager','Cache opened. Contents are yours; equipping them is a separate decision.'),('Mascot','An actual chest! I appreciate a container that respects the job description.'),('Archivist','Recovered from a sealed cache. Previous owner: conspicuously absent.')],
'shop_purchase':[('Salvager','Sold. Inspect the effects, then equip or store it. Regret is sold separately.'),('Salvager','I checked the straps. The curse department has not returned my call.'),('Mascot','A sensible purchase. Somebody write that down before it stops being true.')],
'shrine_upgrade':[('Relic Keeper','That power stays with you between expeditions. The Core remembers.'),('Relic Keeper','There. Stronger, not invincible. Please do not test the difference on my roof.'),('Mascot','Permanent upgrade. Temporary urge to lift the furniture.')],
'large_hoard':[('Salvager','The hoard needs another shelf. The shelf needs hazard pay.'),('Archivist','Your collection now has a table of contents. It is mostly warnings.'),('Mascot','Enough treasure to swim in. I have been advised to try a chair instead.')],
'first_visit':[('Archivist','Begin Expedition takes you into the ruins. Gear, upgrades and the Archive can wait until you return.'),('Salvager','Welcome home. Gold buys supplies; Scrap feeds the Forge. Keep both away from my lunch.'),('Relic Keeper','A safe gate, warm lanterns, people who remember your name. We start there.')],
'rare':[('Archivist','The old vault map says HERE BE ACCOUNTANTS. We have found worse things.'),('Salvager','A prophecy predicted my success. Very little was said about the overheads.'),('Relic Keeper','Sometimes the Core remembers a sky we have never seen. Those are the quiet nights.')]
}

def main():
    p=ROOT/'dialogue_director.gd';s=p.read_text();start=s.index('const POOLS := {');end=s.index('\nvar rng',start)
    lines=['const POOLS := {']
    for context,entries in POOLS.items():
        lines.append('\t'+json.dumps(context)+':[')
        lines.extend('\t\t'+json.dumps(dict(speaker=speaker,text=text,weight=2.0),ensure_ascii=False)+(',' if i<len(entries)-1 else '') for i,(speaker,text) in enumerate(entries))
        lines.append('\t],')
    lines[-1]='\t]';lines.append('}\n')
    p.write_text(s[:start]+'\n'.join(lines)+s[end:],encoding='utf-8')
    replacements={
    'game_catalog.gd':{
        'Execute below 12% HP':'Hits finish foes below 12% HP',
        'Rhythm hits deal 2.2x':'Periodic heavy hits deal 2.2x damage',
        'Frequent attacks chain':'Periodic strikes add lightning damage',
        'Hits build stronger burns':'Strengthen damage over time from burns',
        'Poison damage heals you':'Poison damage restores health',
        'Damage echoes to next foe':'Carry damage into the next foe',
        'QUAKE BONK':'QUAKE GRIP',
    },
    'lootling.gd':{
        'BONKED OUT!':'EXPEDITION ENDED',
        'Choose one relic-grade reward':'Inspect a reward, then confirm one',
        'TAP TO STRIKE • Auto-combat stays active':'TAP THE ARENA • Auto-attacks continue',
        'Back to the hunt!':'Supplies packed. Back to the ruins.',
        'Fresh salvage has arrived.':'Offers replaced. Inspect before buying.',
        'HOARD ERUPTS!':'THE HOARD OPENS',
    },
    'vignette_catalog.gd':{
        'The armour creaks. The toll was due centuries ago.':'The old toll is unpaid. He intends to collect it from someone still breathing.',
        'Every coin counted. Every intruder noticed.':'The dragon counts treasure in coins, and trespassers in bones.',
        'Warm lanterns. Stranger treasure. A door left unlocked.':'Beyond these lanterns, the ruins still take lives. Here, the door stays open.',
    },
    'world_story.gd':{
        'Follow the Core into the broken vaults.':'Your Core remembers a promise here. Bring it home.',
        'Old locks remember their owners.':'The locks serve a fallen Crown. Nobody told the guards.',
        'Something enormous counts its coins.':'The Hoard Dragon guards stolen promises. Guests get eaten.',
        'One vault quiet. Nine mysteries awake.':'The vault is open. Its stolen stories can finally leave.',
    },
    'item_catalog.gd':{
        'Heavy scavenged blade. Strong, deliberate hits.':'Heavy steel, a steady grip, and no intention of asking the lock nicely.',
        'Kills echo into the next foe.':'A hammer with a hungry grin. Its kill blast carries trouble forward.',
        'Ranged, rapid shots with keen aim.':'Light limbs, quick shots. The previous owner was less quick.',
        'Every fifth spell repeats at reduced power.':'Every fifth spell echoes. Even the staff enjoys a second opinion.',
        'Fast blades sharpen crits and executions.':'Quick blades for critical hits and finishing wounded foes. Subtlety optional.',
        'Enemies spill more Run Scrip.':'More Run Scrip from kills. Spend the proceeds before the expedition ends.',
        'Huge power while hurt. Probably safe.':'Stronger at low health, with less maximum HP. The inscription says probably.',
        'Burns hit harder and kills may erupt.':'Stronger burns and kill blasts. Not approved for indoor demonstrations.',
        'Heavy hits punish bosses.':'Heavy hits and boss damage. A small rune with a large grievance.',
    },
    'startup_ui.gd':{'RELIC CORE AWAKENING':'PACK LIGHT. COME HOME HEAVY.'},
    'hideout_ui.gd':{'Conquer a region to unlock the next.':'Defeat a region boss to unlock the next.'},
    }
    changed={}
    for name,pairs in replacements.items():
        p=ROOT/name;s=p.read_text(encoding='utf-8');count=0
        for before,after in pairs.items():
            count+=s.count(before);s=s.replace(before,after)
        p.write_text(s,encoding='utf-8');changed[name]=count
    report={'dialogue_contexts':len(POOLS),'dialogue_lines':sum(map(len,POOLS.values())),'other_replacements':changed,'rule':'Serious world. Ridiculous people. Real stakes. Cheeky reactions. Preserve all gameplay IDs and values.'}
    out=ROOT/'docs/production/phase2/mobileux';out.mkdir(exist_ok=True)
    (out/'copy-pass.json').write_text(json.dumps(report,indent=2)+'\n')
    print(report)

if __name__=='__main__':main()
