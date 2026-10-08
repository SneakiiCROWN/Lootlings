"""Gamewide artist intake. Dry-run by default; never grants visual approval.

Inbox mirrors exact source_delivery_path below its root. New interchange schemas
are not assumed to be engine manifests. Unsupported selectors remain staged.
"""
from pathlib import Path
import argparse, hashlib, json, math, re, shutil, sys, tempfile
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/production/master-art-delivery'
INBOX=ROOT/'art/source/master_artist_delivery'
STATUSES={'PASS','FAIL','NEEDS_ARTIST_CORRECTION'}
PHASES={'idle':'IDLE','windup':'ANTICIPATE','strike_or_cast':'ATTACK','recovery':'RECOVER','hurt':'HURT'}
def read(p):return json.loads(p.read_text(encoding='utf8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def safe(root,relative):
    if Path(relative).is_absolute() or '..' in Path(relative).parts or ':' in relative:
        raise ValueError('Unsafe relative path: '+relative)
    p=root/relative
    if not p.resolve().is_relative_to(root.resolve()) or p.is_symlink():raise ValueError('Path escapes root or is a symbolic link: '+relative)
    return p
def validate_schema(value,schema,path='metadata'):
    """Validate the subset used by all packaged schemas, fail on non-finite data."""
    errors=[]
    if 'anyOf' in schema:
        if not any(not validate_schema(value,s,path) for s in schema['anyOf']):return [path+': fails anyOf']
        return []
    types=schema.get('type',[]);types=[types] if isinstance(types,str) else types
    checks={'object':isinstance(value,dict),'array':isinstance(value,list),'null':value is None,'string':isinstance(value,str),'integer':type(value)==int,'number':type(value) in [int,float] and math.isfinite(value),'boolean':type(value)==bool}
    if types and not any(checks[t] for t in types):return [path+': wrong type']
    if 'const' in schema and value!=schema['const']:errors.append(path+': wrong constant')
    if 'enum' in schema and value not in schema['enum']:errors.append(path+': wrong enum')
    if isinstance(value,str) and 'pattern' in schema and not re.search(schema['pattern'],value):errors.append(path+': wrong pattern')
    if type(value) in [float,int]:
        if not math.isfinite(value):errors.append(path+': non-finite')
        for key,failed in [('minimum',lambda x:value<x),('maximum',lambda x:value>x),('exclusiveMinimum',lambda x:value<=x)]:
            if key in schema and failed(schema[key]):errors.append(path+': '+key)
    if isinstance(value,dict):
        props=schema.get('properties',{})
        errors += [path+': missing '+k for k in schema.get('required',[]) if k not in value]
        for k,v in value.items():
            if k in props:errors+=validate_schema(v,props[k],path+'.'+k)
            elif schema.get('additionalProperties') is False:errors.append(path+': unknown '+k)
            elif isinstance(schema.get('additionalProperties'),dict):errors+=validate_schema(v,schema['additionalProperties'],path+'.'+k)
    if isinstance(value,list):
        if len(value)<schema.get('minItems',0) or len(value)>schema.get('maxItems',len(value)):errors.append(path+': wrong array length')
        if 'items' in schema:
            for i,v in enumerate(value):errors+=validate_schema(v,schema['items'],path+f'[{i}]')
    return errors
def markers(x):
    if isinstance(x,str):return 'MEASURE_FROM_DELIVERED_PIXELS' in x
    if isinstance(x,dict):return any(markers(v) for v in x.values())
    if isinstance(x,list):return any(markers(v) for v in x)
    return False
def png_errors(path,contract,bounds=None,transparent=True):
    with Image.open(path) as im:
        if im.format!='PNG':return ['Not a PNG']
        errors=[]
        if list(im.size)!=contract:errors.append('Wrong canvas')
        if transparent and im.mode!='RGBA':errors.append('Required straight-alpha RGBA missing')
        if transparent and im.mode=='RGBA':
            alpha=im.getchannel('A');box=alpha.getbbox()
            if not box:errors.append('Empty silhouette/layer')
            elif alpha.getextrema()[0]>0:errors.append('Missing transparent background')
            elif bounds and not (bounds[0]<=box[0] and bounds[1]<=box[1] and box[2]<=bounds[2] and box[3]<=bounds[3]):errors.append('Alpha outside contract bounds / provable clipping')
        return errors
def review_ready(row,inbox,files,approvals):
    approval=next((x for x in approvals if x.get('slot_id')==row['slot_id']),{})
    required=['canonical_identity','anatomy','pose_facing','contact_fit','baked_modular_equipment_absent','temporal_vfx_absent','native_phone','native_tablet']
    if not approval.get('reviewer') or not approval.get('review_note') or not all(approval.get(k) is True for k in required):return False
    return approval.get('file_sha256')=={p:sha(safe(inbox,p)) for p in row['required_files']}
def adapter(row):
    if row['category'] in ['playable_lootlings','wanderers'] and row['state'] in PHASES and row['weapon_family']!='bow':return 'playable_extracted_phase'
    if row['category']=='Home':return 'home_environment' if row['slot_id'].startswith('environment:') else 'home_decoration'
    if row['category']=='companions' and row['state'] in ['idle','move','reaction','perch_rest','perch_interact']:return 'companion_state'
    return None
def registry_target(row):
    if row['category']=='Home':return ROOT/'art/production/phase4e/home_runtime_manifest.json'
    if row['category']=='companions':return ROOT/'art/production/companions/runtime_manifest.json'
    return ROOT/'art/production/phase4e/runtime_manifest.json'
def installed_rows():
    entries=[]
    for path in [ROOT/'art/production/phase4e/runtime_manifest.json',ROOT/'art/production/phase4e/home_runtime_manifest.json',ROOT/'art/production/companions/runtime_manifest.json']:
        if path.exists():entries.extend(read(path)['entries'])
    return entries
def metadata_checks(row,meta,body,inbox):
    errors=[]
    for key in ['slot_id','entity_id','state','facing','weapon_family']:
        if key=='slot_id' and row['category']=='Home':continue # decoration metadata names its placement slot
        if key in meta and meta[key]!=row.get(key):errors.append(key+': differs from exact cell')
    if 'body_filename' in meta and meta['body_filename']!=row['expected_filename']:errors.append('body_filename mismatch')
    if 'background_file' in meta and meta['background_file']!=row['expected_filename']:errors.append('background_file mismatch')
    if 'canvas' in meta and meta['canvas']!=row['canvas']:errors.append('metadata canvas mismatch')
    if meta.get('mirroring_allowed',False) is not False or meta.get('mirror_allowed',False) is not False:errors.append('Unsafe mirroring requested')
    for hash_field in ['source_sha256','body_sha256']:
        if hash_field in meta and meta[hash_field]!=sha(body):errors.append(hash_field+': final PNG hash mismatch')
    if row['slot_id'].startswith('home_decor:'):
        if meta.get('decoration_id')!=row['slot_id'].split(':',1)[1]:errors.append('Decoration ID mismatch')
        fg=next(p for p in row['required_files'] if p.endswith('_front.png'))
        if meta.get('foreground_filename')!=Path(fg).name:errors.append('Perch front-layer filename mismatch')
        if safe(inbox,fg).is_file() and meta.get('foreground_sha256')!=sha(safe(inbox,fg)):errors.append('Perch front-layer hash mismatch')
        if meta.get('pivot')!=row['pivot'] or meta.get('surface_anchor')!=row['surface_anchor_pixel']:errors.append('Perch surface/pivot mismatch')
    if row['category']=='companions' and row['state'] in ['perch_rest','perch_interact']:
        if meta.get('allowed_slots')!=row['allowed_perch_slots']:errors.append('Canonical grounded/hover perch compatibility mismatch')
        if meta.get('perch_anchor_type')!=row['perch_anchor_type']:errors.append('Canonical perch contact type mismatch')
        if meta.get('perch_contact_anchor')!=row['perch_contact_anchor_pixel']:errors.append('Perch contact pivot mismatch')
        prop=row.get('interaction_prop')
        expected_prop=prop.get('asset_path') if isinstance(prop,dict) else None
        if meta.get('interaction_prop_path')!=expected_prop:errors.append('Named canonical interaction prop mismatch')
    if row['category'] in ['playable_lootlings','wanderers','enemies','bosses','npcs','companions']:
        if row['category']!='companions' and meta.get('identity_authority')!=row['canonical_authority_files']:errors.append('Dedicated identity authority mismatch')
        if meta.get('source_sha256')!=sha(body):errors.append('Final body SHA256 mismatch')
        pivot=row['pivot'].get('target_canvas') if isinstance(row['pivot'],dict) else row['pivot']
        baseline=row['baseline'].get('target_canvas_y') if isinstance(row['baseline'],dict) else row['baseline']
        if meta.get('pivot')!=pivot:errors.append('Pivot mismatch')
        if meta.get('baseline_y')!=baseline:errors.append('Baseline mismatch')
        with Image.open(body) as im:
            box=list(im.getchannel('A').getbbox() or [])
        if 'occupied_bounds' in meta and meta['occupied_bounds']!=box:errors.append('Measured alpha bounds mismatch')
        for key in ['primary_palm','secondary_palm','core_or_eye','ground_or_hover_point','perch_contact_anchor','interaction_contact_anchor']:
            p=meta.get(key)
            if p is not None and (not isinstance(p,list) or len(p)!=2 or not all(type(v) in [int,float] and math.isfinite(v) for v in p) or not 0<=p[0]<=row['canvas'][0] or not 0<=p[1]<=row['canvas'][1]):errors.append(key+': invalid measured pixel point')
        if row['category'] in ['playable_lootlings','wanderers']:
            if meta.get('baked_equipment'):errors.append('Forbidden interchangeable baked equipment declared')
            for k in ['primary_palm','secondary_palm','core_or_eye']:
                if meta.get(k) is None:errors.append(k+': playable measurement required')
            if box and box[3]!=baseline and row['entity_id']!='glimmerfin':errors.append('Ground-bearing alpha does not meet baseline')
            errors+=validate_schema(meta.get('contacts',{}),read(DOC/'schemas/weapon_socket_sidecar.schema.json'),'contacts')
            contacts=meta.get('contacts',{})
            if contacts.get('primary_contact')!=meta.get('primary_palm'):errors.append('Primary palm/contact disagreement')
            if row['weapon_family'] in ['greatsword','greataxe','maul','spear','daggers','claws','staff','crossbow'] and contacts.get('secondary_contact')!=meta.get('secondary_palm'):errors.append('Missing/disagreeing support/paired contact')
            fg=next((Path(p).name for p in row['required_files'] if p.endswith('_grip_front.png')),None)
            if meta.get('layers',{}).get('foreground')!=fg:errors.append('Mandatory foreground grip/support declaration missing')
            if meta.get('layers',{}).get('vfx') is not None:errors.append('Temporal VFX layer not registered in this delivery contract; cannot bake or silently add')
            if meta.get('layers',{}).get('support') is not None:errors.append('Separate support alternate requires explicit contract registration; use required combined foreground')
        if row['category']=='bosses':
            errors+=validate_schema(meta.get('attack_anchors',{}),read(DOC/'schemas/enemy_attack_anchor_sidecar.schema.json'),'attack_anchors')
            if row['entity_id']=='act_i':
                errors+=validate_schema(meta.get('tail'),read(DOC/'schemas/boss_anchor_tail_sidecar.schema.json'),'tail')
                if (meta.get('tail') or {}).get('tail_count')!=1:errors.append('Hoard Dragon requires exactly one tail')
    return errors
def validate(inbox=INBOX,batch=None,root=ROOT,all_slots=False):
    spec=read(DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json');fmap={x['source_delivery_path']:x for x in spec['artist_files']}
    rows=spec['outstanding_deliverables'];selected=set(batch['slot_ids']) if batch else None
    present=[];unknown=[];unsafe=[]
    for p in inbox.rglob('*') if inbox.exists() else []:
        if p.is_dir():continue
        rel=p.relative_to(inbox).as_posix()
        if rel=='README_IMPORT_ART.txt':continue
        if rel not in fmap:unknown.append(rel)
        else:
            try:safe(inbox,rel);present.append(rel)
            except ValueError as ex:unsafe.append(str(ex))
    if unsafe:return {'unknown_files':unknown,'unsafe_files':unsafe,'overall':'FAIL','empty_inbox':False,'results':[],'counts':{'FAIL':len(unsafe)}}
    touched={fmap[p]['owner_slot_id'] for p in present}
    if selected is not None:touched|=selected
    if all_slots:touched|={row['slot_id'] for row in rows}
    approvals=read(DOC/'ART_REVIEW_APPROVALS.json')['entries']
    results=[]
    refs={x['repository_path']:x['sha256'] for x in read(DOC/'SOURCE_INDEX.json')}
    source_hashes={}
    runtime=installed_rows()
    validate_installed_registrations(runtime)
    installed_ids={e['master_artist_slot_id'] for e in runtime if e.get('master_artist_slot_id')}
    for row in rows:
        if row['slot_id'] not in touched:continue
        if row['slot_id'] in installed_ids:
            results.append({'slot_id':row['slot_id'],'status':'PASS','already_installed':True,'errors':[],'artist_corrections':[],'visual_review_required':False,'automatic_adapter':adapter(row),'runtime_apply_ready':False,'file_sha256':{}})
            continue
        hard=[];corrections=[]
        missing=[p for p in row['required_files'] if not safe(inbox,p).is_file()]
        if missing:corrections+=['Missing mandatory file: '+p for p in missing]
        for path in row['required_files']:
            p=safe(inbox,path)
            if not p.is_file():continue
            try:
                file=fmap[path]
                if file['file_type']=='PNG':hard+=png_errors(p,file['canvas'],row.get('maximum_alpha_bounds'),row.get('transparent_background',True))
                else:
                    m=read(p)
                    if markers(m):corrections.append(path+': unresolved MEASURE_FROM_DELIVERED_PIXELS')
                    corrections+=validate_schema(m,read(DOC/file['schema']))
                    body=safe(inbox,row['source_delivery_path'])
                    if body.is_file() and body.suffix=='.png' and not markers(m):corrections+=metadata_checks(row,m,body,inbox)
                    if row['category']=='support' and not markers(m):
                        declared={s.get('slot_id'):s for s in m.get('states',[]) if isinstance(s,dict)}
                        expected={s['pose_slot_id']:s for s in row['required_states'].values()}
                        if len(declared)!=len(m.get('states',[])):corrections.append('Duplicate support-state mapping')
                        if not set(expected).issubset(declared):corrections.append('Family support packet lacks required exact states')
                        allowed=set(expected)|{s['slot_id'] for s in row['already_accepted_state_references']}
                        if not set(declared).issubset(allowed):hard.append('Unknown support state/family/view reference')
                        for sid,s in expected.items():
                            actual=declared.get(sid,{})
                            for k in ['body_file','sidecar_file','foreground_file']:
                                if actual.get(k)!=s[k]:corrections.append('Support packet '+sid+': wrong '+k)
                                if s[k] and not safe(inbox,s[k]).is_file():corrections.append('Support packet dependency missing: '+s[k])
                dest=safe(root,file['runtime_destination'])
                if dest.exists() and sha(dest)!=sha(p):hard.append('Existing destination must not be overwritten: '+file['runtime_destination'])
            except (OSError,ValueError,TypeError,KeyError) as ex:hard.append(path+': '+str(ex))
        for authority in row.get('canonical_authority_files',[]):
            try:
                a=safe(ROOT,authority)
                if authority not in source_hashes:source_hashes[authority]=sha(a) if a.is_file() else None
                if source_hashes[authority] is None or refs.get(authority)!=source_hashes[authority]:hard.append('Canonical source hash/path changed: '+authority)
            except ValueError as ex:hard.append(str(ex))
        status='FAIL' if hard else 'NEEDS_ARTIST_CORRECTION' if corrections else 'PASS'
        ready=status=='PASS' and review_ready(row,inbox,fmap,approvals)
        results.append({'slot_id':row['slot_id'],'status':status,'errors':hard,'artist_corrections':corrections,'visual_review_required':not ready,'automatic_adapter':adapter(row),'runtime_apply_ready':ready and bool(adapter(row)),'file_sha256':{p:sha(safe(inbox,p)) for p in row['required_files'] if safe(inbox,p).is_file()}})
    return {'unknown_files':unknown,'overall':'FAIL' if unknown or any(x['status']=='FAIL' for x in results) else 'NEEDS_ARTIST_CORRECTION' if any(x['status']=='NEEDS_ARTIST_CORRECTION' for x in results) else 'PASS','empty_inbox':not present,'results':results,'counts':dict(__import__('collections').Counter(x['status'] for x in results)),'apply_policy':'No active runtime writes until every selected cell PASS + hash-bound perceptual/native review + supported adapter. A structural PASS is NOT canonical/visual acceptance.'}
def metadata_source(row):
    return row.get('source_metadata_path') or next(p for p in row['required_files'] if p.endswith('.json'))
def metadata_runtime(row):
    rel=metadata_source(row)
    return next(f['runtime_destination'] for f in read(DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json')['artist_files'] if f['source_delivery_path']==rel)
def registration_row(row,meta):
    if row['category']=='Home':
        return {'master_artist_slot_id':row['slot_id'],'entity_id':row['entity_id'],'asset_path':'res://'+row['runtime_destination'],'metadata_path':'res://'+metadata_runtime(row),'canvas':row['canvas'],'asset_sha256':sha(safe(ROOT,row['runtime_destination'])) if safe(ROOT,row['runtime_destination']).exists() else meta.get('source_sha256',meta.get('body_sha256')),'native_validated':True}
    if row['category']=='companions':
        return {'master_artist_slot_id':row['slot_id'],'actor':row['entity_id'],'state':row['state'],'facing':row['facing'],'asset_path':'res://'+row['runtime_destination'],'asset_sha256':meta['source_sha256'],'metadata_path':'res://'+metadata_runtime(row),'owner_approved':True,'native_validated':True,'mirror_allowed':False}
    w,h=row['canvas'];p=meta['primary_palm'];s=meta['secondary_palm'];core=meta['core_or_eye']
    return {'actor':row['entity_id'],'phase':PHASES[row['state']],'facing':row['facing']+'_only','weapon_types':[row['weapon_family']],'asset_path':'res://'+row['runtime_destination'],'body_rect':[-96,-128,192,192],'primary_anchor':[p[0]/w,p[1]/h],'secondary_anchor':[s[0]/w,s[1]/h],'core_anchor':[core[0]/w,core[1]/h],'feet_baseline':-128+meta['baseline_y']/h*192,'supports_two_hand':row['weapon_family'] in ['greatsword','greataxe','maul','spear','crossbow','staff','daggers','claws'],'foreground_layer':'res://'+str(Path(row['runtime_destination']).with_name(meta['layers']['foreground'])).replace('\\','/') if meta['layers']['foreground'] else '', 'draw_depth':'back','weapon_overrides':{},'wardrobe_requires':{},'baked_weapon':'','master_artist_slot_id':row['slot_id']}
def apply(report,inbox):
    if report['empty_inbox'] or report['overall']!='PASS' or not report['results'] or not all(x['runtime_apply_ready'] for x in report['results']):raise ValueError('Apply blocked: incomplete/unknown files, missing visual approval, or selector/guard adapter not ready. No runtime files changed.')
    spec=read(DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json');lookup={x['slot_id']:x for x in spec['outstanding_deliverables']};fm={x['source_delivery_path']:x for x in spec['artist_files']}
    target=registry_target(lookup[report['results'][0]['slot_id']]);original=target.read_bytes() if target.exists() else None;manifest=json.loads(original) if original else {'entries':[]};ops=[]
    for result in report['results']:
        row=lookup[result['slot_id']];meta=read(safe(inbox,metadata_source(row)));reg=registration_row(row,meta)
        if registry_target(row)!=target:raise ValueError('Cross-registry batch requires independent transactions')
        if row['category'] in ['playable_lootlings','wanderers']:
            key=(reg['actor'],reg['phase'],reg['facing'],reg['weapon_types'][0])
            if any((e['actor'],e['phase'],e['facing'],key[3])==key and key[3] in e['weapon_types'] for e in manifest['entries']):raise ValueError('Existing accepted exact runtime cell preserved: '+row['slot_id'])
        elif any(e.get('master_artist_slot_id')==row['slot_id'] for e in manifest['entries']):raise ValueError('Existing accepted exact runtime cell preserved: '+row['slot_id'])
        manifest['entries'].append(reg)
        for path in row['required_files']:
            src=safe(inbox,path);dst=safe(ROOT,fm[path]['runtime_destination'])
            if sha(src)!=result['file_sha256'][path]:raise ValueError('Delivery changed since validation')
            ops.append((src,dst))
    created=[]
    try:
        for src,dst in ops:
            if not dst.exists():dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst);created.append(dst)
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf8')
        # Existing guards protect scoped source exports and dedicated identities.
        import validate_canonical_art
        validate_canonical_art.validate()
    except BaseException:
        if original is None:target.unlink(missing_ok=True)
        else:target.write_bytes(original)
        for dst in created:dst.unlink()
        raise
def apply_independent(report,inbox):
    """One transaction per approved exact cell; failed siblings never block it."""
    installed=[];failed=[]
    for result in report['results']:
        if not result['runtime_apply_ready']:continue
        isolated={'empty_inbox':False,'overall':'PASS','results':[result]}
        try:
            apply(isolated,inbox)
            installed.append(result['slot_id'])
        except (OSError,ValueError,KeyError,AssertionError) as ex:
            failed.append({'slot_id':result['slot_id'],'reason':str(ex)})
    return {'installed_slot_ids':installed,'installation_failures':failed}

def correction_queue(report,installation):
    installed=set(installation['installed_slot_ids'])|{r['slot_id'] for r in report['results'] if r.get('already_installed')}
    failures={x['slot_id']:x['reason'] for x in installation['installation_failures']}
    entries=[]
    for result in report['results']:
        if result['slot_id'] in installed:continue
        reasons=result['errors']+result['artist_corrections']
        if not reasons and result['visual_review_required']:reasons=['Hash-bound identity/contact/native visual acceptance required']
        if not reasons and not result['automatic_adapter']:reasons=['Exact runtime selector/registration adapter required']
        if result['slot_id'] in failures:reasons.append(failures[result['slot_id']])
        entries.append({'slot_id':result['slot_id'],'status':result['status'],'required_corrections':reasons})
    return {'newly_installed_PASS_count':len(installation['installed_slot_ids']),'installed_PASS_count':len(installed),'correction_count':len(entries),'remaining_exact_slots':len(entries),'unknown_delivery_files':report['unknown_files'],'entries':entries}

def validate_installed_registrations(entries):
    """Guard installed master rows against their reviewed delivery, not sheet crops."""
    candidates=[e for e in entries if e.get('master_artist_slot_id')]
    if not candidates:return
    spec=read(DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json')
    rows={r['slot_id']:r for r in spec['outstanding_deliverables']}
    files={f['source_delivery_path']:f for f in spec['artist_files']}
    approvals=read(DOC/'ART_REVIEW_APPROVALS.json')['entries']
    refs={x['repository_path']:x['sha256'] for x in read(DOC/'SOURCE_INDEX.json')}
    seen=set()
    for entry in candidates:
        sid=entry['master_artist_slot_id']
        if sid in seen:raise ValueError('Duplicate master runtime cell: '+sid)
        seen.add(sid);row=rows[sid]
        if not adapter(row):raise ValueError('Unsupported master selector: '+sid)
        hashes={}
        for rel in row['required_files']:
            f=files[rel];dest=safe(ROOT,f['runtime_destination']);hashes[rel]=sha(dest)
            if f['file_type']=='PNG':errors=png_errors(dest,f['canvas'],row.get('maximum_alpha_bounds'),row.get('transparent_background',True))
            else:errors=validate_schema(read(dest),read(DOC/f['schema']))
            if errors:raise ValueError(sid+': '+str(errors))
        approval=next((a for a in approvals if a.get('slot_id')==sid),{})
        flags=['canonical_identity','anatomy','pose_facing','contact_fit','baked_modular_equipment_absent','temporal_vfx_absent','native_phone','native_tablet']
        if not approval.get('reviewer') or not approval.get('review_note') or not all(approval.get(k) is True for k in flags) or approval.get('file_sha256')!=hashes:
            raise ValueError('Installed master row lacks hash-bound visual approval: '+sid)
        for authority in row['canonical_authority_files']:
            if refs.get(authority)!=sha(safe(ROOT,authority)):raise ValueError('Master identity authority changed: '+authority)
        meta=read(safe(ROOT,files[metadata_source(row)]['runtime_destination']))
        body=safe(ROOT,row['runtime_destination'])
        if row['category']=='companions':
            errors=metadata_checks(row,meta,body,ROOT)
            if errors:raise ValueError(sid+': '+str(errors))
        if row['slot_id'].startswith('home_decor:'):
            foreground=body.with_name(meta['foreground_filename'])
            with Image.open(body) as b,Image.open(foreground) as f:
                for bp,fp in zip(b.getdata(),f.getdata()):
                    if fp[3] and bp!=fp:raise ValueError('Perch front pixels differ from body: '+sid)
        if entry!=registration_row(row,meta):raise ValueError('Runtime socket/phase mapping differs from reviewed exact delivery: '+sid)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--inbox',type=Path,default=INBOX);p.add_argument('--batch',type=Path)
    p.add_argument('--report',type=Path,default=DOC/'INTAKE_REPORT.json');p.add_argument('--apply',action='store_true')
    p.add_argument('--full-completion',action='store_true',help='Validate every master slot; independently install approved PASS cells')
    args=p.parse_args()
    report=validate(args.inbox,read(args.batch) if args.batch else None,all_slots=args.full_completion)
    installation={'installed_slot_ids':[],'installation_failures':[]}
    if args.apply:
        if args.full_completion:installation=apply_independent(report,args.inbox)
        else:apply(report,args.inbox)
    report['installation']=installation
    if args.full_completion:
        report['apply_policy']='Independent hash-bound approved PASS transactions; missing/failed siblings do not block another cell'
        queue=correction_queue(report,installation)
        path=ROOT/'docs/production/full-completion/ART_CORRECTIONS_REQUIRED.json'
        path.write_text(json.dumps(queue,indent=2)+'\n',encoding='utf8')
    args.report.parent.mkdir(parents=True,exist_ok=True);args.report.write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
    print(json.dumps({k:v for k,v in report.items() if k!='results'},indent=2))
    return 1 if report['overall']=='FAIL' else 2 if report['overall']=='NEEDS_ARTIST_CORRECTION' else 0
if __name__=='__main__':sys.exit(main())
