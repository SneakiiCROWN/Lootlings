extends Node
# Explicit test-feature-only telemetry. No gameplay ticks, timers or texture loads.
# Whole frame intervals include OS scheduling; desktop numbers are not device proof.
const REPORT_PATH := "user://device_test_report.json"
var game
var started_usec := Time.get_ticks_usec()
var previous_usec := 0
var first_menu_ms := -1.0
var sample_count := 0
var total_frame_ms := 0.0
var worst_frame_ms := 0.0
var over_33ms := 0
var histogram: Array[int] = []
var combat_histogram: Array[int] = []
var combat_samples := 0
var contexts: Array[Dictionary] = []
var lifecycle := {"focus_out": 0, "focus_in": 0, "paused": 0, "resumed": 0}
var last_state := ""
var report_panel: CanvasLayer
var report_saved := false

func configure(target) -> void:
	game = target
	process_mode = Node.PROCESS_MODE_ALWAYS
	histogram.resize(251)
	histogram.fill(0)
	combat_histogram.resize(251)
	combat_histogram.fill(0)

func _process(_delta: float) -> void:
	if game == null: return
	var now := Time.get_ticks_usec()
	if previous_usec > 0:
		var ms := float(now - previous_usec) / 1000.0
		# Lifecycle notifications reset previous_usec, excluding background gaps.
		# Keep long foreground stalls: these are important loading/pacing evidence.
		if ms > 0.0:
			var bucket := mini(250, maxi(0, int(ceil(ms))))
			histogram[bucket] += 1
			sample_count += 1
			total_frame_ms += ms
			worst_frame_ms = maxf(worst_frame_ms, ms)
			if ms > 33.34: over_33ms += 1
			if game.state == "playing" and not get_tree().paused:
				combat_histogram[bucket] += 1
				combat_samples += 1
	previous_usec = now
	if first_menu_ms < 0 and game.state in ["boot", "title", "profile", "hideout"]:
		first_menu_ms = float(now - started_usec) / 1000.0
	if game.state != last_state:
		last_state = game.state
		checkpoint("state:" + last_state)

func _notification(what: int) -> void:
	if game == null: return
	var event := ""
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT: event = "focus_out"
		NOTIFICATION_APPLICATION_FOCUS_IN: event = "focus_in"
		NOTIFICATION_APPLICATION_PAUSED: event = "paused"
		NOTIFICATION_APPLICATION_RESUMED: event = "resumed"
	if not event.is_empty():
		lifecycle[event] += 1
		previous_usec = 0
		checkpoint(event)

func percentile(bins: Array[int], count: int, proportion: float) -> int:
	if count == 0: return 0
	var wanted := int(ceil(count * proportion))
	var current := 0
	for i in range(bins.size()):
		current += bins[i]
		if current >= wanted: return i
	return 250

func report() -> Dictionary:
	return {"test_build": true, "captured_unix": Time.get_unix_time_from_system(),
		"platform": OS.get_name(), "model": OS.get_model_name(),
		"engine": Engine.get_version_info().string, "state": game.state,
		"loading_node_to_first_menu_ms": first_menu_ms,
		"loading_note": "Starts when game node is ready; excludes Android process/engine startup. Time cold launch separately.",
		"screen_pixels": str(DisplayServer.screen_get_size()),
		"safe_area_pixels": str(DisplayServer.get_display_safe_area()),
		"window_pixels": str(DisplayServer.window_get_size()),
		"viewport_rect": str(game.get_viewport().get_visible_rect()),
		"samples": sample_count, "combat_samples": combat_samples,
		"average_fps": 1000.0 * sample_count / maxf(1.0, total_frame_ms),
		"frame_p50_ms": percentile(histogram, sample_count, 0.50),
		"frame_p95_ms": percentile(histogram, sample_count, 0.95),
		"frame_p99_ms": percentile(histogram, sample_count, 0.99),
		"combat_frame_p95_ms": percentile(combat_histogram, combat_samples, 0.95),
		"worst_frame_ms": worst_frame_ms, "frames_over_33ms": over_33ms,
		"histogram_note": "1 ms buckets, values >=250ms in terminal bucket; lifecycle events reset the frame clock.",
		"texture_memory_bytes": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
		"static_memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"memory_note": "Godot counters; not Android process PSS/GPU driver memory. Capture adb dumpsys meminfo separately.",
		"lifecycle": lifecycle.duplicate(), "recent_contexts": contexts.duplicate(true)}

func checkpoint(reason: String) -> void:
	if game == null: return
	contexts.append({"reason": reason, "elapsed_ms": (Time.get_ticks_usec() - started_usec) / 1000,
		"state": game.state, "tree_paused": get_tree().paused})
	if contexts.size() > 16: contexts.pop_front()
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	report_saved = file != null
	if file != null:
		file.store_string(JSON.stringify(report(), "  "))
		file.flush()
		report_saved = file.get_error() == OK

func show_report() -> void:
	checkpoint("user_report")
	if is_instance_valid(report_panel): report_panel.queue_free()
	report_panel = CanvasLayer.new()
	report_panel.layer = 100
	# CanvasLayer does not inherit the safe-area root's transform.
	report_panel.transform = game.get_global_transform()
	add_child(report_panel)
	var veil := ColorRect.new()
	veil.color = Color(0.02, 0.03, 0.07, 0.88)
	veil.size = Vector2(480, 854)
	report_panel.add_child(veil)
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 100)
	panel.size = Vector2(432, 620)
	var surface := StyleBoxFlat.new()
	surface.bg_color = Color("#101c31")
	surface.border_color = Color("#78e4ff")
	surface.set_border_width_all(2)
	surface.set_corner_radius_all(12)
	surface.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", surface)
	report_panel.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	var title := Label.new()
	title.text = "S23 TEST REPORT"
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	var data := report()
	var summary := Label.new()
	var save_status := "Report saved on this device." if report_saved else "Report write failed; send screenshot."
	summary.text = "FPS %.1f · frames %d\nFrame p95 %d ms · p99 %d ms\nCombat p95 %d ms\nTexture %.1f MiB · static %.1f MiB\nOver 33ms: %d\nFocus out / in: %d / %d\nPause / resume: %d / %d\n\n%s\nAttach report with the PC collector.\n\nCold launch, thermal load and touch\nreadability still need human checks." % [data.average_fps, sample_count, data.frame_p95_ms, data.frame_p99_ms, data.combat_frame_p95_ms, data.texture_memory_bytes / 1048576.0, data.static_memory_bytes / 1048576.0, over_33ms, lifecycle.focus_out, lifecycle.focus_in, lifecycle.paused, lifecycle.resumed, save_status]
	summary.add_theme_font_size_override("font_size", 18)
	column.add_child(summary)
	var close := Button.new()
	close.text = "Close report"
	close.custom_minimum_size = Vector2(0, 52)
	close.pressed.connect(func(): report_panel.queue_free())
	column.add_child(close)
