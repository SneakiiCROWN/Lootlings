# QA and Release Checklist

## Every gameplay tranche
- parser/import clean
- focused new tests
- smoke
- save migration
- inventory/equipment
- economy
- deterministic seed repeat where relevant
- git diff --check
- clean/pushed checkpoint

## Character selection
- all seven Lootlings selectable
- missing final art does not remove identity
- Wanderer selectable when architecture lands
- avatar persists restart
- old saves migrate
- no appearance field changes stats
- randomise never produces invalid asset IDs

## Customisation
- dark/light skin tones render correctly
- hair does not disappear under normal outfits
- horn-compatible hairstyles tested
- modest/revealing variants are optional
- no clipping severe enough to hide face/weapon
- outfit appearance and stat item can differ safely

## Weapons
For each of 12:
- inventory icon
- held sprite/fallback
- correct facing
- grip plausible
- no face obstruction
- projectile socket if ranged
- impact position
- stage evolution fallback
- Lootling render
- Wanderer render

## NPC/dialogue
- correct speaker
- no overflow
- no repeated bark spam
- state tags correct
- no unearned boss references
- transition cancels bubble
- adult flirt/raunchy lines only on adult characters
- child/background NPC pools never receive adult-flirt content

## Routes
- deterministic seed
- no softlock
- room reward once
- merchant once
- chest claim once
- completion semantics clear
- campaign unlock only through intended path
- resume/quit behaviour documented

## Art
- alpha edge clean
- no source-board text/neighbours
- provenance updated
- reference source untouched
- native phone render inspected
- no distorted aspect ratio
- no accidental copyrighted logo/character copied from inspiration

## Performance
- three-enemy stress
- projectile stress
- status/VFX stress
- UI transitions
- memory bounded
- Android test required before mobile release claim

## Release wording
Never claim:
- final humanoid customisation if only presets exist;
- final art if beta crops remain;
- boss mechanics if only presentation changed;
- Android certification from desktop timing;
- online/co-op ownership without server authority.

State exactly what is live, beta, planned and deferred.
