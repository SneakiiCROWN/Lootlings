"""Original gold payout energy from the accepted elemental/reward sheet."""
from pathlib import Path
import hashlib,json
from PIL import Image,ImageDraw
from extract_bible_runtime import isolate
ROOT=Path(__file__).resolve().parents[1]
def main():
 source=ROOT/'art/reference/phase2_master/lootlings_spell_reward_vfx_reference.png';box=(600,270,895,563)
 original=Image.open(source).crop(box);assert original.mode=='RGBA'
 alpha=isolate(original).getchannel('A')
 exclusions=[(0,0,12,293),(267,0,295,190),(282,190,295,293),(0,273,295,293)]
 for area in exclusions:ImageDraw.Draw(alpha).rectangle(area,fill=0)
 image=Image.merge('RGBA',(*original.split()[:3],alpha));assert image.convert('RGB').tobytes()==original.convert('RGB').tobytes()
 padded=Image.new('RGBA',(image.width+8,image.height+8));padded.paste(image,(4,4))
 target=ROOT/'art/production/phase4e/vfx/gold_pillar.png';padded.save(target)
 mp=ROOT/'art/production/phase4e/extraction_manifest.json';data=json.loads(mp.read_text())
 data['entries']=[e for e in data['entries'] if e['id']!='gold_pillar']
 sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
 data['entries'].append(dict(id='gold_pillar',kind='vfx',source=source.relative_to(ROOT).as_posix(),source_sha256=sha(source),crop=list(box),alpha_exclusions=exclusions,asset_path='res://'+target.relative_to(ROOT).as_posix(),canvas=list(padded.size),transparent=True,integrated=True,asset_sha256=sha(target),restrictions='Original RGB; alpha-only neighbouring fragment exclusion; 4px gutter; bounded Legendary payout motif, no new rune/reward/odds.'))
 mp.write_text(json.dumps(data,indent=2)+'\n');print('One original gold payout export; clipped Legendary reel consumer.')
if __name__=='__main__':main()
