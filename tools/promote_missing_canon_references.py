"""Promote only the owner's 35 previously source-less IDs; no body import."""
from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1]
def main():
 base=R/'art/reference/phase4e_handoff/chatgpt_generated_candidates'
 index=json.loads((base/'CHATGPT_GENERATED_ART_INDEX.json').read_text())
 queue=json.loads((R/'art/reference/phase4e_handoff/source_pack_final/MISSING_CANON_ART_QUEUE.json').read_text())
 by_name={e['display_name'].lower():e for e in queue['entries']};by_name['pack peddler']=by_name['pack peddler / merrow (existing merchant role)'];by_name['merrow']=by_name['pack peddler']
 entries={}
 for section in ['regional','bosses','merchant']:
  for board in index[section]:
   assert board['status']=='USER_APPROVED_NEW_CANON_CANDIDATE' and board['runtime_asset'] is False
   source=base/board['file'];digest=hashlib.sha256(source.read_bytes()).hexdigest()
   for name in board['entities']:
    e=by_name[name.lower()];id=e['manifest_game_id']
    if id in entries:continue
    entries[id]={'entity_id':e['entity_id'],'game_id':id,'display_name':e['display_name'],'category':e['category'],'source':source.relative_to(R).as_posix(),'source_sha256':digest,'owner_approval':'Explicit Phase4E promote-new-canon request, 2026-10-07; previously source-less entities only','status':'OWNER_APPROVED_IDENTITY_AND_POSE_REFERENCE','runtime_asset':False,'board_entity':name,'restrictions':'Existing stable IDs, regions, mechanics and written canon override board headings/lore. Supporting established-actor boards cannot replace dedicated canon. Marketing excluded. Exact PNG state/view export still requires separate validation.'}
 assert len(entries)==35
 target=R/'art/approved_missing_canon_references.json'
 target.write_text(json.dumps({'authority':'Owner approval applies only to these previously source-less entities; source board is not a runtime PNG','entries':list(entries.values())},indent=2)+'\n')
 print('Registered35 owner-approved missing identity references; no established identity changed')
if __name__=='__main__':main()
