"""Derive intake directories and production batches without altering the master."""
from pathlib import Path
import json,collections,hashlib
ROOT=Path(__file__).resolve().parents[1];DOC=ROOT/'docs/production/master-art-delivery';INBOX=ROOT/'art/source/master_artist_delivery'
def write(path,data):path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(data,indent=2)+'\n',encoding='utf8')
def main():
    sp=DOC/'LOOTLINGS_MASTER_ART_DELIVERY_SPEC.json';spec=json.loads(sp.read_text(encoding='utf8'));fingerprint=hashlib.sha256(sp.read_bytes()).hexdigest()
    rows=spec['outstanding_deliverables'];fm={x['source_delivery_path']:x for x in spec['artist_files']}
    for f in fm:(INBOX/Path(f).parent).mkdir(parents=True,exist_ok=True)
    INBOX.mkdir(parents=True,exist_ok=True)
    (INBOX/'README_IMPORT_ART.txt').write_text('MASTER ART INBOX\n\nMirror each exact source_delivery_path INSIDE this folder. Example: art/source/master_artist_delivery/art/source/phase4e/delivery/relic_beast/<exactfilename>.png. Do not flatten folders. Metadata/layers retain exact names and state/view/family. Do not put reference boards/archives/helper files here. Accepted runtime files are never moved.\n\nRun tools/master_artist_intake.py --batch docs/production/master-art-delivery/NEXT_ART_BATCH.json. Default is validation only. PASS is structural; hash-bound visual/native approval remains mandatory. No artwork is installed by preparing this inbox. See INTAKE_GUIDE.md for adapter limitations.\n',encoding='utf8')
    groups=collections.defaultdict(list)
    for row in rows:groups[(row['entity_id'],row['category'],row.get('weapon_family'),row.get('facing'))].append(row)
    batches=[]
    for key,items in groups.items():
        for offset in range(0,len(items),6):
            rs=items[offset:offset+6];batch={'batch_id':f'artist_{len(batches)+1:04d}','master_spec_sha256':fingerprint,'entity_id':key[0],'category':key[1],'weapon_family':key[2],'facing':key[3],'slot_ids':[x['slot_id'] for x in rs],'items':rs,'files':[fm[p] for x in rs for p in x['required_files']]}
            write(DOC/'batches'/f"{batch['batch_id']}.json",batch);batches.append({k:batch[k] for k in ['batch_id','entity_id','category','slot_ids']})
    assert {p for b in batches for p in b['slot_ids']}=={r['slot_id'] for r in rows}
    write(DOC/'batches/INDEX.json',{'master_spec_sha256':fingerprint,'batch_count':len(batches),'runtime_contract_records':len(rows),'artist_file_count':len(fm),'batches':batches})
    programme={'relic_beast':'greatsword','emberhorn':'claws','mosskin':'maul','moonkip':'daggers','pebblewyrm':'claws','glimmerfin':'wand','gloomlet':'bow'}
    order=['idle','windup','strike_or_cast','recovery','movement','hurt']
    chosen=[]
    for eid,family in programme.items():
        candidates=[x for x in rows if x['entity_id']==eid and x.get('category')=='playable_lootlings' and x.get('weapon_family')==family and x.get('facing')=='right']
        rs=[x for state in order for x in candidates if x['state']==state]
        assert rs,eid;chosen+=rs
    nextbatch={'batch_id':'initial_seven_lootlings_right_core','master_spec_sha256':fingerprint,'characters':list(programme),'character_count':7,'runtime_cell_count':len(chosen),'slot_ids':[x['slot_id'] for x in chosen],'items':chosen,'files':[fm[p] for x in chosen for p in x['required_files']],'policy':'Individual exports,7 identities each using dedicated sheet; accepted exact cells excluded. Right-facing core first, then remaining follow-through and left views from full batches. No owner APK until native route gate succeeds.'}
    write(DOC/'NEXT_ART_BATCH.json',nextbatch)
    md=['# First large artist batch','',f'7canonical Lootlings; {len(chosen)}exact open right-facing cells; {len(nextbatch["files"])}files. Existing accepted cells are excluded. Each item in JSON contains full canon, pose, socket, canvas, layer, sidecar, prohibited elements and destination contract.','']
    for eid,f in programme.items():
        rs=[x for x in chosen if x['entity_id']==eid];md += [f'## {eid} / {f}', '',*['- '+x['state']+': '+x['expected_filename']+'; sidecar '+x['metadata_filename'] for x in rs],'']
    (DOC/'NEXT_ART_BATCH.md').write_text('\n'.join(md),encoding='utf8')
    write(DOC/'ART_REVIEW_APPROVALS.json',{'scope':'Trusted reviewer log. Approvals must bind every mandatory file hash; filenames alone never approve identity or a pose. Do not fill from artist declarations automatically.','entries':[]}) if not (DOC/'ART_REVIEW_APPROVALS.json').exists() else None
    print(json.dumps({'batches':len(batches),'first_batch_characters':7,'first_batch_cells':len(chosen),'first_batch_files':len(nextbatch['files']),'all_artist_files_covered':len(fm)},indent=2))
if __name__=='__main__':main()
