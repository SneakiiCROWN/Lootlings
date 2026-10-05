extends RefCounted
const Rig=preload("res://combat_sprite_rig.gd")
const IDS={"Salvager":"patch","Relic Keeper":"sera","Archivist":"ilex"}
const COLORS={"patch":["#73534b","#c39672"],"sera":["#68547b","#d7baa4"],"ilex":["#385264","#e2c9b7"]}

static func draw(g, speaker: String, rect: Rect2, clock: float, activity: String) -> void:
	var id: String=IDS[speaker]
	var color:=Color(COLORS[id][0])
	var skin:=Color(COLORS[id][1])
	var facing: float=1 if speaker=="Salvager" else -1
	var primary:=Vector2(31,-15)
	var secondary:=Vector2(7,-4)
	if activity=="repair": primary=Vector2(20,-20-sin(clock*5)*15); secondary=Vector2(12,-3)
	elif activity=="read": primary=Vector2(23,-12); secondary=Vector2(8,-8)
	elif activity=="inspect": primary=Vector2(29,-28); secondary=Vector2(10,-17)
	elif activity=="talk": primary=Vector2(33,-26+sin(clock*2)*3)
	var scale: float=rect.size.y/170
	var root:=Transform2D(0,Vector2(facing,1)*scale,0,Vector2(rect.get_center().x,rect.end.y-61*scale))
	g.draw_set_transform_matrix(root)
	for index in range(2):
		var hip:=Vector2(-13+index*26,6)
		var stride: float=sin(clock*8)*8 if activity=="walk" else 0
		var foot:=Vector2(-22+index*45+(stride if index==0 else -stride),61)
		var knee:=hip.lerp(foot,.5)+Vector2(-4,0)
		if activity=="sit": knee.x+=12; foot.x+=10
		Rig.segment(g,hip,knee,15,color.darkened(.15))
		Rig.segment(g,knee,foot,12,color)
		g.draw_style_box(Rig.boot_box(color.darkened(.3)),Rect2(foot+Vector2(-8,-5),Vector2(23,9)))
	Rig.arm(g,Vector2(-18,-34),secondary,color.darkened(.15),true)
	g.draw_texture_rect(Rig.texture(id),Rect2(-96,-128,192,192),false)
	Rig.arm(g,Vector2(13,-36),primary,color,false)
	if activity=="repair":
		g.draw_line(primary,primary+Vector2(-1,-22),Color("#b59661"),4,true)
		g.draw_style_box(Rig.boot_box(Color("#8e9ba5")),Rect2(primary+Vector2(-13,-28),Vector2(24,10)))
	elif activity in ["read","inspect"] and speaker=="Archivist":
		g.draw_colored_polygon(PackedVector2Array([Vector2(3,-17),Vector2(18,-20),Vector2(37,-15),Vector2(37,-3),Vector2(18,-7),Vector2(3,-4)]),Color("#dec997"))
		g.draw_line(Vector2(18,-20),Vector2(18,-7),Color("#79634d"),1,true)
	elif activity=="inspect" and speaker=="Relic Keeper":
		g.draw_circle(primary+Vector2(0,-8),7,Color("#8c69b1"))
		g.draw_circle(primary+Vector2(-1,-10),3,Color("#ddc4ff"))
	for hand in [primary,secondary]:
		g.draw_circle(hand,5,Color("#172334")); g.draw_circle(hand,3.5,skin)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
