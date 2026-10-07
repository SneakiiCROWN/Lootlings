"""Alpha-only extraction of complete neutral silhouettes from approved canon.

No repainting, recolouring, mirroring, reconstruction or fabricated action frames.
Outlines are recorded in the 3x inspection view; RGB comes from original pixels.
"""
from pathlib import Path
import hashlib, json
from PIL import Image, ImageDraw
R=Path(__file__).resolve().parents[1]
SOURCE='art/reference/canonical/companions/Lootlings_Companion_Collection_Canonical.png'
SPECS={
 'stonekith': {'crop':[495,209,782,486], 'outline':[
 (176,31),(252,47),(260,30),(310,56),(330,40),(373,89),(394,150),(438,106),(471,102),(491,22),(513,16),(600,91),(608,139),(640,135),(682,55),(705,74),(714,112),(756,56),(779,113),(786,168),(822,126),(821,211),(803,246),(837,250),(830,285),(810,309),(835,311),(818,348),(793,383),(840,395),(819,421),(782,447),(795,454),(753,475),(744,517),(721,510),(693,524),(699,548),(714,575),(710,600),(739,632),(728,651),(752,680),(744,704),(766,735),(765,773),(747,790),(706,789),(689,772),(674,786),(641,782),(624,768),(605,765),(591,752),(596,715),(579,725),(545,714),(521,694),(531,755),(539,783),(530,816),(502,828),(469,818),(445,809),(422,819),(400,810),(389,786),(373,787),(362,760),(341,775),(326,770),(316,777),(301,770),(293,750),(287,709),(274,694),(252,701),(225,748),(202,769),(194,790),(177,803),(143,794),(127,805),(105,799),(86,791),(79,768),(78,732),(101,684),(33,670),(43,639),(33,623),(13,607),(34,577),(28,565),(76,543),(123,536),(85,520),(47,497),(57,478),(18,493),(12,475),(30,447),(16,435),(64,418),(72,412),(41,401),(21,374),(13,307),(50,333),(43,301),(40,263),(57,188),(68,137),(124,203),(174,263),(186,229),(219,266),(245,300),(249,333),(268,334),(285,328),(264,307),(238,268),(226,226),(228,206),(244,196),(235,174),(224,171),(205,145),(186,143),(179,110)]},
 'puffnest': {'crop':[495,674,752,948], 'outline':[
 (72,153),(110,133),(101,114),(121,92),(121,72),(141,48),(166,63),(184,48),(186,24),(204,15),(228,57),(231,85),(214,111),(228,115),(263,103),(258,71),(277,42),(299,20),(330,10),(359,17),(378,49),(375,74),(356,110),(371,119),(394,94),(413,108),(424,135),(458,108),(462,82),(477,58),(494,51),(491,27),(529,17),(564,14),(572,40),(550,67),(574,72),(581,98),(606,64),(626,45),(646,69),(655,99),(688,105),(694,126),(665,148),(678,185),(662,211),(683,209),(704,228),(701,244),(738,240),(746,258),(753,282),(743,298),(762,321),(735,335),(745,362),(738,385),(703,371),(702,394),(721,414),(729,452),(745,481),(752,520),(738,538),(715,528),(724,560),(726,591),(692,575),(697,613),(723,663),(703,660),(686,647),(670,672),(658,704),(640,727),(634,748),(607,731),(590,723),(586,747),(568,770),(565,787),(549,797),(515,797),(498,785),(474,784),(462,772),(455,751),(408,756),(413,779),(415,792),(400,809),(375,813),(366,808),(342,807),(323,795),(321,766),(306,757),(298,731),(280,753),(272,737),(250,756),(239,736),(204,750),(198,733),(177,745),(160,725),(122,737),(132,719),(158,693),(120,687),(90,688),(75,707),(56,716),(60,683),(43,674),(45,645),(54,626),(44,612),(45,590),(38,574),(23,553),(14,520),(22,494),(30,477),(39,460),(34,432),(45,410),(35,391),(23,410),(9,414),(23,385),(33,365),(36,347),(18,331),(18,312),(25,299),(40,289),(38,270),(51,257),(56,230),(20,217),(11,201),(28,185),(49,183),(62,163)]},
}

def extract(actor):
 spec=SPECS[actor]
 with Image.open(R/SOURCE) as im: crop=im.crop(spec['crop']).convert('RGBA')
 mask=Image.new('L',(crop.width*4,crop.height*4));ImageDraw.Draw(mask).polygon([(x*4/3,y*4/3) for x,y in spec['outline']],fill=255)
 if actor=='stonekith':
  # Background sparkle between the rear legs, not an anatomical/body detail.
  ImageDraw.Draw(mask).polygon([(x*4/3,y*4/3) for x,y in [(223,710),(247,694),(273,704),(278,731),(254,758),(221,747)]],fill=0)
 crop.putalpha(mask.resize(crop.size,Image.Resampling.LANCZOS))
 crop=crop.crop(crop.getbbox())
 # Preserve aspect, feet baseline and central pivot; no squash/stretch.
 scale=min(192/crop.width,200/crop.height)
 size=(round(crop.width*scale),round(crop.height*scale))
 body=crop.resize(size,Image.Resampling.LANCZOS)
 canvas=Image.new('RGBA',(256,256));canvas.alpha_composite(body,((256-size[0])//2,224-size[1]))
 return crop,canvas

def main():
 rows=[]
 for actor,spec in SPECS.items():
  crop,canvas=extract(actor)
  source=f'art/source/companions/{actor}/{actor}_idle_right.png'
  asset=f'art/production/companions/{actor}/{actor}_idle_right.png'
  for path,im in [(source,crop),(asset,canvas)]:
   p=R/path;p.parent.mkdir(parents=True,exist_ok=True);im.save(p)
  rows.append({'actor':actor,'state':'idle','facing':'right','asset_path':'res://'+asset,'source':SOURCE,'source_sha256':hashlib.sha256((R/SOURCE).read_bytes()).hexdigest(),'source_export':source,'crop':spec['crop'],'outline_3x':spec['outline'],'canvas':[256,256],'baseline':224,'pivot':[128,224],'mirror_allowed':False,'owner_approved':True,'native_validated':False,'asset_sha256':hashlib.sha256((R/asset).read_bytes()).hexdigest(),'purpose':'Exact neutral right-facing body only; no movement/reaction/opposite state implied.'})
  print(actor,canvas.getbbox())
 (R/'art/production/companions/runtime_manifest.json').write_text(json.dumps({'scope':'Owner-approved companion identity, exact source-derived states only; partial previews cannot enable equipment.','entries':rows},indent=2)+'\n')
if __name__=='__main__':main()
