"""Scoped owner-approved original-pixel NPC panels; not fabricated body exports."""
from pathlib import Path
import hashlib,json
from PIL import Image
R=Path(__file__).resolve().parents[1]
SOURCE='art/reference/canonical/characters/04_Lootlings_Art_Bible_Canonical_Reference.png'
SPECS={'patch':('Patch_Brasswick_Canonical.png',[7,301,119,458]),'ilex':('Ilex_Quill_Canonical.png',[123,301,231,458])}
def main():
 rows=[]
 for actor,(filename,crop) in SPECS.items():
  source=R/SOURCE;dedicated=R/'art/reference/canonical/npcs'/filename
  runtime=R/'art/production/phase4e/npcs'/f'{actor}_canonical_station_panel.png'
  dedicated.parent.mkdir(parents=True,exist_ok=True);runtime.parent.mkdir(parents=True,exist_ok=True)
  with Image.open(source) as board:panel=board.crop(crop).convert('RGBA')
  panel.save(dedicated);panel.save(runtime)
  rows.append({'id':actor,'canonical_source':dedicated.relative_to(R).as_posix(),'source_board':SOURCE,'source_crop':crop,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'dedicated_sha256':hashlib.sha256(dedicated.read_bytes()).hexdigest(),'runtime_asset':runtime.relative_to(R).as_posix(),'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'authority':'Scoped owner approval, 2026-10-07: KEY NPCS (CANONICAL), Patch/Ilex only','purpose':'Station vignette and portrait; original panel with painted setting/counter. Not transparent full-body idle, route, work, talk or sit animation.','full_body_states_closed':0,'superseded_runtime_assets':[f'art/sprites/npcs/beta/{actor}_idle.png',f'art/sprites/npcs/beta/{actor}_portrait.png']})
 (R/'art/npc_identity_authorities.json').write_text(json.dumps({'scope':'Patch and Ilex only. Other broad-board bodies remain rejected. Dedicated existing actors and stable IDs unchanged.','entries':rows},indent=2)+'\n',encoding='utf-8')
 print('Two dedicated NPC authorities and two pixel-identical runtime station panels; zero full-body state closures.')
if __name__=='__main__':main()
