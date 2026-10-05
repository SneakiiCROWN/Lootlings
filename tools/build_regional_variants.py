"""Original region anatomy/attachments on the existing original species layers."""
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]/'art/sprites/enemies/beta'
VARIANTS={
 'mossmaw':('hound','<path fill="#68964e" d="M120 98Q118 76 137 67L134 86L151 76L146 106ZM144 132L163 126L157 143L149 142Z"/><path fill="none" stroke="#bbd095" d="M147 99Q145 126 129 141M138 91L140 113"/>'),
 'glasswing':('bat','<path fill="#c1f8f5" d="M31 61L50 70L62 106L44 99ZM173 61L154 70L142 106L160 99Z"/><path fill="none" stroke="#f2ffff" d="M38 72L55 93M166 72L149 93"/>'),
 'bell_bat':('bat','<path fill="#accde7" d="M30 57L16 64L18 93L30 90ZM173 57L187 64L184 93L172 90Z"/><path fill="#d6b45a" d="M90 141Q99 133 109 141L116 160L85 160ZM96 163L106 163L104 171L98 171Z"/>'),
 'rime_pup':('hound','<path fill="#bcecff" d="M125 97L138 67L147 96L159 80L158 114ZM128 123L145 104L148 131L160 127L151 145Z"/><path fill="#f0fcff" d="M41 81L43 47L54 75L65 68L62 86Z"/>'),
 'coal_pup':('hound','<path fill="#413d43" d="M121 96L139 82L156 109L160 137L139 141Z"/><path fill="#ff9a46" d="M127 99L138 114L132 132M144 102L148 121L155 130"/><path fill="#fdd19a" d="M48 155L57 149L55 163L48 167Z"/>'),
 'null_hound':('hound','<path fill="#8d6ec7" d="M132 96L146 75L158 106L143 112ZM143 136L167 117L168 148L157 163Z"/><path fill="none" stroke="#e6c4ff" d="M145 82L151 103M150 142L161 134L160 151"/>'),
 'lantern_toad':('toad','<path fill="none" stroke="#9a8955" d="M51 81Q42 33 77 29L84 43"/><path fill="#ffde88" d="M78 29L93 29L97 45L75 45Z"/><path fill="#fff5bc" d="M80 33L90 33L91 42L79 42Z"/>'),
 'sluice_crab':('crab','<path fill="#446770" d="M48 112L64 86L77 96L68 130L52 139ZM152 112L136 86L123 96L132 130L148 139Z"/><path fill="#c2bb89" d="M83 106L116 106L116 132L83 132Z"/><path fill="none" stroke="#426274" d="M89 109L89 128M97 109L97 128M105 109L105 128M112 109L112 128"/>'),
 'brassback':('beetle','<path fill="#bd8d4e" d="M61 91L78 75L91 84L90 147L71 134ZM141 91L124 75L111 84L112 147L131 134Z"/><path fill="#efd398" d="M68 95L76 86L78 117L70 118ZM134 95L126 86L124 117L132 118Z"/>'),
 'forge_beetle':('beetle','<path fill="#4e4045" d="M58 90L81 63L95 77L90 159L67 141ZM145 90L121 63L107 77L111 159L135 141Z"/><path fill="none" stroke="#ff8a41" d="M70 91L85 114L74 136M132 91L117 114L128 136M97 79L103 109L98 145"/>'),
 'inkling':('wyrm','<path fill="#514367" d="M140 138Q174 140 171 155Q146 177 130 169Q147 164 140 138Z"/><path fill="#b399e0" d="M136 148L149 154L147 161L136 157Z"/>'),
 'pagewyrm':('wyrm','<path fill="#e2cf9f" d="M48 117L62 110L69 136L80 155L69 161L53 141ZM78 161L90 143L107 151L107 171L92 174ZM115 151L125 146L139 160L126 169Z"/><path fill="none" stroke="#80715d" d="M57 121L61 133M61 138L70 151M88 155L101 159M91 162L101 166"/>'),
 'pressure_sprite':('shard','<path fill="#829aa4" d="M51 89L61 76L65 90L62 123L53 126ZM142 89L132 76L128 90L131 123L140 126Z"/><path fill="none" stroke="#b4efe7" d="M56 84L51 54L61 45M136 84L141 54L131 45"/>'),
 'crown_shard':('shard','<path fill="#d5a452" d="M71 52L61 26L82 38L100 15L119 38L138 26L127 53Z"/><path fill="#fff1b8" d="M92 36L101 27L110 37L101 47Z"/>'),
 'hookwing':('bat','<path fill="none" stroke="#b9c6ce" stroke-width="6" d="M22 74L14 51Q18 36 29 40Q36 45 29 53M181 74L189 51Q185 36 174 40Q167 45 174 53"/><path fill="none" stroke="#506275" d="M20 69L39 91L52 120M184 69L165 91L152 120"/>'),
}
for name,(body,detail) in VARIANTS.items():
    source=(ROOT/f'regional_{body}.svg').read_text(encoding='utf-8')
    # Detail remains within the same bounded canvas, never changes game hitboxes.
    source=source.replace('</g></svg>',detail+'</g></svg>')
    (ROOT/f'{name}.svg').write_text(source,encoding='utf-8')
print(f'Authored {len(VARIANTS)} named regional silhouette variants')
