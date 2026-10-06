"""Register unchanged accepted Wanderer neutral exports; never manufacture states."""
from pathlib import Path
import json,hashlib
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SPECS={
 'vault_runner':([.719,.461],[.305,.49],[-75,-146,150,225],[.49,.31]),
 'ruin_warden':([.753,.438],[.25,.48],[-70,-145,140,210],[.473,.186]),
 'nightstage_drifter':([.787,.446],[.265,.50],[-75,-146,150,225],[.463,.181]),
 'velvet_astrologer':([.766,.447],[.28,.48],[-75,-146,150,225],[.504,.236]),
 'ashtrail_hunter':([.765,.452],[.255,.47],[-75,-146,150,225],[.549,.244]),
}
def main():
 entries=[]
 for actor,(primary,secondary,rect,core) in SPECS.items():
  path=f'art/sprites/wanderers/beta/{actor}_idle.png'
  with Image.open(ROOT/path) as im:
   assert im.mode=='RGBA' and im.size==(1024,1536)
   for anchor in [primary,secondary]:
    assert im.getpixel((int(anchor[0]*1024),int(anchor[1]*1536)))[3]>127,(actor,anchor)
  entries.append(dict(actor=actor,phase='IDLE',facing='right_only',weapon_types=['wand','orb','daggers','claws','sling'],asset_path='res://'+path,source_reference='res://'+path,source_sha256=hashlib.sha256((ROOT/path).read_bytes()).hexdigest(),canvas=[1024,1536],body_rect=rect,primary_anchor=primary,secondary_anchor=secondary,core_anchor=core,feet_baseline=rect[1]+rect[3]*.975,supports_two_hand=False,foreground_layer='',draw_depth='front',weapon_overrides={},wardrobe_requires={},baked_weapon='',production_status='accepted_beta_reuse',restrictions='Original neutral right-facing body only; no mirror, no idle-as-attack, no movement/hurt/defeat claim. Paired palms partial; action support package stays open.'))
 out=ROOT/'art/production/phase4e/reuse_manifest.json'
 out.write_text(json.dumps(dict(authority='Established accepted Wanderer runtime exports and their existing source hand contracts',entries=entries),indent=2)+'\n')
 existing=ROOT/'art/production/phase4e/runtime_manifest.json'
 data=json.loads(existing.read_text())
 for row in data['entries']:
  if row['phase']=='IDLE' and not row.get('baked_weapon') and 'sling' not in row['weapon_types']:
   row['weapon_types'].append('sling')
 existing.write_text(json.dumps(data,indent=2)+'\n')
 print('Registered five unchanged canonical bodies / twenty-five neutral state-family cells; zero new images.')
if __name__=='__main__':main()
