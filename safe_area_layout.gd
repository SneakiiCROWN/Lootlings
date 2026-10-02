extends Node

const DESIGN := Vector2(480, 854)
var game: Control

func configure(target: Control) -> void:
	game = target
	if OS.get_name() != "Android": return
	get_window().size_changed.connect(func(): call_deferred("refresh"))
	call_deferred("refresh")

static func fit_in(safe: Rect2) -> Rect2:
	var available := safe.intersection(Rect2(Vector2.ZERO, DESIGN))
	if available.size.x <= 0.0 or available.size.y <= 0.0:
		return Rect2(Vector2.ZERO, DESIGN)
	var factor := minf(1.0, minf(available.size.x / DESIGN.x, available.size.y / DESIGN.y))
	var extent := DESIGN * factor
	return Rect2(available.get_center() - extent * 0.5, extent)

func refresh() -> void:
	var safe := Rect2(DisplayServer.get_display_safe_area())
	if safe.size.x <= 0 or safe.size.y <= 0: return
	# DisplayServer returns physical screen coordinates. Convert through the
	# engine's actual letterbox/stretch transform before fitting the fixed UI.
	var screen_to_canvas := get_window().get_screen_transform().affine_inverse()
	var logical := Rect2(screen_to_canvas * safe.position, screen_to_canvas.basis_xform(safe.size))
	apply(logical)

func apply(logical_safe: Rect2) -> void:
	var frame := fit_in(logical_safe)
	game.set_anchors_preset(Control.PRESET_TOP_LEFT)
	game.size = DESIGN
	game.position = frame.position
	game.scale = Vector2.ONE * (frame.size.x / DESIGN.x)
	game.queue_redraw()
