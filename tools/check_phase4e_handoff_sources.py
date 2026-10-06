"""Read-only archive/source comparison; records missing requested package explicitly."""
from pathlib import Path
import csv,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'docs/production/phase4e/source-correction'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 OUT.mkdir(parents=True,exist_ok=True)
 requested=[ROOT/'reference/phase4e_handoff',ROOT/'reference/phase4e_handoff.zip']
 archive_records=[]
 for path in [ROOT/'art/reference/phase4e_handoff.zip',ROOT/'art/reference/phase4e_handoff/approved_references.zip']:
  with zipfile.ZipFile(path) as archive:
   assert archive.testzip() is None
   for info in archive.infolist():
    if info.is_dir():continue
    parts=Path(info.filename).parts
    assert not Path(info.filename).is_absolute() and '..' not in parts
    relative=info.filename if parts[0]=='phase4e_handoff' else 'phase4e_handoff/'+info.filename
    local=ROOT/'art/reference'/relative
    digest=hashlib.sha256(archive.read(info)).hexdigest()
    archive_records.append(dict(archive=path.relative_to(ROOT).as_posix(),entry=info.filename,bytes=info.file_size,sha256=digest,local=local.relative_to(ROOT).as_posix(),already_present=local.is_file(),matches_extracted=local.is_file() and sha(local)==digest))
 rows=[]
 reused=json.loads((ROOT/'art/production/phase4e/reuse_manifest.json').read_text())['entries']
 for row in reused:
  rows.append(dict(runtime_slot=row['actor']+'/IDLE/right/'+','.join(row['weapon_types']),current_asset=row['asset_path'],current_source=row['source_reference'],preferred_handoff_asset='NONE: requested newer package absent; available overview Wanderers conflict with established detailed preset identity',replacement_needed='PENDING intended-package location; preserve existing valid integration',source_kind='older accepted runtime export'))
 extraction=json.loads((ROOT/'art/production/phase4e/extraction_manifest.json').read_text())['entries']
 for row in extraction:
  rows.append(dict(runtime_slot=row['id'],current_asset=row['asset_path'],current_source=row['source'],preferred_handoff_asset=row['source'] if 'phase4e_handoff' in row['source'] else 'No compatible newer body/expression source in available five boards',replacement_needed='NO for compatible original handoff elements; PENDING exact newer package for other slots',source_kind='existing handoff extraction' if 'phase4e_handoff' in row['source'] else 'locked character sheet extraction'))
 report=dict(requested_locations=[dict(path=str(p),exists=p.exists()) for p in requested],available_package='art/reference/phase4e_handoff',archives=archive_records,mapping=rows,compatible_handoff_exports=sum('phase4e_handoff' in r['source'] for r in extraction),new_runtime_switches=0,identity_rule='Hard canon freeze retained: no rejected body is re-approved by a package filename or relocation',decision='Source correction blocked on locating the specifically intended newer package; preserve all validated current changes. No broad integration until mapping can compare actual intended sources.')
 report['owner_clarified_root']='art/reference'
 report['source_priority']='Written canon/stable IDs/production; established canonical sheets; accepted runtime poses; established gear/UI/world; compatible handoff guidance only. New exports derive from established identity.'
 report['reference_inventory']=[dict(path=p.relative_to(ROOT).as_posix(),sha256=sha(p),replacement_body_authority='Established character sheet' if '/canonical/characters/' in p.as_posix() else 'No new identity authority; use existing approval/provenance and stable ID match') for p in sorted((ROOT/'art/reference').rglob('*.png'))]
 report['decision']='RESOLVED by owner: full art/reference root is authoritative; no handoff timestamp overrides identity freeze. Five accepted Wanderers remain valid. Continue compatible original source integration; no rejected replacement body.'
 for row in rows:
     if row['source_kind']=='older accepted runtime export':
         row['preferred_handoff_asset']=row['current_asset']
         row['replacement_needed']='NO: explicitly confirmed valid by owner; no higher-authority same-identity superseding source'
     elif row['source_kind']=='locked character sheet extraction':
         row['preferred_handoff_asset']=row['current_source']
         row['replacement_needed']='NO: already derived from highest-authority established character sheet'
     else:row['replacement_needed']='NO: preserve previously accepted compatible runtime export; no new handoff body import'
 report['new_runtime_switches']=2
 for prop in json.loads((ROOT/'art/production/phase4e/props/source_manifest.json').read_text())['entries']:
     rows.append(dict(runtime_slot=prop['runtime_slot']+'/'+prop['id'],current_asset=prop['asset_path'],current_source=prop['source'],preferred_handoff_asset=prop['source'],replacement_needed='IMPLEMENTED: original compatible source prop at existing Home hotspot',source_kind='approved established prop-sheet crop/alpha ownership mask'))
 (OUT/'SOURCE_MAPPING.json').write_text(json.dumps(report,indent=2)+'\n')
 with (OUT/'SOURCE_MAPPING.csv').open('w',newline='',encoding='utf-8-sig') as f:
  writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
 print(json.dumps({k:v for k,v in report.items() if k not in ['archives','mapping']},indent=2))
if __name__=='__main__':main()
