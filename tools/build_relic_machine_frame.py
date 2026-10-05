"""Authored brass/obsidian Relic Machine; no generated imagery or outside designs."""
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'art/ui/relic_machine_frame.svg'
out.parent.mkdir(parents=True,exist_ok=True)
parts=['''<svg xmlns="http://www.w3.org/2000/svg" width="752" height="448" viewBox="0 0 376 224">
<defs>
<linearGradient id="metal" x1="0" y1="0" x2="0" y2="224" gradientUnits="userSpaceOnUse"><stop stop-color="#f1dc9a"/><stop offset=".18" stop-color="#a17b42"/><stop offset=".48" stop-color="#59412c"/><stop offset=".67" stop-color="#b7975e"/><stop offset="1" stop-color="#322b28"/></linearGradient>
<linearGradient id="stone" x1="0" y1="0" x2="376" y2="224" gradientUnits="userSpaceOnUse"><stop stop-color="#34434a"/><stop offset=".5" stop-color="#14232c"/><stop offset="1" stop-color="#080f19"/></linearGradient>
<linearGradient id="bevel" x1="0" y1="38" x2="0" y2="198" gradientUnits="userSpaceOnUse"><stop stop-color="#100e14"/><stop offset=".08" stop-color="#dfc188"/><stop offset=".12" stop-color="#715238"/><stop offset=".84" stop-color="#342b27"/><stop offset="1" stop-color="#dab77b"/></linearGradient>
</defs>
<path d="M28 8L72 3H304L348 8L370 31V190L346 218H30L6 190V31Z" fill="#050910" stroke="#06090d" stroke-width="8"/>
<path d="M28 8L72 3H304L348 8L370 31V190L346 218H30L6 190V31Z" fill="url(#metal)" stroke="#c2a16b" stroke-width="2"/>
<path d="M33 17L73 12H303L343 17L358 35V186L337 206H39L18 186V35Z" fill="url(#stone)" stroke="#e7ce91" stroke-width="1"/>
<path d="M35 34H341L350 44V185L338 197H38L26 185V44Z" fill="url(#bevel)" stroke="#080d14" stroke-width="3"/>
<rect x="34" y="44" width="308" height="142" rx="8" fill="#030711" stroke="#c9ac72" stroke-width="1"/>
<path d="M52 21H144M232 21H324M52 211H152M224 211H324" fill="none" stroke="#aa8e5c" stroke-width="2"/>
<path d="M165 17L188 5L211 17L204 29H172Z" fill="#302c32" stroke="#d7bb7b" stroke-width="2"/>
<path d="M177 17L188 9L199 17L188 27Z" fill="#87c9bf" stroke="#f0e2b4"/>
<path d="M179 17L188 12L188 24Z" fill="#d2fff0" opacity=".5"/>
''']
for x in (17,359):
 for y in (43,77,153,185):
  parts.append(f'<circle cx="{x}" cy="{y}" r="6" fill="#262627" stroke="#a88953" stroke-width="2"/><circle cx="{x-1}" cy="{y-1}" r="2" fill="#d8bd80"/><path d="M{x-3} {y+2}L{x+2} {y-3}" stroke="#4b392a"/>')
 for y in range(92,140,8):
  parts.append(f'<path d="M{x-5} {y}H{x+5}" stroke="#060c14" stroke-width="3"/><path d="M{x-5} {y+2}H{x+5}" stroke="#738178" stroke-width="1"/>')
parts.append('</svg>')
out.write_text(''.join(parts),encoding='utf-8')
print(out)
