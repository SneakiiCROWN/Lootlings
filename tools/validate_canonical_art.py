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
    for p in ROOT.glob('*.gd'):
        if re.search(r'res://art/(?:reference/phase4e_handoff|sprites/enemies/handoff)/',p.read_text(encoding='utf-8-sig')):
            errors.append('Runtime references rejected handoff art: '+p.name)
    if errors: raise ValueError('\n'.join(errors))
    return {'frozen_sources':len(registry['frozen_sources']),'rejected_boards':len(registry['references']),
            'preserved_pose_rows':len(poses),'approved_boss_frames':len(bosses),'art_accepted':False}

if __name__=='__main__':
    print(json.dumps(validate(),indent=2))
