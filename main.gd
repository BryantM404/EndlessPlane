extends Node2D

@export var kamikaze_scene : PackedScene
@export var powerup_scene : PackedScene
@export var spawn_timer : Timer
@export var margin_y : float = 150.0
var score: float = 0.0
var score_multiplier: float = 1.0
var multiplier_timer: Timer

func _ready():
	spawn_timer.start()
	$CanvasLayer/ScoreLabel.text = "0"
	
	multiplier_timer = Timer.new()
	multiplier_timer.one_shot = true
	multiplier_timer.wait_time = 10.0
	multiplier_timer.timeout.connect(_on_multiplier_timeout)
	add_child(multiplier_timer)
	
	var powerup_spawner = Timer.new()
	powerup_spawner.wait_time = 3.0
	powerup_spawner.autostart = true
	powerup_spawner.timeout.connect(_on_powerup_spawn)
	add_child(powerup_spawner)
	
func _process(delta: float) -> void:
	score += (200 * score_multiplier) * delta
	$CanvasLayer/ScoreLabel.text = str(int(score))
	
func activate_score_multiplier():
	score_multiplier = 2.0
	multiplier_timer.start()
	
func _on_multiplier_timeout():
	score_multiplier = 1.0

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
	
func _on_powerup_spawn():
	# Cek dulu apakah scene-nya sudah dimasukkan, kalau belum jangan error
	if powerup_scene == null:
		print("Error : power up kosong di inspector")
		return
	print("Muncul, powerup lagi terbang ke layar")
		
	var pu = powerup_scene.instantiate()
	get_tree().current_scene.add_child(pu)
	
	var screen_size = get_viewport_rect().size
	var margin_x = 100 
	
	# Posisi Y diacak dari atas ke bawah
	var y_new = randf_range(margin_y, screen_size.y - margin_y)
	var spawn_x = get_viewport_transform().affine_inverse().origin.x + screen_size.x + margin_x
	
	pu.global_position = Vector2(spawn_x, y_new)
