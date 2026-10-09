"""Two specific Home interaction recordings; preserve all existing banks."""
from pathlib import Path
import json
from build_sound_bank import source,mix,save,records,ROOT
def main():
    # Existing verified Kenney CC0 pack; exact recording hashes saved by source().
    wood,w=source('impact','impactWood_light',.85)
    cloth,c=source('rpg','cloth1',.9)
    page,p=source('rpg','bookFlip1',.92)
    save('home_bench',0,mix([(wood,.55,0),(cloth,.22,.045)],.35),[w,c])
    save('home_page',0,mix([(page,.75,0),(cloth,.10,.09)],.45),[p,c])
    path=ROOT/'art/audio/production/sources.json';data=json.loads(path.read_text(encoding='utf8'))
    names={x['asset'] for x in records};data['assets']=[x for x in data['assets'] if x['asset'] not in names]+records
    path.write_text(json.dumps(data,indent=2)+'\n',encoding='utf8');print('Two specific Home feedback clips installed; other banks unchanged.')
if __name__=='__main__':main()
