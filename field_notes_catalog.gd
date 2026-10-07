extends RefCounted

# Read-only presentation of established canon and owned equipment. No unlock,
# reward, save or RNG writes; unrecovered boss memories remain undisclosed.
const Story = preload("res://world_story.gd")
const Actors = preload("res://lootling_catalog.gd")
const Wanderers = preload("res://wanderer_catalog.gd")
const Memories = preload("res://vignette_catalog.gd")
const Items = preload("res://item_catalog.gd")
const UI = preload("res://lootlings_ui.gd")
const CATEGORIES := ["ALL", "CAST", "TRAILS", "BOSSES", "GEAR"]

static func portrait(actor: String) -> String:
	if preload("res://actor_identity_corrections.gd").corrected_actor(actor):return ""
	var path := "res://art/production/phase4e/ui/expressions/%s_happy.png" % actor
	return path if ResourceLoader.exists(path) else str(Actors.definition(actor).profile_icon)

static func pages(profile: Dictionary, campaign, inventory) -> Array[Dictionary]:
	var result: Array[Dictionary] = [{"id":"story/crownfall", "category":"TRAILS", "name":"The Crownfall", "body":Story.PREMISE, "art":"res://art/backgrounds/lootlings_hideout.png"}]
	for actor in Actors.selectable_ids():
		var entry := Actors.definition(actor)
		result.append({"id":"character/"+actor, "category":"CAST", "name":entry.display_name, "body":Story.ORIGINS[actor]+"\n\n"+entry.personality, "art":portrait(actor)})
	for actor in Wanderers.PRESETS:
		var entry := Wanderers.definition(actor)
		# Appearance is not a fabricated biography or a gameplay restriction.
		# Reuse the accepted HUD portrait region; never manufacture another face.
		var face := preload("res://avatar_presentation.gd").portrait({"avatar_mode":"wanderer", "wanderer":{"preset_id":actor}})
		result.append({"id":"wanderer/"+actor, "category":"CAST", "name":entry.display_name, "body":"Wanderer • "+str(entry.body_frame).capitalize()+" build\n\n"+str(entry.outfit_cosmetic_id).replace("_"," ").capitalize()+"\n\nYour past does not choose your weapon.", "art":entry.runtime_sprite, "texture":face})
	for resident in Memories.RESIDENTS:
		var entry: Dictionary = Memories.RESIDENTS[resident]
		var art: String=preload("res://resident_art_catalog.gd").portrait_path(resident)
		result.append({"id":"resident/"+resident, "category":"CAST", "name":entry.name, "body":Story.NPC_NOTES[entry.name], "art":art})
	for region in Story.REGIONS:
		if campaign != null and campaign.available(region):
			result.append({"id":"region/"+region, "category":"TRAILS", "name":preload("res://campaign_system.gd").title(region), "body":Story.region_line(region,0)+"\n\n"+Story.region_line(region,1), "art":Memories.region_background(region)})
	# The three established Act I locations already have individual paintings
	# and encounter rosters. A recovered region account opens its route notes.
	if "region/act_i" in profile.get("memories",[]) or (campaign!=null and "act_i" in campaign.completed):
		for zone in preload("res://zone_catalog.gd").ZONES:
			var foes: Array[String]=[]
			for enemy in zone.enemies.values(): foes.append(str(enemy.name).capitalize())
			result.append({"id":"route/"+str(zone.id), "category":"TRAILS", "name":str(zone.name).capitalize(), "body":"Act I • "+str(zone.entry).capitalize()+"\n\nKnown patrols\n"+"\n".join(foes), "art":zone.background.resource_path})
	for boss in Memories.boss_entries():
		if not Memories.available("boss/"+boss,profile,campaign.completed if campaign!=null else []): continue
		var entry: Dictionary = Memories.boss_entries()[boss]
		result.append({"id":"boss/"+boss, "category":"BOSSES", "name":entry.name, "body":entry.epithet+"\n\n"+entry.line, "art":entry.art if not str(entry.art).is_empty() else Memories.region_background(entry.region)})
	if inventory != null:
		var seen := {}
		var owned: Array = inventory.stash.duplicate()
		for slot in ["Weapon","Armour","Relic","Rune"]:
			var equipped: Dictionary = inventory.equipped_item(slot)
			if not equipped.is_empty(): owned.append(equipped)
		for item in owned:
			var key := str(item.id)+"/"+str(item.rarity)+"/"+str(item.get("evolution_stage",0))+"/"+str(item.get("affix_ids",[]))+"/"+JSON.stringify(item.get("effects",{}))
			if seen.has(key): continue
			seen[key]=true
			result.append({"id":"gear/"+key, "category":"GEAR", "name":item.name, "body":Items.display_identity(item)+" • "+str(item.rarity)+"\n\n"+str(item.get("desc",""))+"\n\n"+Items.describe_effects(item)+"\n\n"+Items.evolution_hint(item), "art":UI.item_texture(item).resource_path, "texture":UI.item_texture(item)})
	return result
