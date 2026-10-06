"""Fail build/import checks on canon drift; never grants aesthetic approval."""
from pathlib import Path
import hashlib,json,re
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]

def resource(path):
    relative=path.removeprefix('res://')
    target=(ROOT/relative).resolve()
    if not target.is_relative_to(ROOT) or '..' in Path(relative).parts:
        raise ValueError('Asset path escapes project: '+path)
    return target

def validate():
    registry=json.loads((ROOT/'art/reference/phase4e_handoff/REFERENCE_STATUS.json').read_text(encoding='utf-8'))
    errors=[]
    rejected={r['sha256'] for r in registry['references'] if not r['runtime_allowed']}
    for row in registry['references']+registry['frozen_sources']:
        p=resource(row['path'])
        if not p.exists() or hashlib.sha256(p.read_bytes()).hexdigest()!=row['sha256']:
            errors.append('Frozen source changed/missing; owner review required: '+row['path'])
    poses=json.loads((ROOT/'art/production_pose_manifest.json').read_text(encoding='utf-8'))['entries']
    bosses=json.loads((ROOT/'art/production_boss_manifest.json').read_text(encoding='utf-8'))['entries']
    keys=set()
    preserved=set(registry['preserved_pose_keys'])
    checksums={}
    for row in poses+bosses:
        if row not in bosses and row.get('production_status')!='authored_beta': continue
        path=row['asset_path']; p=resource(path)
        if not path.startswith('res://art/sprites/') or 'phase4e_handoff' in path:
            errors.append('Reference/prototype path cannot be approved frame: '+path)
        if p.exists() and hashlib.sha256(p.read_bytes()).hexdigest() in rejected:
            errors.append('Rejected board renamed as runtime frame: '+path)
        if row not in bosses:
            key=':'.join(str(row[k]) for k in ['actor','stance','phase','facing'])
            if p.exists() and path not in checksums: checksums[path]=hashlib.sha256(p.read_bytes()).hexdigest()
            retained=(key in preserved and registry['preserved_pose_sources'].get(key)==path
                      and registry['preserved_pose_assets'].get(path)==checksums.get(path))
            if not retained:
                source=row.get('source_reference','')
                if not row.get('owner_approval') or not source or 'phase4e_handoff' in source:
                    errors.append('New pose needs established source provenance and explicit owner approval: '+path)
                else:
                    s=resource(source)
                    if not s.exists() or hashlib.sha256(s.read_bytes()).hexdigest()!=row.get('source_sha256'):
                        errors.append('New pose canonical source mismatch: '+path)
        if row in bosses:
            key=(row.get('region'),row.get('state'),row.get('action'),row.get('facing'))
            if key in keys: errors.append('Duplicate boss state/view: '+str(key))
            keys.add(key)
            source=row.get('source_reference','')
            if row.get('production_status')!='owner_approved_beta' or not row.get('owner_approval'):
                errors.append('Boss export lacks explicit owner approval: '+path)
            if not path.startswith('res://art/sprites/enemies/approved/'):
                errors.append('Boss export outside approved frame directory: '+path)
            if not source or 'phase4e_handoff' in source:
                errors.append('Boss export lacks established canonical source: '+path)
            else:
                s=resource(source)
                if not s.exists() or hashlib.sha256(s.read_bytes()).hexdigest()!=row.get('source_sha256'):
                    errors.append('Boss canonical source hash mismatch: '+path)
            if not p.exists() or hashlib.sha256(p.read_bytes()).hexdigest()!=row.get('asset_sha256'):
                errors.append('Boss production frame hash mismatch: '+path)
            if p.exists():
                with Image.open(p) as im:
                    if im.mode!='RGBA' or im.size!=tuple(row.get('canvas',[])):
                        errors.append('Boss frame must match declared RGBA canvas: '+path)
                    elif any(im.getpixel(point)[3] for point in [(0,0),(im.width-1,0),(0,im.height-1),(im.width-1,im.height-1)]):
                        errors.append('Boss frame has opaque background or clipped canvas corners: '+path)
    # Runtime source must never name the excluded boards/cutout experiment.
    extraction=ROOT/'art/production/phase4e/extraction_manifest.json'
    if extraction.exists():
        extracted=json.loads(extraction.read_text(encoding='utf-8'))['entries']
        allowed_icons={'bow','claws','crossbow','daggers','greatsword','greataxe','maul','orb','sling','spear','staff','wand','core_fire','core_lightning','gear_rune','rune_fire','rune_frost','rune_poison','rune_lightning','rune_arcane'}
        paths=set();body_paths=set()
        for row in extracted:
            p=resource(row['asset_path']);s=resource(row['source']);kind=row['kind']
            paths.add(row['asset_path'])
            if kind=='body':body_paths.add(row['asset_path'])
            if not row['asset_path'].startswith('res://art/production/phase4e/') or not p.exists() or sha_file(p)!=row.get('asset_sha256'):
                errors.append('Extracted asset path/hash mismatch: '+row['asset_path'])
            if not s.exists() or sha_file(s)!=row['source_sha256']:errors.append('Extracted canonical source drift: '+row['source'])
            if kind in ['body','expression_portrait'] and not row['source'].startswith('art/reference/canonical/characters/'):
                errors.append('Body/portrait cannot derive from rejected boards: '+row['id'])
            if kind in ['weapons','hud'] and (row['id'] not in allowed_icons or row['source']!='art/reference/phase4e_handoff/approved_references/04_Lootlings_Art_Bible_Canonical_Reference.png'):
                errors.append('Unapproved reference element extraction: '+row['id'])
            if p.exists():
                with Image.open(p) as im:
                    if im.mode!='RGBA' or im.size!=tuple(row['canvas']):errors.append('Invalid extracted RGBA canvas: '+row['id'])
                    if row.get('transparent') and any(im.getpixel(point)[3] for point in [(0,0),(im.width-1,0),(0,im.height-1),(im.width-1,im.height-1)]):errors.append('Clipped extracted canvas corners: '+row['id'])
        runtime=json.loads((ROOT/'art/production/phase4e/runtime_manifest.json').read_text(encoding='utf-8'))['entries']
        for row in runtime:
            expected='ANTICIPATE' if row['asset_path'].endswith('gloomlet_windup_right.png') else 'IDLE'
            if row['asset_path'] not in body_paths or row['phase']!=expected or row['facing'] not in ['right_only','left_only']:
                errors.append('Unproven extracted phase/view routing: '+row['asset_path'])
    reuse=json.loads((ROOT/'art/production/phase4e/reuse_manifest.json').read_text(encoding='utf-8'))['entries']
    expected_actors={'vault_runner','ruin_warden','nightstage_drifter','velvet_astrologer','ashtrail_hunter'}
    if {r['actor'] for r in reuse}!=expected_actors or len(reuse)!=5:errors.append('Unapproved reuse actor registry')
    for row in reuse:
        expected='res://art/sprites/wanderers/beta/'+row['actor']+'_idle.png'
        if row['asset_path']!=expected or row['source_reference']!=expected or row['phase']!='IDLE' or row['facing']!='right_only' or set(row['weapon_types'])!={'wand','orb','daggers','claws','sling'}:
            errors.append('Unproven canonical reuse state: '+row['actor'])
        if sha_file(ROOT/expected.removeprefix('res://'))!=row['source_sha256']:errors.append('Changed accepted reuse source: '+row['actor'])
    prop_manifest=ROOT/'art/production/phase4e/props/source_manifest.json'
    props=json.loads(prop_manifest.read_text(encoding='utf-8'))['entries']
    if {r['id'] for r in props}!={'home_gate','home_shrine'}:errors.append('Unapproved Home source export')
    for row in props:
        source=ROOT/row['source'];asset=ROOT/row['asset_path'].removeprefix('res://')
        if row['source']!='art/reference/phase2_master/lootlings_chests_shrine_merchant_props_reference.png' or sha_file(source)!=row['source_sha256'] or sha_file(asset)!=row['asset_sha256']:
            errors.append('Changed approved Home prop provenance: '+row['id'])
        with Image.open(source) as original, Image.open(asset) as exported:
            if exported.mode!='RGBA' or exported.size!=tuple(row['canvas']) or exported.convert('RGB').tobytes()!=original.crop(row['crop']).convert('RGB').tobytes():
                errors.append('Home prop repainted/resampled instead of original alpha-only crop: '+row['id'])
    for p in ROOT.glob('*.gd'):
        if re.search(r'res://art/(?:reference/phase4e_handoff|sprites/enemies/handoff)/',p.read_text(encoding='utf-8-sig')):
            errors.append('Runtime references rejected handoff art: '+p.name)
    if errors: raise ValueError('\n'.join(errors))
    return {'frozen_sources':len(registry['frozen_sources']),'rejected_boards':len(registry['references']),
            'preserved_pose_rows':len(poses),'approved_boss_frames':len(bosses),'art_accepted':False}

def sha_file(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

if __name__=='__main__':
    print(json.dumps(validate(),indent=2))
