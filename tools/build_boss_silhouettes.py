"""Original profile-facing boss silhouettes, using our own regional ink layers."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]/'art/sprites/enemies/beta'
hound=(root/'regional_hound.svg').read_text(encoding='utf-8')
details={
'lantern_jackal': '''<path fill="#494761" d="M128 119Q149 91 153 60L145 43L155 41L168 63Q164 101 146 128Z"/><path fill="#b6a06a" d="M141 29L163 26L173 56L144 62Z"/><path fill="#fff2a4" d="M145 35L159 33L165 52L147 55Z"/><path fill="none" stroke="#91724c" d="M145 36L147 53M154 34L159 53"/><path fill="#868496" d="M45 74L42 38L65 66L62 81ZM106 69L122 33L128 68L117 86Z"/><path fill="#d6bd79" d="M71 133L88 150L109 134L106 153L88 164L73 154Z"/><path fill="#d7e7cd" d="M151 99L175 75Q174 114 157 131L140 136Z"/>''',
'belljaw': '''<path fill="#718eaa" d="M121 111Q131 87 131 61L143 43L147 81L164 60L160 111L176 95Q166 140 147 142Z"/><path fill="#c8e5ec" d="M135 97L142 58L146 103L157 84L149 120L135 130Z"/><path fill="#d6ad68" d="M143 68L159 67L165 84L139 85ZM146 87L155 87L154 94L148 94Z"/><path fill="#52657c" d="M26 114Q42 138 85 134L103 120Q92 158 54 158L25 140Z"/><path fill="#eff8ed" d="M33 122L39 145L46 128L52 152L59 135L69 151L74 132L86 143L88 127Z"/><path fill="#c4dff0" d="M108 149L121 128L130 149L141 144L143 174L116 179Z"/><path fill="#b6975c" d="M82 139L98 138L103 157L77 160ZM85 162L96 162L93 170L87 170Z"/>'''}
for name,detail in details.items():
    (root/(name+'.svg')).write_text(hound.replace('</g></svg>', '<path fill="#4f6877" stroke="none" d="M115 103Q135 108 141 133L142 159L133 147L116 142Z"/><path fill="#c4d9db" stroke="none" d="M55 81Q77 68 100 76L94 84L71 86Z"/><path fill="#547587" stroke="none" d="M42 127Q59 143 73 141L64 151L49 146Z"/>'+detail+'</g></svg>'),encoding='utf-8')
print('Two original boss silhouettes: lantern-bearing jackal and frost/bell jaw beast')
