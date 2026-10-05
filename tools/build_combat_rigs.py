"""Original Lootlings combat layers. Authored vector paths, no image generation.

Heads/torso/tails only: articulated limbs belong to combat_sprite_rig.gd.
The 384px canvas maps to (-96,-128,192,192). Eyes look right.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'art/sprites/combat_rigs'
OUT.mkdir(parents=True, exist_ok=True)
PALETTES = {
 'relic_beast': ('#ba7035','#f4ce82','#e8b94d'),
 'emberhorn': ('#963c39','#ef8a58','#ffd076'),
 'mosskin': ('#52685a','#a0b585','#c9d879'),
 'moonkip': ('#748cad','#d6eafa','#b6a1ef'),
 'pebblewyrm': ('#76665c','#b8a38a','#e6bb68'),
 'glimmerfin': ('#297b88','#8edfd7','#d7a4ef'),
 'gloomlet': ('#42355e','#8275a5','#d79ced'),
 'vault_runner': ('#3b6673','#9a674a','#76dae3'),
 'ruin_warden': ('#514b40','#b58361','#e0bc65'),
 'nightstage_drifter': ('#383b51','#b59d7c','#b495e5'),
 'velvet_astrologer': ('#5d365e','#a9745b','#e4bd76'),
 'ashtrail_hunter': ('#655344','#dfb8a0','#cba573'),
'patch': ('#73534b','#c39672','#e1b264'),
'sera': ('#68547b','#d7baa4','#bd9eeb'),
'ilex': ('#385264','#e2c9b7','#9ac9d4'),
}

def path(d, fill, stroke='#172334', w=4):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{w}" stroke-linejoin="round" stroke-linecap="round"/>'

for actor, (body, face, accent) in PALETTES.items():
    creature = actor in list(PALETTES)[:7]
    shapes = []
    if creature:
        # Tail, chest and a true three-quarter head; no portrait arms or props.
        if actor in ('relic_beast','moonkip','gloomlet'):
            shapes += [path('M155 258 Q62 306 68 222 Q69 199 95 182 Q86 237 150 220 Z', body),
                       path('M76 219 Q74 203 95 182 Q91 222 117 239 Q94 240 76 219',face,w=2)]
        elif actor == 'pebblewyrm':
            shapes += [path('M164 271 Q76 279 73 235 L93 212 L109 239 L142 240 Z',body),
                       path('M90 217 L81 195 L106 207 L119 226',accent,w=2)]
        elif actor == 'glimmerfin':
            shapes += [path('M151 255 Q76 263 78 202 Q113 216 143 232 Z',accent)]
        shapes += [path('M152 182 Q113 204 128 267 Q151 295 211 281 Q243 263 231 224 L215 184 Z','url(#coat)'),
                   path('M174 204 Q157 229 168 268 Q192 280 213 264 L211 209 Z',face,w=2),
                   path('M137 265 Q184 282 231 256 L229 274 Q177 294 135 279 Z','#59463c',w=3)]
        if actor in ('relic_beast','moonkip','gloomlet'):
            shapes += [path('M138 142 L115 46 Q161 53 183 107 L205 96 Q221 50 251 46 L244 149 Z',body),
                       path('M132 72 L145 126 L171 115 Z',accent,w=2),path('M223 108 L240 70 L237 130 Z',accent,w=2)]
        elif actor == 'emberhorn':
            shapes += [path('M144 132 Q102 99 113 62 Q127 91 166 92 L220 92 Q254 90 263 60 Q278 105 239 141 Z','#d8bb87'),
                       path('M165 85 L187 47 L196 91 L216 68 L218 103',accent,w=2)]
        elif actor == 'mosskin':
            shapes += [path('M129 143 L115 100 L138 79 L161 96 L184 72 L200 95 L229 80 L251 122 L238 150 Z',body),
                       path('M125 104 Q141 76 159 94 Q180 65 198 92 Q226 66 244 106 L223 122 L147 120 Z',accent,w=2)]
        elif actor == 'pebblewyrm':
            shapes += [path('M136 136 L129 97 L155 91 L172 62 L188 91 L222 75 L246 109 L238 148 Z',body),
                       path('M161 95 L172 62 L188 91 L198 104 Z',accent,w=2)]
        else:
            shapes += [path('M144 156 L98 100 L142 108 L170 58 L195 103 L232 65 L239 147 Z',accent),
                       path('M110 110 L143 132 M174 77 L187 120 M225 83 L223 126','none',body,2)]
        shapes += [path('M137 124 Q162 98 211 107 Q238 111 245 146 L269 158 Q280 178 253 193 Q232 211 183 203 Q147 198 135 174 Z','url(#face)'),
                   path('M183 170 Q215 164 252 178 L263 179 Q248 201 218 203 L184 191 Z',face,w=2),
                   path('M202 136 Q218 123 235 139 L229 157 L208 155 Z','#182131',w=2),
                   path('M219 136 L229 138 L225 149 L217 149 Z',accent,w=0),
                   path('M198 132 L229 126','none',body,5),
                   path('M257 158 L270 165 L257 173 L250 167 Z','#192333',w=2),
                   path('M232 188 Q247 191 256 181','none','#263041',2)]
        if actor == 'mosskin':
            shapes += [path('M155 143 L167 163 L153 184 M144 122 L167 123 M178 185 L186 201','none','#344f47',3)]
        if actor == 'gloomlet':
            shapes += [path('M183 119 L177 86 L193 104 M237 121 L250 89 L250 134',accent,w=3)]
    else:
        broad = actor in ('ruin_warden','ashtrail_hunter','patch')
        l = 133 if broad else 145
        shapes += [path(f'M{l} 176 Q121 220 124 294 L166 282 L188 234 L220 294 L244 279 Q239 219 217 170 Z',body),
                   path(f'M{l} 177 L171 154 L211 155 L233 181 L222 243 Q180 260 140 239 Z','url(#coat)'),
                   path('M177 160 L194 185 L207 160 L214 209 L194 220 L171 207 Z',face,w=2),
                   path('M146 231 L220 230 L224 248 L142 248 Z','#302d38',w=3),
                   path('M185 233 L201 233 L201 245 L185 245 Z',accent,w=2)]
        hair = {'vault_runner':'#30282b','ruin_warden':'#343032','nightstage_drifter':'#54446c','velvet_astrologer':'#c6ced5','ashtrail_hunter':'#924f39','patch':'#6b493b','sera':'#ccd0dd','ilex':'#e9e2d8'}[actor]
        shapes += [path('M167 144 L169 162 L196 177 L211 154 L204 135 Z',face),
                   path('M160 82 Q191 63 219 85 L229 121 L241 133 L230 144 L225 161 L203 169 L180 154 L165 135 Z','url(#face)'),
                   path('M211 114 L226 116 L221 124 L209 122 Z','#192333',w=1),
                   path('M209 110 L226 111','none',hair,4),
                   path('M218 150 L229 147','none','#593f41',2),
                   path('M158 123 Q140 88 164 70 Q197 51 222 76 L227 101 L211 92 L193 98 L177 126 L173 140 L163 129 Z',hair)]
        if actor == 'nightstage_drifter':
            shapes += [path('M154 88 L160 58 L176 70 L189 52 L195 76 L219 78 L208 105 L190 112 L171 129 Z',hair),
                       path('M212 118 L228 120','none','#332438',3),path('M172 127 L174 140',accent,w=3)]
        elif actor in ('velvet_astrologer','sera'):
            shapes += [path('M163 108 Q133 177 150 226 L164 206 L170 142 Z',hair),path('M211 80 L215 114 L209 145 L216 169','none',hair,8),
                       path('M143 195 L152 190 L165 199 M220 193 L229 201 M172 216 L193 210 L214 219','none',accent,3)]
        elif actor == 'ashtrail_hunter':
            shapes += [path('M184 147 L202 169 L226 164 L233 145 L214 153 L205 143 Z',hair,w=2),
                       path('M144 175 L127 189 L130 211 L154 217 L170 191 Z',accent),path('M221 131 L216 140','none','#b67f72',2)]
        elif actor in ('ruin_warden','patch'):
            shapes += [path('M145 173 L124 182 L126 212 L159 218 L174 185 Z',accent),
                       path('M181 147 L207 165 L226 157','none',hair,3),path('M156 87 L164 66 M166 85 L176 65 M179 80 L188 63','none','#6d655b',3)]
        else:
            shapes += [path('M137 199 L155 195 L161 213 L145 218 Z',accent),path('M174 173 L183 207 L191 211','none',accent,3)]
    # Explicit value planes survive SVG importers that flatten gradients.
    if creature:
        shapes += [path('M143 138 Q140 163 155 181 L174 192 L164 166 L166 146 Z',body,w=0),
                   path('M178 119 Q206 109 226 124 L228 132 Q207 120 185 128 Z',face,w=0),
                   path('M134 217 Q128 248 142 270 L159 278 L151 250 L155 215 Z',body,w=0),
                   path('M176 214 L188 208 L202 211 L199 216 L184 219 Z',accent,w=0)]
    else:
        shapes += [path('M145 193 L159 180 L166 208 L154 233 L142 231 Z',body,w=0),
                   path('M178 89 Q196 79 214 93 L216 106 L205 105 L196 92 L184 100 Z',face,w=0),
                   path('M158 83 Q179 62 204 76 L196 82 L178 81 L166 97 Z',hair,w=0),
                   path('M202 188 L216 180 L222 209 L212 224 L205 210 Z',accent,w=0)]
    if actor == 'patch':
        shapes += [path('M145 199 L178 195 L212 211 L216 279 L145 285 Z','#55443e'),path('M153 221 L172 218 L176 241 L155 244 Z',accent,w=2)]
    elif actor == 'sera':
        shapes += [path('M164 82 L181 34 L207 65 L235 71 L253 100 L222 97 L202 84 Z',body),path('M168 144 L184 155 L210 147 L226 163 L198 188 L169 178 Z',accent,w=2)]
    elif actor == 'ilex':
        shapes += [path('M166 94 L164 65 L191 58 L215 81 L202 98 Z','#e9e2d8'),path('M207 115 L226 116 L228 128 L206 127 Z','none','#d6b47a',2),path('M156 192 L161 219 L171 204 Z',accent,w=2)]
    # A shared Core motif anchors identities without baking a weapon into the body.
    shapes += [path('M187 211 L197 218 L191 232 L179 226 Z',accent,w=2),
               path('M186 216 L191 220 L188 225', '#fff3c6',w=0)]
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="384" height="384" viewBox="0 0 384 384">
<defs><linearGradient id="coat" gradientUnits="userSpaceOnUse" x1="130" y1="170" x2="220" y2="290"><stop stop-color="{body}"/><stop offset="1" stop-color="#202a3d"/></linearGradient><linearGradient id="face" gradientUnits="userSpaceOnUse" x1="145" y1="100" x2="255" y2="195"><stop stop-color="{face}"/><stop offset="1" stop-color="{body if creature else face}"/></linearGradient></defs>
{''.join(shapes)}</svg>'''
    (OUT / f'{actor}.svg').write_text(svg, encoding='utf-8')
print(f'Authored {len(PALETTES)} original combat torso/head layers')
