"""Recalculate explicit state/view/family debt after real source extraction.

Counts are delivery cells, not a demand for a unique image per cell. Compatible
families may share one authored asset, as existing heavy exports already do.
"""
from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'docs/production/phase4e/extraction'
WEAPONS=['greatsword','greataxe','maul','spear','daggers','claws','bow','crossbow','sling','staff','wand','orb']
STATES=['idle','movement','windup','strike_or_cast','follow_through','recovery','hurt','defeat','victory_return']
GROUPS={'heavy_two_hand':['greatsword','greataxe','maul'],'polearm':['spear'],'staff':['staff']}

def main():
    BASE.mkdir(parents=True,exist_ok=True)
    requests=json.loads((ROOT/'docs/production/phase4e/polish/replacement-export-requests.json').read_text(encoding='utf-8'))
    poses=json.loads((ROOT/'art/production_pose_manifest.json').read_text())['entries']
    extracted=json.loads((ROOT/'art/production/phase4e/runtime_manifest.json').read_text())['entries']
    extracted+=json.loads((ROOT/'art/production/phase4e/reuse_manifest.json').read_text())['entries']
    extracted+=json.loads((ROOT/'art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json').read_text())['entries']
    batch=ROOT/'art/production/phase4e/player_batch_043_manifest.json'
    if batch.exists():extracted += [r for r in json.loads(batch.read_text())['entries'] if r.get('native_validated') and r.get('production_status')=='canon_validated_runtime']
    motion=ROOT/"art/production/phase4e/player_motion_044_manifest.json"
    if motion.exists():extracted += [r for r in json.loads(motion.read_text())["entries"] if r.get("native_validated") and r.get("production_status")=="canon_validated_runtime"]
    combat=ROOT/'art/production/phase4e/player_combat_045_manifest.json'
    if combat.exists():extracted += [r for r in json.loads(combat.read_text(encoding='utf-8-sig'))['entries'] if r.get('native_validated') and r.get('production_status')=='canon_validated_runtime']
    coverage={}; before={}; cells=[]
    for row in poses:
        if row['production_status']!='authored_beta':continue
        states=['idle','windup'] if row['phase']=='READY' else ['strike_or_cast','follow_through'] if row['phase']=='RELEASE' else []
        if row['actor']=='relic_beast' and row['phase']=='RELEASE':states+=['recovery']
        for weapon in row.get('weapon_types',GROUPS.get(row['stance'],[])):
            for state in states:
                key=(row['actor'],state,row['facing'].removesuffix('_only'),weapon)
                before[key]=row['asset_path'];coverage[key]=row['asset_path']
    for row in extracted:
        for weapon in row['weapon_types']:
            states={'IDLE':['idle'],'ANTICIPATE':['windup'],'ATTACK':['strike_or_cast'],'IMPACT':['follow_through'],'RECOVER':['recovery'],'HURT':['hurt'],'MOVE':['movement'],'VICTORY':['victory_return'],'DEFEAT':['defeat']}
            assert row['phase'] in states,'Unproven extracted state: '+row['phase']
            for state in ([row['state']] if row.get('contract_slot_id') and row.get('state') else states[row['phase']]):
                key=(row['actor'],state,row['facing'].removesuffix('_only'),weapon)
                assert key not in before,'Must not overwrite good authored coverage'
                # An ATTACK frame may remain a runtime fallback during later
                # phases, but cannot close a distinct follow-through contract.
                if key not in coverage or row['phase']=='IMPACT':coverage[key]=row['asset_path']
    for req in requests['requests']:
        if req['category']!='playable':continue
        actor=req['asset_id'];canvas=req['required_canvas'];source=re.findall(r'res://[^` ]+',req['canonical_identity'])
        for state in STATES:
            for facing in ['right','left']:
                for weapon in WEAPONS:
                    if (actor,state,facing,weapon) in coverage:continue
                    hand='two palms plus bow draw/nock' if weapon=='bow' else 'two shaft/stock palms' if weapon in ['greatsword','greataxe','maul','spear','crossbow','staff'] else 'two distinct palms, alternating lead, foreground fingers' if weapon in ['daggers','claws'] else 'primary palm; source-authored secondary hand must remain intact'
                    # Exact existing rig target coordinates, not fabricated
                    # source-art hand pixels. Artist supplies the corresponding
                    # actual source palms/foreground layer on delivery.
                    primary=[48,-29] if weapon in ['bow','crossbow'] else [34,-19] if weapon in ['daggers','claws'] else [40,-17]
                    secondary=[14,-25] if weapon in ['bow','crossbow'] else [10,-1] if weapon in ['daggers','claws'] else [12,-8]
                    cells.append(dict(game_id=actor,category='playable',state=state,facing=facing,weapon_family=weapon,hand_support_requirement=hand,canvas=canvas,transparent_background=True,baseline=dict(renderer_ground_y=548,rig_local_y=64,target_canvas_y=canvas[1]-16),anchor=dict(rig_local=[0,0],target_canvas=[canvas[0]/2,canvas[1]*2/3]),hand_socket_coordinates=dict(coordinate_space='existing rig local units; initial READY target, phase-specific source artist alignment required',primary=primary,secondary=secondary,source_palm_pixels=None,source_pixels_status='OPEN until the actual requested state is authored; do not invent anatomy to meet a coordinate'),scale_restrictions='uniform only; full silhouette; preserve source aspect; no body mirror if accessories/anatomy differ',source_canonical_sheet=source or [req['canonical_identity']],rig_reuse=True))
    playable_count=len(cells)
    other_before=0
    approved_refs={e['game_id']:e for e in json.loads((ROOT/'art/approved_missing_canon_references.json').read_text())['entries']} if (ROOT/'art/approved_missing_canon_references.json').exists() else {}
    approved_frames=json.loads((ROOT/'art/production/phase4e/approved_missing_runtime_manifest.json').read_text())['entries'] if (ROOT/'art/production/phase4e/approved_missing_runtime_manifest.json').exists() else []
    for req in requests['requests']:
        if req['category']=='playable':continue
        states=[]
        for original in req['required_states']:
            if original.endswith(' windup/commit/recovery'):
                action=original.removesuffix(' windup/commit/recovery')
                if action in ['RECOVER','COOLING']:states.append(action+' recovery')
                else:states.extend(action+' '+phase for phase in ['windup','commit','recovery'])
            elif original=='vulnerability/recovery':states.extend(['vulnerability','recovery'])
            else:states.append(original)
        for state in dict.fromkeys(states):
            for facing in req['views']:
                if any(e['actor']==req['asset_id'] and e['state']==state and e['facing']==facing and e.get('native_validated') for e in approved_frames):continue
                other_before+=1;canvas=req['required_canvas']
                cells.append(dict(game_id=req['asset_id'],category=req['category'],state=state,facing=facing,weapon_family=None,hand_support_requirement=req['socket_metadata'],canvas=canvas,transparent_background=True,baseline=dict(renderer_ground_y=548 if req['category']!='resident' else None,target_canvas_y=canvas[1]-32,source_ground_or_hover_pixels=None),anchor=dict(target_canvas=[canvas[0]/2,canvas[1]-32],source_pivot_pixels=None),hand_socket_coordinates=dict(source_pixels=None,status='OPEN: no approved articulated source palms/launch pixels exist; supply actual authored coordinates, never inferred board anatomy'),scale_restrictions='uniform only; uncropped full silhouette; reuse current per-ID bounds/routes/attack clocks; no proxy or board redesign',source_canonical_sheet=req['canonical_identity'],rig_reuse=True))
    merchant=requests['current_merchant_requirement']
    for state in merchant['states']:
        for facing in merchant['views']:
            other_before+=1
            cells.append(dict(game_id='pack_peddler',category='current merchant role',state=state,facing=facing,weapon_family=None,hand_support_requirement=merchant['sockets'],canvas=merchant['canvas'],transparent_background=True,baseline={'target_canvas_y':1504,'source_pixels':None},anchor={'target_canvas':[512,1504],'source_pixels':None},hand_socket_coordinates={'source_pixels':None,'status':'OPEN, exact authored palms/offer prop needed'},scale_restrictions='uniform; established merchant role, not a new Home NPC',source_canonical_sheet=merchant['canon'],rig_reuse=True))
    source_rows=poses+extracted
    npc_authorities={e['id']:e for e in json.loads((ROOT/'art/npc_identity_authorities.json').read_text())['entries']} if (ROOT/'art/npc_identity_authorities.json').exists() else {}
    for cell in cells:
        if cell['game_id'] in npc_authorities:cell['source_canonical_sheet']=['res://'+npc_authorities[cell['game_id']]['canonical_source']]
        if cell['game_id'] in approved_refs:cell['source_canonical_sheet']=['res://'+approved_refs[cell['game_id']]['source']]
        candidates=sorted({row['asset_path'] for row in source_rows if row.get('actor')==cell['game_id'] and row.get('production_status')!='temporary_proxy' and row.get('asset_path')})
        cell['reuse_search']={'accepted_state_manifest':'art/production_pose_manifest.json','extracted_state_manifest':'art/production/phase4e/runtime_manifest.json','direct_reuse_manifest':'art/production/phase4e/reuse_manifest.json','existing_actor_candidates':candidates}
        cell['why_existing_source_cannot_close']='No accepted source frame has this exact state/facing and hand/weapon contract. Neutral exports cannot substitute for movement/strike/hurt/defeat; an asymmetric view cannot be mirrored; source palms and support layers cannot be invented.'
        if cell['game_id'] in npc_authorities:cell['why_existing_source_cannot_close']+=' Scoped owner-approved panel is an upper-body workstation vignette with counter/background, not transparent complete anatomy. Superseded beta body/portrait may not fill this request.'
        if cell['game_id']=='moonkip':cell['why_existing_source_cannot_close']+=' Existing original hooded rogue idle has baked daggers; removal would require missing covered paw/anatomy pixels.'
        if cell['game_id'] in ['hoard_dragon','act_i']:
            cell['source_canonical_sheet']=['res://'+json.loads((ROOT/'art/hoard_dragon_identity_authority.json').read_text(encoding='utf-8-sig'))['canonical_source']]
            cell['why_existing_source_cannot_close']+=' Owner-authoritative original winged, four-legged Hoard Dragon is required; superseded wingless/coiled anatomy is not canon. Retained valid boss states do not substitute for a missing named action.'
        if not candidates:cell['why_existing_source_cannot_close']+=' Existing proxy/intro presentation is not an approved articulated state export; written regional canon constrains the eventual asset.'
    # A sampled windup contact pass cannot close a whole family across its
    # missing attack/recovery/hurt states. Retain the authoritative full matrix.
    support=json.loads((ROOT/'docs/production/phase4e/polish/support-art-debt.json').read_text())['by_facing']
    data=dict(authority='CANONICAL_REPLACEMENTS.md; actual frozen authored exports plus phase4e/runtime_manifest.json; not concept-board labels',count_unit='one game ID × actual requested state × facing × weapon family (family=null for non-playable packages)',playable_universe=12*12*2*len(STATES),playable_before=12*12*2*len(STATES)-len(before),playable_remaining=playable_count,non_playable_remaining=other_before,total_missing_cells=len(cells),new_source_cells_removed=len(coverage)-len(before),complete_support_family_debt_recalculated=support,coverage=[dict(game_id=k[0],state=k[1],facing=k[2],weapon_family=k[3],asset_path=v) for k,v in sorted(coverage.items())],missing=cells,notes=['This expanded state count is not comparable to the old165 whole support-family count. Partial idles do not close missing paired attack/recovery packages.','Body frames may be reused only where actual hand/facing/state contracts work; this is not a request for thousands of unique drawings.','Initial rig target coordinates are provided; absent actual source-art palms are explicitly null. Inventing source coordinates would violate the canon/anatomy rule.','Boss RECOVER/COOLING downtime does not request fake attacking windup/commit frames.','No Dragon board body, changed Moonkip, mushroom Gloomlet, board NPC or new region is imported.'])
    (BASE/'MISSING_ART_MANIFEST.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in data.items() if k not in ['coverage','missing','notes']},indent=2))

if __name__=='__main__':main()
