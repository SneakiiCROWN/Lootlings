"""Identity index from existing reflected catalogs and approved export contracts.

This does not approve new art. Pose cells remain in the generated art matrix.
"""
from pathlib import Path
from collections import defaultdict
import hashlib,json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/production'
def read(path): return json.loads((ROOT/path).read_text(encoding='utf-8-sig'))
def sha(path): return hashlib.sha256((ROOT/path).read_bytes()).hexdigest()
def build():
    master=read('docs/production/MASTER_INTEGRATION_MANIFEST.json')
    runtime=read('docs/production/MASTER_RUNTIME_CATALOG_SNAPSHOT.json')
    status=read('art/reference/phase4e_handoff/REFERENCE_STATUS.json')
    entries={}; coverage={}; missing=defaultdict(list)
    for row in master['records']:
        if row['status']=='NEEDS_NEW_CANON_EXPORT': missing[row['game_id']].append(row['slot_id'])
    def add(category,id,name,source,accepted=(),**extra):
        key=category+':'+id
        if key not in entries:
            entries[key]=dict(stable_id=id,category=category,display_name=name,authoritative_source=source,
                accepted_runtime_sources=sorted(set(accepted)),status='ACCEPTED_BETA_SOURCE' if accepted else 'CANON_IDENTITY_WRITTEN_ONLY',
                rejected_conflicting_sources=[],guidance_only_sources=[],missing_required_states=missing.get(id,[]),
                fallback_policy='Missing authored state stays explicitly TEMP; no proxy establishes identity, no idle-as-attack or unsafe mirroring.',
                approval_state='Final visual owner acceptance open; source acceptance is not state/art completion.')
        entries[key]['authoritative_source']=source
        entries[key]['display_name']=name
        if accepted: entries[key]['accepted_runtime_sources']=sorted(set(accepted))
        entries[key].update(extra)
        return key
    # Catalog records and UI entry points retain their real ID namespace. Repeated
    # item/profile definitions point to one identity rather than inventing cast.
    for row in master['records']:
        if not row['launch_scope'] or not row['slot_id'].startswith(('content:','screen:')): continue
        ev=row.get('evidence') or {}; definition=ev.get('actual_definition',{})
        if row['slot_id'].startswith('screen:'):
            category='ui'; id=row['slot_id'].removeprefix('screen:')
        else:
            category=row['category']; id=row['game_id']
            if category=='playable':
                if ev.get('constant') not in ('ENTRIES','PRESETS'): category='wanderer_option'; id=ev.get('constant','')+'/'+id
                else: category='lootling' if row['implementation_file']=='lootling_catalog.gd' else 'wanderer'
            if category=='weapon' and ev.get('constant')!='FAMILIES': category='weapon_option';id=ev.get('constant','')+'/'+id
            if category in ('story','dialogue','audio_hook','world','reward'): id=ev.get('constant','')+'/'+id
            if category=='boss': category='boss_profile'; id=ev.get('constant','')+'/'+id
        name=definition.get('display_name',definition.get('name',row['subject'])) if isinstance(definition,dict) else row['subject']
        source=row['implementation_file']+'#'+ev.get('constant',row['state'] or '')+'/'+str(ev.get('key',''))
        key=add(category,id,str(name),source)
        coverage[row['slot_id']]=key
    export_rows=[]
    export_rows+=read('art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json')['entries']
    for path in ['art/production_pose_manifest.json','art/production/phase4e/runtime_manifest.json','art/production/phase4e/reuse_manifest.json','art/production/phase4e/extraction_manifest.json']:
        export_rows+=read(path)['entries']
    for category,filename,constant in [('lootling','lootling_catalog.gd','ENTRIES'),('wanderer','wanderer_catalog.gd','PRESETS')]:
        for id,entry in runtime[filename]['constants'][constant].items():
            assets=[r['asset_path'] for r in export_rows if r.get('actor')==id and r.get('asset_path')]
            if category=='wanderer': assets.append(entry['runtime_sprite'])
            else:
                old=ROOT/('art/sprites/lootlings/'+id+'_idle.png')
                if old.exists(): assets.append('res://'+old.relative_to(ROOT).as_posix())
            source=entry.get('reference',entry.get('runtime_sprite'))
            locked='res://art/reference/canonical/characters/'+('Lootlings_Main_Mascot_RelicBeast_Canonical.png' if id=='relic_beast' else id.capitalize()+'_CharacterSheet_Canonical.png') if category=='lootling' else 'res://art/sprites/wanderers/beta/'+id+'_idle.png'
            assert source==locked,'Stable identity changed canonical source: '+id
            add(category,id,entry['display_name'],source,assets,accepted_runtime_sources=sorted(set(assets)),
                status='NEEDS_NEW_CANON_EXPORT',missing_required_states=missing[id],
                identity_lock={'glimmerfin':'Dedicated sheet confirmed by owner: pale aquatic, pink/cyan frilled ears, luminous tail, blue Core and mage/tide identity; no board-04 body replacement.', 'gloomlet':'Dedicated sheet confirmed by owner: black-purple furry Assassin, magenta ears, violet eyes/Core, clawed partial armour; no mushroom/hooded board-04 replacement.', 'moonkip':'Established hooded rogue; baked daggers do not constitute a weaponless export.'}.get(id,'Preserve established silhouette, anatomy, outfit, proportions and colours.'))
    for id,entry in runtime['weapon_catalog.gd']['constants']['FAMILIES'].items():
        icons=[r['asset_path'] for r in export_rows if r.get('kind')=='weapons' and r.get('id')==id]
        add('weapon',id,entry['name'],'weapon_catalog.gd#FAMILIES/'+id,icons,
            status='ACCEPTED_BETA_SOURCE',fallback_policy='Accepted inventory glyph only. Held weapon, paired grip, support/nock and facing contracts remain in the authored pose manifests; an icon never supplies combat art.')
    for id,entry in runtime['vignette_catalog.gd']['constants']['RESIDENTS'].items():
        scoped=next((x for x in json.loads((ROOT/'art/npc_identity_authorities.json').read_text())['entries'] if x['id']==id),None) if (ROOT/'art/npc_identity_authorities.json').exists() else None
        add('npc',id,entry['name'],scoped['canonical_source'] if scoped else 'world_story.gd#NPC_NOTES/'+entry['name'],
            ['res://'+scoped['runtime_asset']] if scoped else ['res://art/sprites/npcs/beta/'+id+'_idle.png','res://art/sprites/npcs/beta/'+id+'_portrait.png'],
            status='NEEDS_NEW_CANON_EXPORT',missing_required_states=missing[id])
        if scoped:
            entries['npc:'+id]['rejected_conflicting_sources']=scoped['superseded_runtime_assets']
            entries['npc:'+id]['fallback_policy']=scoped['purpose']
    add('merchant','pack_peddler','Pack Peddler / Merrow','LOOTLINGS_WORLD_BIBLE.md#merchant',
        status='CANON_IDENTITY_WRITTEN_ONLY',missing_required_states=['rest','talk','offer','inspect','return'],
        fallback_policy='Keep the existing merchant role/composition; no new NPC identity from concept labels.')
    for zone in runtime['zone_catalog.gd']['constants']['ZONES']:
        for enemy in zone['enemies'].values():
            asset='res://art/sprites/enemies/'+enemy['id']+'.png'
            add('enemy',enemy['id'],enemy['name'],'zone_catalog.gd#ZONES/'+zone['id']+'/enemies',
                [asset] if (ROOT/asset.removeprefix('res://')).exists() else [], missing_required_states=missing[enemy['id']])
    bosses=runtime['vignette_catalog.gd']['constants']['BOSS_ENTRIES'].copy()
    for region,id in runtime['vignette_catalog.gd']['constants']['REGIONAL_BOSS_IDS'].items():
        bosses[id]={'name':runtime['world_content_catalog.gd']['constants']['FUTURE_ZONES'][region]['boss'],'region':region,'art':''}
    for id,entry in bosses.items():
        add('boss_identity',id,entry['name'],'vignette_catalog.gd#boss_entries/'+id,
            [entry['art']] if entry['art'] else [], status='NEEDS_NEW_CANON_EXPORT',runtime_region_id=entry['region'],
            missing_required_states=missing[entry['region']],
            identity_lock='Wingless/coiled violet-obsidian-gold; actual malformed source tail remains REPLACE.' if id=='hoard_dragon' else 'Existing written and accepted intro identity; regional proxies are TEMP only.')
    for region in runtime['campaign_system.gd']['constants']['ORDER']:
        art=runtime['vignette_catalog.gd']['constants']['REGION_ART'].get(region)
        paths=['res://art/backgrounds/beta/'+art+'.png'] if art else [z['background']['resource_path'] for z in runtime['zone_catalog.gd']['constants']['ZONES']]
        add('region',region,region.replace('_',' ').title(),'LOOTLINGS_WORLD_BIBLE.md#'+region,paths)
    systems={
        'hub':('Main Hub / Hideout','hideout_ui.gd',['res://art/backgrounds/lootlings_hideout.png']),
        'home':('Personal Home','personal_home.gd',['res://art/backgrounds/stash_vault.png']),
        'relic_machine':('Relic Machine','relic_machine.gd',['res://art/ui/relic_machine_frame.svg','res://art/ui/production/relic.png']),
        'combat_hud':('Combat HUD','lootlings_ui.gd',[]), 'archive':('Archive / Field Notes','field_notes_catalog.gd',[]),
        'memory':('Recovered Memories','vignette_catalog.gd',[]), 'title_app':('Lootlings title / app','startup_ui.gd',[])}
    for id,(name,source,assets) in systems.items(): add('presentation',id,name,source,assets)
    for id in ['gold','coins','scrap','red_fragments','spin_sparks','spin_wallet','free_spins']:
        add('resource',id,id.replace('_',' ').title(),'inventory_system.gd / endgame_progress.gd / relic_chase_meter.gd', fallback_policy='Use current currency/icon contract and actual wallet; never substitute currencies or alter value.')
    for id in ['Weapon','Armour','Relic','Rune','jewellery','offhand','spell','material','currency','reward','chest']:
        add('item_category',id,id,'item_catalog.gd / item_icon.gd', fallback_policy='Use current category/icon resolver. Category coverage does not claim every missing illustration is approved.')
    rejected=[r['path'] for r in status['references'] if not r['runtime_allowed']]
    for entry in entries.values():
        if entry['stable_id'] in ['gloomlet','moonkip','hoard_dragon']:
            entry['rejected_conflicting_sources']=[p for p in rejected if entry['stable_id'].split('_')[0].lower() in p.lower()]
        entry['guidance_only_sources']=['art/reference/phase4e_handoff/REFERENCE_STATUS.json']
    inputs=['docs/production/MASTER_INTEGRATION_MANIFEST.json','docs/production/MASTER_RUNTIME_CATALOG_SNAPSHOT.json','art/reference/phase4e_handoff/REFERENCE_STATUS.json','art/actor_identity_corrections.json','art/production_pose_manifest.json','art/production/phase4e/runtime_manifest.json','art/production/phase4e/reuse_manifest.json','art/production/phase4e/extraction_manifest.json']
    inputs.append('art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json')
    approved_file='art/approved_missing_canon_references.json'
    if (ROOT/approved_file).exists():
        approved=read(approved_file)['entries']; assert len(approved)==35
        runtime_file='art/production/phase4e/approved_missing_runtime_manifest.json'
        deliveries=read(runtime_file)['entries'] if (ROOT/runtime_file).exists() else []
        for ref in approved:
            category={'regional enemy':'enemy','boss':'boss_identity','current merchant role':'merchant'}[ref['category']]
            key=category+':'+ref['entity_id']; assert key in entries and ref['runtime_asset'] is False
            assert sha(ref['source'])==ref['source_sha256']
            entry=entries[key];entry['authoritative_source']='res://'+ref['source']
            entry['owner_reference_approval']=ref['owner_approval'];entry['reference_scope']=ref['restrictions']
            entry['status']='OWNER_APPROVED_VISUAL_REFERENCE_RUNTIME_STATES_OPEN'
            entry['identity_lock']='Approved named entity panel only; written stable ID/region and mechanics override board headings.'
            entry['accepted_runtime_sources']=sorted(set(entry['accepted_runtime_sources']+[r['asset_path'] for r in deliveries if r['actor']==ref['game_id'] and r.get('native_validated')]))
        inputs.append(approved_file)
        if (ROOT/runtime_file).exists():inputs.append(runtime_file)
    companion_file='art/reference/canonical/companions/COMPANION_CANON_MANIFEST.json'
    if (ROOT/companion_file).exists():
        companion=read(companion_file)
        assert companion['status']=='OWNER_APPROVED_FINAL_COMPANION_REFERENCE'
        previews=read('art/production/companions/previews/manifest.json')['entries']
        for name in companion['canonical_companions']:
            id=name.lower()
            delivered=read('art/production/companions/runtime_manifest.json')['entries']
            cells=[r for r in delivered if r.get('actor')==id and r.get('native_validated',False)]
            required=[state+'_'+facing for state in ['idle','move','reaction','perch_rest','perch_interact'] for facing in ['right','left']]
            present={r['state']+'_'+r['facing'] for r in cells}
            remaining=[key for key in required if key not in present]
            add('companion',id,name,companion['reference_files'][0]['path'],[r['asset'] for r in previews if r['id'] in [id,id+'_unlock']]+[r['asset_path'].removeprefix('res://') for r in cells],status='APPROVED_COMPANION_IDENTITY_COMPLETE_FOLLOWER_AND_PERCH_RUNTIME' if not remaining else 'APPROVED_COMPANION_IDENTITY_RUNTIME_STATES_OPEN',identity_lock='Companion-only; never overrides playable/NPC/enemy/boss canon.',missing_required_states=remaining)
        inputs += [companion_file,'art/production/companions/previews/manifest.json']
    return dict(schema_version=1,authority='START_HERE_CURRENT.md; written IDs and frozen sheets win. Generated by tools/build_canon_registry.py; explicit missing-source approval register is limited to35 entities; companion-only approval separately names six identities.',
        source_sha256={p:sha(p) for p in inputs}, rejected_runtime_paths=rejected,
        entries=[entries[k] for k in sorted(entries)],runtime_slot_coverage=coverage,
        exact_state_contract='phase4e/extraction/MISSING_ART_MANIFEST.json', counts=master['counts'])
if __name__=='__main__':
    data=build();(OUT/'CANON_REGISTRY.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('CANON registry:',len(data['entries']),'identities;',len(data['runtime_slot_coverage']),'catalog/screen routes; no new art approval')
