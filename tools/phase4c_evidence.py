"""Package captured native Phase 4C frames into review sheets; never edits game art."""
from pathlib import Path
from PIL import Image, ImageDraw
import shutil
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'.godot_test_data/phase4c'
OUT=ROOT/'docs/production/phase4c'
OUT.mkdir(parents=True,exist_ok=True)
for right in (BASE/'weapons').glob('*_right.png'):
    actor=right.stem.removesuffix('_right')
    sheet=Image.new('RGB',(1920,2320),'#0b1430')
    for x,p in [(0,right),(960,right.with_name(actor+'_left.png'))]:
        sheet.paste(Image.open(p),(x,40))
    ImageDraw.Draw(sheet).text((15,10),actor+' | RIGHT / LEFT | idle, windup, strike, recovery | 12 weapon families',fill='white')
    sheet.save(OUT/(actor+'-weapon-review.webp'),quality=88)
labels=['lootlings','wanderers','home','dialogue','expeditions','modes','stash','forge','blueprints','archive','contracts','combat','verdant_mirror','merchant_selected','level_up','spinner','results']
for size in ['1080x2316','1600x2560']:
    for start in range(0,len(labels),4):
        group=labels[start:start+4]
        sheet=Image.new('RGB',(len(group)*480,580),'#0b1430')
        for i,label in enumerate(group):
            for j,stage in enumerate(['before','after']):
                p=BASE/stage/size/(label+'.png')
                if not p.exists(): raise FileNotFoundError(p)
                frame=Image.open(p); frame.thumbnail((240,540)); sheet.paste(frame,(i*480+j*240,32))
            ImageDraw.Draw(sheet).text((i*480+5,8),label+' | BEFORE / AFTER',fill='white')
        sheet.save(OUT/(size+'-comparison-'+str(start//4+1)+'.webp'),quality=90)
regions=['act_i','mossglass_wilds','moonfen','frostbell_hollows','sunken_gearworks','cinder_crown','starfall_archive','nullglass_expanse','skyhook_bastion','first_hoard']
for start in [0,5]:
    sheet=Image.new('RGB',(1500,660),'#0b1430')
    for i,region in enumerate(regions[start:start+5]):
        for j,state in enumerate(['idle','attack']):
            frame=Image.open(BASE/'bosses'/(region+'_'+state+'.png')); frame.thumbnail((150,600)); sheet.paste(frame,(i*300+j*150,40))
        ImageDraw.Draw(sheet).text((i*300+5,10),region+' | idle / attack',fill='white')
    sheet.save(OUT/('bosses-'+str(start//5+1)+'.webp'),quality=92)
for size in ['1080x2316','1600x2560']:
    for name in ['region_detail','stash_detail','dungeon_navigation','spinner_windup','spinner_reveal','level_up','merchant_selected']:
        frame=Image.open(BASE/'after'/size/(name+'.png'));frame.save(OUT/(size+'-'+name+'.webp'),quality=90)
for facing in [1,-1]:
    sheet=Image.new('RGB',(900,660),'#0b1430')
    for i,state in enumerate(['draw','fire','recovery']):
        frame=Image.open(BASE/'bosses'/('bow_%s_%s.png' % (facing,state)));frame.thumbnail((300,620));sheet.paste(frame,(i*300,25))
        ImageDraw.Draw(sheet).text((i*300+5,5),'bow %s %s' % (facing,state),fill='white')
    sheet.save(OUT/('bow-%s-sequence.webp' % facing),quality=92)
shutil.copy2(BASE/'weapons/report.json',OUT/'weapon-review.json')
print('Native comparison, bosses, bow sequences and full-frame detail evidence packaged.')
