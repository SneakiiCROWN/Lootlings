"""Reproducible production index: actual runtime IDs, source inventory and art contracts.

No game changes, no generated art, no new canon. Delivery cells remain explicit;
external requests group shared actor/state/weapon requirements into packages.
"""
from pathlib import Path
from collections import Counter,defaultdict
import csv,hashlib,json,re
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'docs/production'
STATUSES=['LIVE_FINAL','LIVE_BETA','EXTRACTABLE_NOW','NEEDS_CROP_OR_MASK','NEEDS_RUNTIME_ASSEMBLY','NEEDS_NEW_CANON_EXPORT','REFERENCE_ONLY','REJECTED_IDENTITY_DRIFT','PLANNED_NOT_IMPLEMENTED','NOT_REQUIRED_FOR_CURRENT_LAUNCH']
def read(p):return p.read_text(encoding='utf-8-sig')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def input_digest(p):return hashlib.sha256(read(p).encode('utf-8')).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def slug(v):return re.sub(r'[^a-z0-9]+','_',str(v).lower()).strip('_')
def main():
    OUT.mkdir(parents=True,exist_ok=True)
    raw_snapshot=ROOT/'.godot_test_data/master-integration/runtime.json'
    if not raw_snapshot.exists():raw_snapshot=OUT/'MASTER_RUNTIME_CATALOG_SNAPSHOT.json'
    runtime=json.loads(read(raw_snapshot))
    for filename,info in runtime.items():
        assert info.get('source_sha256')==hashlib.sha256(read(ROOT/filename).encode('utf-8')).hexdigest(),'Runtime snapshot stale; rerun isolated master_runtime_inventory.gd: '+filename
    dump(OUT/'MASTER_RUNTIME_CATALOG_SNAPSHOT.json',runtime)
    missing=json.loads(read(OUT/'phase4e/extraction/MISSING_ART_MANIFEST.json'))
    extraction=json.loads(read(ROOT/'art/production/phase4e/extraction_manifest.json'))
    pose_sources={r['asset_path']:r for r in json.loads(read(ROOT/'art/production_pose_manifest.json'))['entries']+json.loads(read(ROOT/'art/production/phase4e/runtime_manifest.json'))['entries'] if r.get('asset_path')}
    enemy_rows=[r for r in json.loads(read(ROOT/'art/production_enemy_manifest.json'))['entries'] if r.get('native_validated')]
    enemy_sources={(r['actor'],r['state'],r['facing']):r for r in enemy_rows}
    pose_sources.update({r['asset_path']:r for r in enemy_rows})
    npc_rows=[r for r in json.loads(read(ROOT/'art/production_npc_manifest.json'))['entries'] if r.get('native_validated') and r.get('production_status')=='canon_validated_runtime']
    npc_sources={(r['actor'],r['state'],r['facing']):r for r in npc_rows}
    pose_sources.update({r['asset_path']:r for r in npc_rows})
    missing['total_missing_cells']-=sum(1 for c in missing['missing'] if (c['game_id'],c['state'],c['facing']) in npc_sources)
    missing['total_missing_cells']-=sum(1 for c in missing['missing'] if (c['game_id'],c['state'],c['facing']) in enemy_sources)
    boss_rows=[r for r in json.loads(read(ROOT/'art/production_boss_manifest.json'))['entries'] if r.get('native_validated')]
    boss_sources={(r['region'],(r['action']+' '+r['state']).strip(),r['facing']):r for r in boss_rows}
    missing['total_missing_cells']-=sum(1 for c in missing['missing'] if (c['game_id'],c['state'],c['facing']) in boss_sources)
    pose_sources.update({r['asset_path']:r for r in boss_rows})
    crop_sources={r['asset_path']:r for r in extraction['entries']}
    pose_sources.update({r['asset_path']:r for r in json.loads(read(ROOT/'art/production/phase4e/reuse_manifest.json'))['entries']})
    pose_sources.update({r['asset_path']:r for r in json.loads(read(ROOT/'art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json'))['entries']})
    batch=ROOT/'art/production/phase4e/player_batch_043_manifest.json'
    if batch.exists():pose_sources.update({r['asset_path']:r for r in json.loads(read(batch))['entries'] if r.get('native_validated') and r.get('production_status')=='canon_validated_runtime'})
    references=json.loads(read(ROOT/'art/reference/phase4e_handoff/REFERENCE_STATUS.json'))
    npc_authorities={x['id']:x for x in json.loads(read(ROOT/'art/npc_identity_authorities.json'))['entries']} if (ROOT/'art/npc_identity_authorities.json').exists() else {}
    texts={p.name:read(p) for p in ROOT.glob('*.gd')}
    rows=[];keys=set()
    def add(id,category,subject,status='LIVE_BETA',**extra):
        if id in keys:raise ValueError('Duplicate slot '+id)
        keys.add(id)
        row=dict(slot_id=id,game_id=slug(subject),category=category,subject=subject,state=None,facing=None,weapon_family=None,status=status,launch_scope=status not in ['REFERENCE_ONLY','REJECTED_IDENTITY_DRIFT','PLANNED_NOT_IMPLEMENTED','NOT_REQUIRED_FOR_CURRENT_LAUNCH'],canonical_source=None,source_crop=None,current_production_asset=None,target_production_path=None,dimensions=None,background=None,baseline=None,pivot_anchor=None,weapon_socket=None,support_hand_socket=None,layering_requirements=None,runtime_system=None,implementation_file=None,dependency=[],blocker=None,priority='P2',acceptance_status='BETA / owner visual acceptance open' if status=='LIVE_BETA' else 'OPEN',evidence=None)
        row.update(extra);rows.append(row);return row
    # Exact current weapon/state/view slots, preserving coverage and shared packages.
    for cell in missing['missing']+missing['coverage']:
        absent='asset_path' not in cell;actor=cell['game_id'];state=cell['state'];face=cell['facing'];weapon=cell.get('weapon_family')
        category=cell.get('category','playable')
        boss=boss_sources.get((actor,state,face)) or enemy_sources.get((actor,state,face)) or npc_sources.get((actor,state,face))
        if boss:cell={**cell,'asset_path':boss['asset_path'],'source_canonical_sheet':boss['source_reference']};absent=False
        source=cell.get('source_canonical_sheet'); asset=cell.get('asset_path')
        if actor in npc_authorities:source=npc_authorities[actor]['canonical_source']
        if not absent:
            spec=pose_sources.get(asset,{});crop=crop_sources.get(asset,{})
            source=crop.get('source',spec.get('source_reference',source))
            cell={**cell,'canvas':crop.get('canvas',spec.get('canvas',[512,512])),'baseline':{'rig_local_y':spec.get('feet_baseline'),'renderer_ground_y':548},'anchor':{'body_rect':spec.get('body_rect'),'core_normalized':spec.get('core_anchor')},'hand_socket_coordinates':{'primary_normalized':spec.get('primary_anchor'),'secondary_normalized':spec.get('secondary_anchor'),'coordinate_space':'existing authored frame normalized canvas'},'hand_support_requirement':spec.get('supports_two_hand',False)}
        package=actor+'__'+face
        add('pose:'+actor+':'+state+':'+face+':'+str(weapon),category,actor,'NEEDS_NEW_CANON_EXPORT' if absent else 'LIVE_BETA',game_id=actor,state=state,facing=face,weapon_family=weapon,canonical_source=source,current_production_asset=asset,target_production_path=asset or 'art/production/phase4e/'+('lootlings' if actor in ['relic_beast','emberhorn','mosskin','moonkip','pebblewyrm','glimmerfin','gloomlet'] else 'wanderers' if category=='playable' else 'npcs' if category=='resident' else 'bosses' if category=='boss' else 'enemies')+'/'+actor+'/'+actor+'_'+slug(state)+('_'+weapon if weapon else '')+'_'+face+'.png',dimensions=cell.get('canvas',[512,512]),background='transparent RGBA',baseline=cell.get('baseline'),pivot_anchor=cell.get('anchor'),weapon_socket=cell.get('hand_socket_coordinates'),support_hand_socket=cell.get('hand_support_requirement'),layering_requirements='Preserve body/weapon depth, existing target facing, paw contact, support/nock/paired sockets; no baked replacement identity',runtime_system='weapon_fit_catalog / creature_renderer' if category=='playable' else 'boss_presentation' if category=='boss' else 'regional_enemy_presentation / resident_art_catalog',implementation_file='weapon_fit_catalog.gd' if category=='playable' else 'boss_presentation.gd' if category=='boss' else 'resident_art_catalog.gd' if category=='resident' else 'regional_enemy_presentation.gd',dependency=[package],blocker='Exact canonical state/view/support source is unavailable; rig-ready targets are not invented source-pixel palms' if absent else None,priority='P0' if actor in ['relic_beast','moonkip','gloomlet','act_i'] else 'P1')
        if absent:
            rows[-1]['blocker']=cell.get('why_existing_source_cannot_close',rows[-1]['blocker'])
            rows[-1]['evidence']=cell.get('reuse_search')
    for entry in extraction['entries']:
        add('export:'+entry['id'],entry['kind'],entry['id'],canonical_source=entry['source'],source_crop=entry.get('crop'),current_production_asset=entry['asset_path'],target_production_path=entry['asset_path'],dimensions=entry['canvas'],background='transparent RGBA' if entry['transparent'] else 'opaque painted portrait',game_id=entry.get('actor',entry['id']),state='expression' if entry['kind']=='expression_portrait' else 'inventory glyph' if entry['kind'] in ['weapons','hud'] else 'source pose',runtime_system='phase4e_extracted_art / authored_pose_manifest / LootlingsUI',implementation_file='phase4e_extracted_art.gd',evidence={'source_sha256':entry['source_sha256'],'asset_sha256':entry['asset_sha256'],'restrictions':entry['restrictions']})
    # Actual runtime content definitions (top-level records, not guessed board labels).
    specs={
      'lootling_catalog.gd':('playable',['ENTRIES']), 'wanderer_catalog.gd':('playable',['PRESETS','LINEAGES','ORIGINS','VOICES','VISUAL_STYLES','APPEARANCE_SLOTS','COMPONENTS']),
      'item_catalog.gd':('equipment',['ITEMS']), 'phase3_item_catalog.gd':('equipment',['ITEMS']), 'phase4_catalog.gd':('equipment',['ITEMS','FARMS','HUMANS']), 'phase4b_catalog.gd':('equipment',['ITEMS']),
      'weapon_catalog.gd':('weapon',['FAMILIES','EVOLUTION_TRAITS','PROJECTILES']), 'game_catalog.gd':('perk',['UPGRADES']), 'affix_catalog.gd':('affix',['AFFIXES','SIGNATURES']),
      'zone_catalog.gd':('world',['ZONES']), 'campaign_system.gd':('world',['ORDER','REGIONAL_VARIANTS']), 'world_content_catalog.gd':('world',['FUTURE_ZONES','ENCOUNTER_ARCHETYPES']),
      'enemy_variant_catalog.gd':('elite',['VARIANTS']), 'boss_presentation.gd':('boss',['PROFILES']), 'boss_patterns.gd':('boss',['PATTERNS']),
      'expedition_event_catalog.gd':('event',['EVENTS']), 'chest_catalog.gd':('chest',['CHESTS']), 'vignette_catalog.gd':('story',['RESIDENTS','BOSS_ENTRIES','REGIONAL_BOSS_IDS']), 'field_notes_catalog.gd':('story',['CATEGORIES']),
      'world_story.gd':('story',['ORIGINS','NPC_NOTES','LOOTLINGS','REGIONS','RESIDENT_REACTIONS']), 'contextual_dialogue.gd':('dialogue',['LINES','PERSONALITY','GREETINGS']),
      'relic_spin_catalog.gd':('reward',['POOL','TIERS']), 'reward_reveal_catalog.gd':('reward',['RARITY_PROFILES','CHEST_PROFILES'])}
    specs.update({'companion_catalog.gd':('companion',['ENTRIES']), 'regional_enemy_presentation.gd':('enemy',['ENTRIES']), 'achievement_manager.gd':('achievement',['DEFINITIONS']), 'audio_manager.gd':('audio_hook',['BASE_EVENT_SPECS','MUSIC_PATHS','VARIANT_EVENTS']), 'voice_identity.gd':('audio_hook',['PLAYER_PROFILES']), 'projectile_presentation.gd':('projectile',['COLORS'])})
    def strings(obj):
        if isinstance(obj,str):yield obj
        elif isinstance(obj,dict):
            for v in obj.values():yield from strings(v)
        elif isinstance(obj,list):
            for v in obj:yield from strings(v)
    for filename,(category,constants) in specs.items():
        for constant in constants:
            data=runtime.get(filename,{}).get('constants',{}).get(constant,{})
            records=list(data.items()) if isinstance(data,dict) else [(str(v.get('id',i)) if isinstance(v,dict) else str(i),v) for i,v in enumerate(data)] if isinstance(data,list) else [('value',data)]
            for key,value in records:
                if isinstance(value,dict) and 'resource_path' in value:continue
                subject=str(value.get('id',value.get('name',key))) if isinstance(value,dict) else key
                status='LIVE_BETA'
                if filename=='world_content_catalog.gd':status='REFERENCE_ONLY' # source metadata, actual campaign IDs indexed separately
                if filename=='chest_catalog.gd' and isinstance(value,dict) and value.get('status') in ['FUTURE','DEFINED_DATA','ASSET_NEEDED']:status='PLANNED_NOT_IMPLEMENTED'
                r=add('content:'+filename+':'+constant+':'+key,category,subject,status,game_id=str(value.get('id',key)) if isinstance(value,dict) else str(value) if filename=='campaign_system.gd' and constant=='ORDER' else slug(subject),runtime_system=filename.removesuffix('.gd'),implementation_file=filename,evidence={'constant':constant,'key':key,'actual_definition':value},dependency=[filename])
                for index,line in enumerate(strings(value)):
                    if len(line)<16 or line.startswith(('res://','#')):continue
                    add('text:'+r['slot_id']+':'+str(index),'player_text',subject,status,state='authored text',runtime_system=r['runtime_system'],implementation_file=filename,evidence={'text':line,'owner':r['slot_id']})
    # Each implemented UI entry point, including popups/Back/reward states.
    screens=[]
    for filename,info in runtime.items():
        if filename not in ['lootling.gd','personal_home.gd','hub_navigation.gd'] and not any(term in filename for term in ['ui','startup','retention','dialogue','result','pause','combat_controls','settings','tutorial','vignette']):continue
        for method in info['methods']:
            if not method.startswith(('show_','build_','open_','draw_','refresh_')):continue
            r=add('screen:'+filename+':'+method,'ui',method,runtime_system=filename.removesuffix('.gd'),implementation_file=filename,state=method,layering_requirements='Single active screen/input owner; decorative art ignores input; portrait scroll/release protection',dependency=['touch_ux.gd','safe_area_layout.gd']);screens.append(r)
    # Individual script-authored player-visible labels/status strings, stable by file+line+digest.
    for filename,text in texts.items():
        for number,line in enumerate(text.splitlines(),1):
            if not re.search(r'(\.text\s*=|draw_string\(|set_text\()',line):continue
            for literal_index,literal in enumerate(re.findall(r'"((?:[^"\\]|\\.)+)"',line)):
                if literal.startswith(('res://','#')) or len(literal)<2:continue
                add('label:'+filename+':'+str(number)+':'+str(literal_index)+':'+hashlib.sha1(literal.encode()).hexdigest()[:8],'player_text',filename,implementation_file=filename,state='UI label',runtime_system=filename.removesuffix('.gd'),evidence={'line':number,'text':literal,'dynamic_template':True})
    # Every current production image/audio asset; references/source masters stay distinct.
    used={}
    for filename,text in texts.items():
        for path in re.findall(r'res://(art/[^"\n]+\.(?:png|svg|wav|ogg|json))',text):used.setdefault(path,[]).append(filename)
    def paths(value):
        if isinstance(value,dict):
            if str(value.get('resource_path','')).startswith('res://art/'):yield value['resource_path'][6:]
            for v in value.values():yield from paths(v)
        elif isinstance(value,list):
            for v in value:yield from paths(v)
    for filename,info in runtime.items():
        for p in paths(info):used.setdefault(p,[]).append(filename)
    for entry in extraction['entries']:used.setdefault(entry['asset_path'][6:],[]).append('phase4e_extracted_art.gd')
    new_runtime=ROOT/'art/production/phase4e/approved_missing_runtime_manifest.json'
    if new_runtime.exists():
        for entry in json.loads(read(new_runtime))['entries']:
            if entry.get('native_validated'):used.setdefault(entry['asset_path'][6:],[]).append('approved_missing_runtime_art.gd')
    for p in missing['coverage']:used.setdefault(p['asset_path'][6:],[]).append('authored_pose_manifest.gd')
    for p in enemy_rows:used.setdefault(p["asset_path"][6:],[]).append("enemy_art_manifest.gd")
    for p in npc_rows:used.setdefault(p['asset_path'][6:],[]).append('resident_art_catalog.gd')
    for p in boss_rows:used.setdefault(p['asset_path'][6:],[]).append('boss_presentation.gd')
    audio_manifest=ROOT/'art/audio/production/sources.json'
    if audio_manifest.exists():
        for record in json.loads(read(audio_manifest)).get('assets',[]):used.setdefault(str(record['asset']).replace('\\','/'),[]).append('audio_system.gd')
    for p in sorted((ROOT/'art').rglob('*')):
        if not p.is_file() or p.suffix.lower() not in ['.png','.svg','.wav','.ogg']:continue
        rel=p.relative_to(ROOT).as_posix()
        if '/source_pack_final/' in rel:continue # Packaging copies are not new runtime/canon sources.
        if '/reference/' in rel or '/source/' in rel:
            rejected=next((r for r in references['references'] if r['path'].removeprefix('res://')==rel and not r['runtime_allowed'] and not r.get('identity_authority_allowed')),None)
            add('source:'+rel,'reference',p.stem,'REJECTED_IDENTITY_DRIFT' if rejected else 'REFERENCE_ONLY',canonical_source=rel,launch_scope=False,evidence={'sha256':digest(p),'rejection':rejected},blocker='Reference is not a production state; no new canon approval inferred')
            continue
        category='audio' if '/audio/' in rel else 'world_art' if '/backgrounds/' in rel else 'brand' if '/brand/' in rel or '/app/' in rel else 'ui_art' if '/ui/' in rel else 'combat_art'
        consumers=sorted(set(used.get(rel,[])))
        # Dynamic asset families are documented explicitly by their loader directory.
        dynamic=next((filename for folder,filename in [('/weapons/','weapon_catalog.gd'),('/items/beta/','lootlings_ui.gd'),('/ui/icons/','lootlings_ui.gd'),('/ui/production/','lootlings_ui.gd'),('/wanderers/','avatar_presentation.gd'),('/lootlings/','lootling_catalog.gd'),('/audio/production/','audio_manager.gd')] if folder in '/'+rel),None)
        if dynamic and not consumers:consumers=[dynamic]
        live=bool(consumers);prototype=p.suffix=='.svg' and any(v in rel for v in ['combat_rigs','enemies/beta'])
        dimensions=None; background=None
        if p.suffix=='.png':
            with Image.open(p) as im:dimensions=list(im.size);background='RGBA' if im.mode=='RGBA' else 'opaque'
        add('asset:'+rel,category,p.stem,'LIVE_BETA' if live else 'REFERENCE_ONLY',current_production_asset=rel,target_production_path=rel,dimensions=dimensions,background=background,implementation_file=consumers,runtime_system=consumers,launch_scope=live,evidence={'sha256':digest(p),'usage':'static resource or documented dynamic loader' if live else 'retained unreferenced production/historical export'},acceptance_status='TEMP rig/proxy only' if prototype else 'BETA; owner/perceptual acceptance open',blocker='Canonical body replacement required' if prototype else None)
    # Explicit canon/planned scope, never creates NPCs or game IDs from boards.
    for name in ['Lantern Compact','Quillkeepers','Hollow Court','Unwritten']:
        add('canon:faction:'+slug(name),'story',name,'REFERENCE_ONLY',canonical_source='LOOTLINGS_WORLD_BIBLE.md',launch_scope=False,state='written lore; no faction mechanic')
    for name in ['Edda','Nessa Vale','Corvin Ash','Vesper Thread','authored pets','homestead decorations','store screenshots','store marketing banner']:
        row=add('planned:'+slug(name),'planned',name,'LIVE_BETA' if name=='homestead decorations' else 'PLANNED_NOT_IMPLEMENTED',canonical_source='LOOTLINGS_WORLD_BIBLE.md' if name!='Edda' else 'board-only Edda label, no current stable runtime ID',launch_scope=False,blocker='No implemented current runtime role; separate owner scope approval required',priority='P3')
        if name in ['authored pets','homestead decorations']:
            row['dependency'].append('docs/production/completion-sprint/OWNER_AUTHORIZATION.md')
            row['blocker']='Authored companion identity and six state/view exports open; implemented system shell is indexed separately' if name=='authored pets' else None
            row['evidence']={'implemented_shell':['companion_catalog.gd','companion_presentation.gd','profile_store.gd'] if name=='authored pets' else ['hideout_ui.gd','profile_store.gd'],'limitations':'No new art or stat advantage; bounded shelf choices use accepted assets'}
    historical=json.loads(read(ROOT/'art/reference/docs/lootlings_master_catalog_v1.json'))
    for category,content in historical.items():
        if category in ['meta','pillars']:continue
        records=list(content.items()) if isinstance(content,dict) else [(str(i),v) for i,v in enumerate(content)] if isinstance(content,list) else [('value',content)]
        for key,record in records:
            subject=str(record.get('id',record.get('name',key))) if isinstance(record,dict) else key
            drift=category=='npcs' and subject=='patch'
            add('historical-design:'+category+':'+key,'historical_design',subject,'REJECTED_IDENTITY_DRIFT' if drift else 'REFERENCE_ONLY',canonical_source='art/reference/docs/lootlings_master_catalog_v1.json',launch_scope=False,evidence=record,blocker='Historical goblin Patch contradicts established adult Patch; written current canon wins' if drift else 'Historical design record only; current runtime/canon controls implementation')
    for zone in runtime['zone_catalog.gd']['constants']['ZONES']:
        for role,enemy in zone['enemies'].items():
            add('encounter-enemy:'+enemy['id'],'enemy',enemy['name'],game_id=enemy['id'],state=role,runtime_system='Act I zone encounter',implementation_file='zone_catalog.gd',canonical_source='current Act I enemy assets and stable IDs',evidence={'zone':zone['id'],'role':role})
        if zone['miniboss']:
            add('miniboss:'+zone['miniboss'],'miniboss',zone['miniboss'],game_id=zone['miniboss'],implementation_file='lootling.gd',canonical_source='art/sprites/enemies/grump_knight.png',current_production_asset='art/sprites/enemies/grump_knight.png',state='current miniboss encounter')
    # Every historical launch-scope spec stays traceable without being blindly promoted.
    with (ROOT/'art/reference/docs/LOOTLINGS_ASSET_MANIFEST_v1.csv').open(encoding='utf-8-sig',newline='') as file:
        for i,record in enumerate(csv.DictReader(file)):
            add('planned-spec:'+record['asset_id'],'planned_spec',record['subject'],'NOT_REQUIRED_FOR_CURRENT_LAUNCH',state=record['state'],canonical_source='art/reference/docs/LOOTLINGS_ASSET_MANIFEST_v1.csv',launch_scope=False,evidence=record,blocker='Historical broad art target; current stable-ID contracts and live slots above override it',priority='P3')
    # Every engine/runtime presentation subsystem is separately indexed, including VFX/SFX/branding/hooks.
    for filename,info in runtime.items():
        add('system:'+filename,'runtime_system',filename,implementation_file=filename,runtime_system=filename,state='implementation/hook',evidence={'methods':info['methods']})
    statuses=Counter(r['status'] for r in rows);launch=Counter(r['status'] for r in rows if r['launch_scope'])
    sources=[p for p in [ROOT/n for n in ['DESIGN_BIBLE.md','LOOTLINGS_WORLD_BIBLE.md','MASTER_ROADMAP.md','CONTENT_IMPLEMENTATION_STATUS.md','ART_REFERENCE_INDEX.md','PRODUCTION_PHASE4E.md','docs/production/phase4e/polish/ART_EXPORT_CONTRACT.md','export_presets.cfg','art/production_pose_manifest.json','art/production_boss_manifest.json','art/production/phase4e/runtime_manifest.json','art/production/phase4e/extraction_manifest.json','art/reference/phase4e_handoff/REFERENCE_STATUS.json','docs/production/phase4e/extraction/MISSING_ART_MANIFEST.json','art/audio/production/sources.json']]+list((ROOT/'art/reference/docs').glob('*'))+list(ROOT.glob('*.gd')) if p.is_file()]
    data=dict(schema_version=1,authority='Stable IDs/written canon remain identity authority; this manifest is the permanent derivative production routing/status index. Do not override owner canon or mark BETA final automatically.',baseline='11cd6c49f62972597eec8426a344226da031fe25 / Android v25',refresh='Run isolated tools/master_runtime_inventory.gd, then tools/recalculate_phase4e_art.py and tools/build_master_integration.py; tools/validate_master_integration.py detects stale inputs/outputs',statuses=STATUSES,counts=dict(total_records=len(rows),total_launch_scope_slots=sum(launch.values()),all_statuses={s:statuses[s] for s in STATUSES},launch_statuses={s:launch[s] for s in STATUSES},exact_missing_art_cells=missing['total_missing_cells'],support_packages=sum(missing['complete_support_family_debt_recalculated'].values())),source_hash_encoding='UTF8 text, LF line endings, no BOM; source image/audio evidence retains raw SHA256',source_inputs={p.relative_to(ROOT).as_posix():input_digest(p) for p in sources},records=rows)
    data['source_inputs']['art/production/phase4e/reuse_manifest.json']=input_digest(ROOT/'art/production/phase4e/reuse_manifest.json')
    data['source_inputs']['art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json']=input_digest(ROOT/'art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json')
    data['source_inputs']['art/production/phase4e/props/source_manifest.json']=input_digest(ROOT/'art/production/phase4e/props/source_manifest.json')
    for new_input in ['art/approved_missing_canon_references.json','art/production/phase4e/approved_missing_runtime_manifest.json','art/npc_identity_authorities.json','art/production/companions/runtime_manifest.json','art/production_enemy_manifest.json','art/production_npc_manifest.json','art/production/phase4e/player_batch_043_manifest.json']:
        if (ROOT/new_input).exists():data['source_inputs'][new_input]=input_digest(ROOT/new_input)
    dump(OUT/'MASTER_INTEGRATION_MANIFEST.json',data)
    def write_csv(name,records):
        fields=list(rows[0]);
        with (OUT/name).open('w',encoding='utf-8-sig',newline='') as f:
            w=csv.DictWriter(f,fieldnames=fields);w.writeheader()
            for r in records:w.writerow({k:json.dumps(v,ensure_ascii=False) if isinstance(v,(list,dict)) else v for k,v in r.items()})
    write_csv('MASTER_INTEGRATION_MANIFEST.csv',rows)
    write_csv('CHARACTER_POSE_MATRIX.csv',[r for r in rows if r['category']=='playable' and r['slot_id'].startswith('pose:')])
    write_csv('BOSS_ASSET_MATRIX.csv',[r for r in rows if r['category']=='boss'])
    write_csv('ENEMY_ASSET_MATRIX.csv',[r for r in rows if r['category'] in ['regional enemy','enemy','elite']])
    # One body package per stable actor + facing; lists shared poses and support families once.
    packages={}
    for row in rows:
        if row['status']!='NEEDS_NEW_CANON_EXPORT':continue
        key=row['dependency'][0];pkg=packages.setdefault(key,dict(package_id=key,game_id=row['game_id'],category=row['category'],facing=row['facing'],canonical_sources=row['canonical_source'],canvas=row['dimensions'],background=row['background'],baseline=row['baseline'],anchor=row['pivot_anchor'],layering_rules=row['layering_requirements'],reusable_rig=True,states={},existing_source_sockets='See art/production/phase4e/runtime_manifest.json and each delivery cell; actual missing source pixels are OPEN, not invented',temp_evidence='docs/production/phase4e/extraction/GALLERY.md',no_redesign=True))
        state=pkg['states'].setdefault(row['state'],dict(weapon_families=[],requirements=[]))
        if row['weapon_family'] not in state['weapon_families']:state['weapon_families'].append(row['weapon_family'])
        state['requirements'].append(dict(slot_id=row['slot_id'],weapon_family=row['weapon_family'],primary_socket=row['weapon_socket'],support_socket=row['support_hand_socket'],target_path=row['target_production_path']))
        state['requirements'][-1]['why_existing_source_cannot_close']=row['blocker']
        state['requirements'][-1]['existing_source_search']=row['evidence']
        delivery=state['requirements'][-1]
        delivery['purpose']=row['state']+' / '+str(row['facing'])+' / '+str(row['weapon_family'] or row['category'])
        delivery['weapon_contract']='Exact family-specific export; a baked weapon must be declared and restricted. Otherwise deliver intact weaponless hands and separate equipment layers.' if row['weapon_family'] else 'Preserve established authored equipment/props for this entity; no interchangeable proxy.'
        delivery['source_scale']='Deliver at requested canvas dimensions with uniform scale and complete source silhouette; no stretch or invented covered pixels.'
        delivery['allowed_baked_vfx']='Permanent canonical markings/glow only; any source-baked temporal effect requires explicit state restriction and provenance.'
        delivery['separate_vfx']='Trails, charge, impact, damage flash, status, reward burst and floor/contact particles remain separate runtime layers.'
        delivery['expected_filename']=Path(row['target_production_path']).name
        delivery['runtime_destination']=row['target_production_path']
        delivery['source_destination']='art/source/phase4e/delivery/'+row['game_id']+'/'+delivery['expected_filename']
        delivery['entity']=row['game_id']
        delivery['state']=row['state']
        delivery['facing']=row['facing']
        delivery['canvas']=row['dimensions']
        delivery['transparent_background']=True
        delivery['baseline']=row['baseline']
        delivery['pivot']=row['pivot_anchor']
        delivery['canonical_reference']=row['canonical_source']
        delivery['socket_sidecar_filename']=Path(delivery['expected_filename']).with_suffix('.json').name
        delivery['integration_contract']='Sidecar declares exact state/view/family, actual primary/secondary palms, Core, ground, foreground fingers, and baked equipment. Register approved delivery in the existing per-state manifest; never route another state implicitly. Compatible identical bodies may share a single PNG only after family socket validation.'
        delivery['occupied_bounds']={'canvas_inset_pixels':16,'maximum_bounds':[16,16,row['dimensions'][0]-16,row['dimensions'][1]-16],'rule':'Full silhouette inside these bounds; match per-ID proportions and existing ground target, not a stretched square.'}
        delivery['mirroring_allowed']=False
        delivery['visible_anatomy']='Complete head/ears, torso/hips, source-authored limbs, feet/tail and relevant hands; palms/grips must not be obscured by charge, trails, sheet text or another pose. Do not reconstruct covered anatomy.'
        delivery['required_pose']={'idle':'Grounded neutral ready pose; complete canonical silhouette and actual equipment-contact palms.', 'movement':'Authored movement step with complete feet and stable weapon contact; do not relabel a neutral frame.', 'windup':'Readable anticipation toward active target, body weight prepared behind the release, hands attached to their grips.', 'strike_or_cast':'Authored target-directed strike or casting release; lead hand/weapon drives the action.', 'follow_through':'Actual committed strike/release frame before recovery; preserve limbs, contact and body weight.', 'recovery':'Authored controlled return toward the neutral baseline; no invented idle/strike relabel.', 'hurt':'Authored recoil with intact head, feet and weapon/contact hands.', 'defeat':'Recognizable authored defeated pose; complete anatomy and equipment layers.', 'victory_return':'Authored victory-to-ready return matching the same canonical identity.'}.get(row['state'],'Exact named '+row['state']+' state of this established entity; follow its existing route/attack clocks without redesign.')
        delivery['separate_layers_required']=['foreground grip fingers when equipment passes behind the palm','family weapon module unless explicitly declared source-baked','second independent weapon and palm for paired families','bowstring/nocked arrow and drawing palm for Bow','temporal charge/trail/impact/status VFX separate from body'] if row['category']=='playable' else ['named attack VFX and launch points separate from canonical body','activity props with actual hand/contact metadata where required']
        stem=Path(delivery['expected_filename']).stem
        delivery['layer_filenames']={'body':delivery['expected_filename'],'metadata':delivery['socket_sidecar_filename'],'foreground_grip_if_needed':stem+'_grip_front.png','support_hand_if_needed':stem+'_support.png','separate_temporal_vfx_if_required':stem+'_vfx.png'}
        delivery['current_temp_replacement']=row['slot_id']+'; existing unapproved/missing authored-state presentation is not final art.'
        delivery['priority']=row['priority']
    debt=json.loads(read(ROOT/'docs/production/phase4e/polish/support-art-debt.json'))['by_facing']
    sources_by_actor={r.get('actor'):r['source'] for r in extraction['entries'] if r.get('actor') and r['kind']=='body'}
    wanderers=runtime['wanderer_catalog.gd']['constants']['PRESETS']
    for pkg in packages.values():
        actor=pkg['game_id'];images=[]
        if actor in sources_by_actor:images=[sources_by_actor[actor]]
        elif actor in wanderers:
            images=[p.relative_to(ROOT).as_posix() for p in (ROOT/'art/sprites/wanderers').rglob(actor+'_idle.png')]
        elif actor in ['patch','ilex','sera']:images=['art/sprites/npcs/beta/'+actor+'_idle.png','art/sprites/npcs/beta/'+actor+'_portrait.png']
        elif actor=='act_i':images=[json.loads((ROOT/'art/hoard_dragon_identity_authority.json').read_text(encoding='utf-8'))['canonical_source']] if (ROOT/'art/hoard_dragon_identity_authority.json').exists() else ['art/sprites/enemies/hoard_dragon.png']
        elif actor in ['mossglass_wilds','cinder_crown']:images=['art/sprites/enemies/beta/'+('verdant_mirror' if actor=='mossglass_wilds' else 'furnace_regent')+'.png']
        if actor in npc_authorities:
            images=[npc_authorities[actor]['canonical_source']];pkg['canonical_sources']=['res://'+images[0]]
            pkg['owner_reference_approval']=npc_authorities[actor]['authority']
        approval=ROOT/'art/approved_missing_canon_references.json'
        approved=next((e for e in json.loads(read(approval))['entries'] if e['game_id']==actor),None) if approval.exists() else None
        if approved:
            assert not images,'Do not override existing dedicated canon'
            images=[approved['source']];pkg['canonical_sources']=['res://'+approved['source']]
            pkg['owner_reference_approval']=approved['owner_approval']
        pkg['locked_source_images']=[dict(path=p,sha256=digest(ROOT/p)) for p in images]
        pkg['visual_source_gate']='MATCH_EXISTING_CANON_EXACTLY' if images else 'OPEN: written identity only; canonical visual must be owner-approved before final production art. Never copy current procedural/proxy body as canon.'
        pkg['scale_rules']='Uniform scale only, retain complete silhouette and original anatomy. No automatic opposite-view mirror of asymmetric gear/paws.'
        pkg['source_metadata_delivery']='PNG plus JSON: actual per-state primary/secondary palm pixels, Core, ground baseline/pivot, support/nock and foreground layers. Existing rig target coordinates are in state requirements; actual source coordinates remain unknown until a real frame exists.'
    supplemental=[x['external_art_requirement'] for x in json.loads(read(OUT/'phase4e/canon-world/LATER_SYSTEM_INTEGRATION.json'))['items'] if 'external_art_requirement' in x]
    dump(OUT/'NEEDS_NEW_CANON_EXPORT.json',dict(supplemental_runtime_art_requirements=supplemental,authority='Existing locked identity; final production art cannot be inferred from rejected boards',count_unit='body/view bundles, each containing reusable pose states plus exact family/socket restrictions; not unique files per delivery cell',body_view_packages=len(packages),delivery_cells=missing['total_missing_cells'],support_packages_recalculated=debt,packages=list(packages.values()),notes=['One body pose can support multiple families only after actual socket/occlusion validation. Heavy READY/RELEASE exports already share three families.','Paired/support packages are additive hand/weapon/layer delivery, not thousands of copied complete bodies. Existing 165 count remains after exact matrix rerun.','Moonkip weaponless 512x512 original hooded anatomy is mandatory. Dragon follows art/hoard_dragon_identity_authority.json: owner-restored winged quadruped with one continuous tail; old coiled runtime is superseded.','Request actual source-pixel hand/pivot metadata from authored art; rig coordinates are delivery targets, not fabricated source anatomy.']))
    summary=['# Permanent master integration manifest','','Current launch/runtime inventory; established canon and stable IDs override all board labels. All current visuals remain LIVE_BETA until explicit final owner acceptance; zero LIVE_FINAL is intentional. This is an inventory of slots, not a claim that every slot is a unique illustration.','','| Status | All records | Current launch slots |','|---|---:|---:|']
    summary += [f'| {s} | {statuses[s]} | {launch[s]} |' for s in STATUSES]
    summary += ['',f'Total records: **{len(rows)}**. Current launch-scope slots: **{sum(launch.values())}**.',f'Exact missing art delivery cells: **{missing["total_missing_cells"]}** grouped into **{len(packages)} body/view bundles**. Whole support packages: **{sum(debt.values())}** ({debt["right"]} right / {debt["left"]} left), from authoritative full-state acceptance; partial windup samples do not close a family.','', f'The {missing["total_missing_cells"]} cells keep their individual state/view/family contracts. Shared body poses and weapon modules group into body/view bundles; the separate support-package count must not be added as unique images. No repeated neutral art, tint substitute or fake movement/attack export closes a slot.','', 'Refresh: isolated Godot reflection → existing exact art recalc → tools/build_master_integration.py. The reflection uses the official [Script constant/method API](https://docs.godotengine.org/en/stable/classes/class_script.html). CSV and JSON are generated together. Do not edit generated rows by hand; update the underlying catalogs or extraction/approval contracts, regenerate and validate.','', 'Historical 2026-09/Phase2 broad scope is retained as NOT_REQUIRED_FOR_CURRENT_LAUNCH spec records. Edda is a board-only unimplemented label, not a promoted Home NPC. Existing Patch/Ilex/Sera and Pack Peddler remain current. The owner now authorizes a bounded companion shell and Home shelf customization; authored pet identity/frames remain open. Future NPC and store art records remain separate.','', 'Runtime assembly opportunities: shared UI icon resource resolution, item-ID→elemental glyph mapping, cached source portraits and compatible heavy pose modules. Accepted canonical extraction, five compatible rune glyphs and resolved inline UI icons are preserved. See START_HERE_CURRENT for the latest checkpoint and next work. Exact art gaps and separate save/audio/owner/device gates remain HOLD.','', '[One consolidated art production package](NEEDS_NEW_CANON_EXPORT.json) · [current status and evidence](START_HERE_CURRENT.md)']
    summary=[line.replace('The 3097 cells',f'The {missing["total_missing_cells"]} cells') for line in summary]
    summary+=['','Preserved accepted reuse: five unchanged Wanderer neutral bodies and seven compatible sling views previously replaced 32 TEMP state/family/view cells. All opposite-facing, attack and full support gaps remain explicit. [Before/after evidence](phase4e/reuse-canon/GALLERY.md).']
    (OUT/'MASTER_INTEGRATION_SUMMARY.md').write_text('\n'.join(summary)+'\n',encoding='utf-8')
    for name,categories in [('STORY_CONTENT_MAP.md',['story','dialogue','event']),('UI_SCREEN_MAP.md',['ui']),('WORLD_REGION_MAP.md',['world','world_art','chest'])]:
        lines=['# '+name.removesuffix('.md').replace('_',' ').title(),'','Stable runtime IDs/implementation paths. LIVE_BETA is implemented, not final owner acceptance. Historical/reference metadata never replaces current campaign order.','', '| Slot | ID / subject | Status | Implementation |','|---|---|---|---|']
        lines += ['| '+r['slot_id']+' | '+str(r['game_id'])+' / '+str(r['subject'])+' | '+r['status']+' | '+str(r['implementation_file'])+' |' for r in rows if r['category'] in categories]
        (OUT/name).write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print(json.dumps(data['counts'],indent=2))
if __name__=='__main__':main()
