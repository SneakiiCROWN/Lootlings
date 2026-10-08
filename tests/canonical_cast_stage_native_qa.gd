extends "res://tests/phase4_native_qa.gd"
# extends SceneTree via guarded native helper. Candidates stay outside runtime.
const Authored=preload("res://authored_pose_manifest.gd")
const Fit=preload("res://weapon_fit_catalog.gd")
var verify_installed:=false
const DIR="res://docs/production/full-completion/continuous-production/playable-cast-candidates/"
func review() -> void:
 var staged:Array=JSON.parse_string(FileAccess.get_file_as_string(DIR+"CONTACT_STAGE.json"))
 var observations:=[]
 if not verify_installed:
  Authored.extracted_loaded=true;Authored.extracted_rows=[];Authored.extracted_resolved={}
  for row in staged:
   var key:String="res://art/production/phase4e/lootlings/"+row.actor+"/stage/"+row.filename
   var phase:String={"windup":"ANTICIPATE","strike_or_cast":"ATTACK","recovery":"RECOVER"}[row.state]
   var rect:=Rect2(-96,-128,192,192)
   var im:=Image.load_from_file(DIR+"technical-exports/"+row.filename)
   var fg:=Image.load_from_file(DIR+"technical-exports/"+row.foreground_filename)
   Authored.extracted_rows.append({"actor":row.actor,"phase":phase,"facing":row.facing+"_only","weapon_types":["wand"],"asset_path":key})
   Authored.extracted_resolved[key]={"texture":ImageTexture.create_from_image(im),"body_rect":rect,"primary_hand":rect.position+Vector2(row.primary_palm[0],row.primary_palm[1])/512*rect.size,"secondary_hand":rect.position+Vector2(row.secondary_palm[0],row.secondary_palm[1])/512*rect.size,"core":rect.position+Vector2(row.core_or_eye[0],row.core_or_eye[1])/512*rect.size,"supports_two_hand":false,"depth":"back","facing_support":row.facing+"_only","wardrobe_requires":{},"feet_baseline":58.0,"weapon_types":["wand"],"weapon_overrides":{},"foreground":ImageTexture.create_from_image(fg),"baked_weapon":"","extracted_pose":true,"extracted_idle":false}
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
  root.size=viewport;folder="res://.godot_test_data/canonical-cast-stage/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
  for row in staged:
   helper.prepare(row.actor,"wand");game.forced_facing_test=-1 if row.facing=="left" else 1
   game.enemy_encounter.clear();game.attack_projectiles.clear();game.player_flash=0
   game.attack_anim=.22 if row.state=="strike_or_cast" else .045 if row.state=="recovery" else 0
   game.attack_clock=.025 if row.state=="windup" else game.current_attack_interval()
   var rng=game.rng.state;var loot_rng=game.loot_system.rng.state;var damage=game.base_damage;var interval=game.current_attack_interval()
   var pose:=Fit.sample(game)
   assert(not pose.sprite_rig and pose.extracted_pose,"Missing candidate selector: "+row.slot_id)
   assert(pose.authored_facing==row.facing+"_only")
   var grip:Vector2=pose.weapon_rect.position+Vector2(pose.geometry.grip)*pose.weapon_rect.size
   var held:Transform2D=pose.root*Transform2D(pose.weapon_rotation,pose.weapon_scale,0,pose.hand)
   assert((held*grip).distance_to(pose.root*pose.hand)<.001)
   assert(pose.foreground is Texture2D)
   assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.base_damage==damage and game.current_attack_interval()==interval)
   game.queue_redraw();await create_timer(.06).timeout;await RenderingServer.frame_post_draw
   var capture_image:=root.get_texture().get_image()
   var center:Vector2=root.get_screen_transform()*game.get_global_transform()*preload("res://combat_stage.gd").player_position(game,pose)-Vector2(root.position)
   var scale:Vector2=root.get_screen_transform().get_scale()*game.get_global_transform().get_scale()
   var crop:=Rect2i(Vector2i(center-Vector2(115,155)*scale),Vector2i(Vector2(230,225)*scale))
   var body:=capture_image.get_region(crop);body.resize(384,376,Image.INTERPOLATE_LANCZOS);body.save_png(folder+row.filename)
   if row.state=="strike_or_cast" and row.facing=="right":capture_image.save_png(folder+"screen_"+row.filename)
   var module:Texture2D=preload("res://weapon_catalog.gd").presentation_texture("wand","held",load("res://art/sprites/weapons/mage_staff.png"))
   var projectile_pixel:Vector2=(pose.root.affine_inverse()*pose.projectile-pose.body_rect.position)/pose.body_rect.size*512
   if verify_installed:assert(pose.texture.resource_path==row.runtime_path)
   observations.append({"slot_id":row.slot_id,"viewport":str(viewport),"selector":true,"grip_error":(held*grip).distance_to(pose.root*pose.hand),"sprite_rig":false,"foreground":true,"gameplay_unchanged":true,"module_file":module.resource_path,"module_size":[pose.weapon_rect.size.x,pose.weapon_rect.size.y],"module_angle":pose.weapon_rotation,"module_grip_uv":[pose.geometry.grip.x,pose.geometry.grip.y],"projectile_origin":[projectile_pixel.x,projectile_pixel.y],"body_path":pose.texture.resource_path,"installed":verify_installed})
  helper.free();game.free();await process_frame
 var report=FileAccess.open("res://.godot_test_data/canonical-cast-stage/"+("INSTALLED_CHECKS.json" if verify_installed else "CONTACT_CHECKS.json"),FileAccess.WRITE);report.store_string(JSON.stringify(observations,"\t"));report.close()
 print("CAST STAGE NATIVE PASS: ",staged.size()," independent candidate cells, phone/tablet actual renderer, source foreground, existing wand/grip/projectile transforms, gameplay/RNG unchanged; visual acceptance still required")
 quit()
