"""One precise remaining high-resolution handoff from newly approved source IDs."""
from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1]
def main():
 refs={r['game_id']:r for r in json.loads((R/'art/approved_missing_canon_references.json').read_text())['entries']}
 missing=json.loads((R/'docs/production/NEEDS_NEW_CANON_EXPORT.json').read_text())
 entries=[]
 for p in missing['packages']:
  if p['game_id'] not in refs:continue
  ref=refs[p['game_id']]
  for state,d in p['states'].items():
   for requirement in d['requirements']:
    if ref['category']=='boss':why='1448x1086 seven-boss overview: action frames are tiny, larger hero panels bake water/pages/chain/VFX or lack exact requested attack/state. They cannot supply full2048x2048 transparent articulated frames with valid contact anatomy. Do not enlarge an overview and claim missing detail.'
    elif ref['category']=='current merchant role':why='Small animation/turnaround strips lack native-readable hand/contact detail. Larger Pack Peddler hero does not expose a verifiable second palm; Merrow is a different labelled panel, not a substitute body for stable pack_peddler. Produce exact approved-role pose/hand layers.'
    elif p['game_id']=='fen_sneak':why='Only larger neutral right-facing whole pose passed direct export. This state/view is absent as a sufficiently detailed isolated body: tiny action/left-view strip cannot supply intact hands/anatomy. No neutral-to-attack relabel or forbidden mirror.'
    else:why='1448x1086 multi-entity board: strips contain roughly50–110px bodies; larger hero panels are framed/cropped, obscure feet/contact anatomy or bake pose/VFX/background. Direct original-pixel cutouts cannot satisfy this exact state/view and phone readability without reconstructing anatomy.'
    entries.append({'entity_id':ref['entity_id'],'manifest_game_id':p['game_id'],'entity_name':ref['display_name'],'category':ref['category'],'state':state,'facing':p['facing'],'identity_authority':ref['source'],'identity_authority_sha256':ref['source_sha256'],'board_entity':ref['board_entity'],'owner_approval':ref['owner_approval'],'reason_direct_extraction_is_blocked':why,'canvas':p['canvas'],'background':p['background'],'baseline':p['baseline'],'pivot':p['anchor'],'exact_delivery_contract':requirement,'restrictions':'Approved named design only. Existing game region/role/attack timing wins over accidental board labels; no marketing/support-body substitution. PNG+actual socket sidecar and required independent layers, not a concept board.'})
 assert len(entries)==593
 out=R/'docs/production/phase4e/HIGH_RES_RUNTIME_GENERATION_QUEUE.json'
 out.write_text(json.dumps({'authority':'Only explicitly approved35 previously source-less identities; exact remaining runtime cells derived from current manifest','scope':'35 new-source entities only; established actors retain their separate existing missing-art contracts','approved_reference_entities':35,'direct_exports_installed':1,'previous_delivery_cells':594,'remaining_delivery_cells':len(entries),'global_missing_cells':missing['delivery_cells'],'entries':entries},indent=2)+'\n')
 print('One consolidated high-resolution queue:',len(entries),'exact state/view cells')
if __name__=='__main__':main()
