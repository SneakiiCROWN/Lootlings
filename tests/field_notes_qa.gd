extends SceneTree
const Notes = preload("res://field_notes_catalog.gd")
const Rewards = preload("res://reward_reveal_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false)
	var before := JSON.stringify(game.inventory.stash)
	var state: Dictionary = game.profile.duplicate(true)
	state.memories=[]
	var pages:=Notes.pages(state,game.campaign,game.inventory)
	assert(pages.filter(func(page): return page.category=="CAST").size()==15)
	for page in pages:
		if str(page.id).begins_with("wanderer/"):
			var face: AtlasTexture=page.texture
			var actor: String=str(page.id).get_slice("/",1)
			assert(face.atlas==preload("res://wanderer_catalog.gd").runtime_texture(actor))
			assert(face.region.end.x<=face.atlas.get_width() and face.region.end.y<=face.atlas.get_height())
	for actor in preload("res://lootling_catalog.gd").selectable_ids():
		var neutral:=preload("res://phase4e_extracted_art.gd").neutral_body(actor)
		assert(neutral!=null)
		var memory:=preload("res://vignette_catalog.gd").entry("character/"+actor)
		assert(memory.actor==neutral.resource_path and memory.actor_tint==Color.WHITE)
	assert(pages.filter(func(page): return page.category=="BOSSES").is_empty())
	assert(Notes.pages({},null,null).filter(func(page): return str(page.id).begins_with("route/")).is_empty())
	var discovered_routes := Notes.pages({"memories":["region/act_i"]},null,null).filter(func(page): return str(page.id).begins_with("route/"))
	assert(discovered_routes.size()==3)
	for page in discovered_routes:
		assert(ResourceLoader.exists(page.art) and page.category=="TRAILS")
	state.memories=["boss/hoard_dragon"]
	pages=Notes.pages(state,game.campaign,game.inventory)
	assert(pages.filter(func(page): return page.category=="BOSSES").size()==1)
	for page in pages:
		assert(not page.name.is_empty() and not page.body.is_empty())
		assert(not str(page.body).contains("\u00e2\u20ac"))
		assert(page.get("texture",null) is Texture2D or ResourceLoader.exists(page.art))
	assert(JSON.stringify(game.inventory.stash)==before)
	for region in preload("res://vignette_catalog.gd").REGIONAL_BOSS_IDS:
		var boss: String=preload("res://vignette_catalog.gd").REGIONAL_BOSS_IDS[region]
		assert(not preload("res://vignette_catalog.gd").available("boss/"+boss,{},[]))
		assert(preload("res://vignette_catalog.gd").available("boss/"+boss,{},[region]))
		var entry:=preload("res://vignette_catalog.gd").entry("boss/"+boss)
		assert(entry.actor.is_empty() and ResourceLoader.exists(entry.background))
		assert(entry.lines.size()==3)
		assert(entry.lines[1]==preload("res://world_story.gd").region_line(region,2))
		assert(entry.lines[2]==preload("res://world_story.gd").region_line(region,3))
	var player=game.presentation_director.vignette
	player.actor=load("res://art/sprites/enemies/beta/verdant_mirror.png")
	player.data={"actor_kind":"boss"}
	var extent: Vector2=player.actor_extent()
	assert(is_equal_approx(extent.x/extent.y,player.actor.get_width()/float(player.actor.get_height())))
	assert(extent.x<=360 and extent.y<=320)
	player.actor=null
	var previous:=0.0
	for rarity in preload("res://item_catalog.gd").RARITIES:
		var item:=preload("res://item_catalog.gd").create_item("bonebow",rarity,7)
		var reveal:=Rewards.for_rewards("relic_chest",[item])
		assert(reveal.rarity==rarity and reveal.intensity>previous)
		previous=reveal.intensity
		if rarity=="RED": assert(reveal.audio=="relic_red" and reveal.particles>Rewards.RARITY_PROFILES.LEGENDARY.particles)
	game.free(); print("FIELD NOTES PASS: 15 cast entries, boss discovery gates, owned gear, read-only inventory, five item rarity profiles including RED"); quit()
