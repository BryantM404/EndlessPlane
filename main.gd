extends Node2D

@export var kamikaze_scene : PackedScene
@export var spawn_timer : Timer
@export var margin_y : float = 150.0
var score = 0

func _ready():
	spawn_timer.start()
	
#func _process(delta: float) -> void:
	#score += 1
	#$CanvasLayer/ScoreLabel.text = str(score)

func _on_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	var enemy = kamikaze_scene.instantiate()
	get_tree().current_scene.add_child(enemy)

	var screen_size = get_viewport_rect().size
	var margin_x = 100 
	var max_attempts = 15
	var y_new = 0.0
	var attempt = 0
	var found_pos = false

	while attempt < max_attempts:
		y_new = randf_range(margin_y, screen_size.y - margin_y)
		var ok = true
	
		for k in get_tree().get_nodes_in_group("kamikaze"):
			if abs(k.global_position.y - y_new) < margin_y:
				ok = false
				break
		
		if ok:
			found_pos = true
			break
		attempt += 1
		
	var spawn_x = get_viewport_transform().affine_inverse().origin.x + screen_size.x + margin_x
	
	enemy.global_position = Vector2(spawn_x, y_new)
	enemy.add_to_group("kamikaze")
