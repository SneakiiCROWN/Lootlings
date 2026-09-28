extends Sprite2D

@export var speed: float = 180.0
@export var stop_distance: float = 150.0
@export var attack_speed: float = 0.6

@onready var enemy = $"../Enemy"

var attack_timer: float = 0.0

func _process(delta):
	if not is_instance_valid(enemy):
		return

	var distance = global_position.distance_to(enemy.global_position)

	if distance > stop_distance:
		global_position = global_position.move_toward(
			enemy.global_position,
			speed * delta
		)
	else:
		attack_timer -= delta

		if attack_timer <= 0:
			attack_timer = attack_speed
			attack_enemy()


func attack_enemy():
	print("BONK! Lootling attacks!")

	enemy.scale = Vector2(0.85, 0.85)

	var tween = create_tween()
	tween.tween_property(enemy, "scale", Vector2.ONE, 0.12)
