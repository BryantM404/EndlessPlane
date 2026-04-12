extends Node2D

@export var kamikaze_scene : PackedScene
@export var powerup_scene : PackedScene
@export var bomb_scene : PackedScene
@export var spawn_timer : Timer
@export var margin_y : float = 40.0
@export var margin_x_bomb : float = 50.0

@onready var bg_container = $BackgroundContainer
var backgrounds = [
	preload("res://background_paris.tscn"),
	preload("res://background_forest.tscn"),
	preload("res://background_winternight.tscn"),
	preload("res://background_skies.tscn"),
	preload("res://background_moon.tscn"),
]
var current_bg = null
var bg_state = -1
var transition_scene = preload("res://transition.tscn")

var score: float = 0.0
var score_multiplier: float = 1.0
var multiplier_timer: Timer

var game_over_scene = preload('res://game_over_scene.tscn')
#var game_over_ui = null

func _ready():
	Engine.time_scale = 1
	spawn_timer.start()
	$CanvasLayer/ScoreLabel.text = "0"
	
	change_background(0)
	bg_state = 0
	add_to_group("game")
		
	# Timer untuk durasi Power-Up
	multiplier_timer = Timer.new()
	multiplier_timer.one_shot = true
	multiplier_timer.wait_time = 10.0
	multiplier_timer.timeout.connect(_on_multiplier_timeout)
	add_child(multiplier_timer)
	
	# Timer untuk munculin Power-Up
	var powerup_spawner = Timer.new()
	powerup_spawner.wait_time = 15.0 
	powerup_spawner.autostart = true
	powerup_spawner.timeout.connect(_on_powerup_spawn)
	add_child(powerup_spawner)
	
func _process(delta: float) -> void:
	score += (200 * score_multiplier) * delta
	$CanvasLayer/ScoreLabel.text = str(int(score))
	update_background(score)
	
func activate_score_multiplier():
	score_multiplier = 2.0
	multiplier_timer.start()
	
func _on_multiplier_timeout():
	score_multiplier = 1.0

func _on_timer_timeout():
	if randf() > 0.3:
		spawn_enemy()
	else:
		spawn_bomb()

func spawn_enemy():
	var enemy = kamikaze_scene.instantiate()
	get_tree().current_scene.add_child(enemy)

	var screen_size = get_viewport_rect().size
	var player = get_tree().get_first_node_in_group("player")
	var margin_x = 100 
	var y_new = 0.0
	
	var batas_bawah_layar = screen_size.y - 35.0 
	var batas_atas_layar = 35.0 

	if player:
		if player.global_position.y > (screen_size.y * 0.8):
			y_new = clamp(player.global_position.y, margin_y, batas_bawah_layar)
		elif player.global_position.y < (screen_size.y * 0.2):
			y_new = clamp(player.global_position.y, batas_atas_layar, screen_size.y - margin_y)		
		else:
			y_new = randf_range(margin_y, screen_size.y - margin_y)
	else:
		y_new = randf_range(margin_y, screen_size.y - margin_y)
		
	var spawn_x = get_viewport_transform().affine_inverse().origin.x + screen_size.x + margin_x
	enemy.global_position = Vector2(spawn_x, y_new)
	enemy.add_to_group("kamikaze")

func spawn_bomb():
	if bomb_scene == null: return
	
	var bomb = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	
	var screen_size = get_viewport_rect().size
	var camera_x = get_viewport_transform().affine_inverse().origin.x
	var player = get_tree().get_first_node_in_group("player")
	
	var x_new = 0.0
	var front_gap = 150.0
	var found_pos = false
	var attempts = 0
	
	while !found_pos and attempts < 15:
		x_new = randf_range(camera_x + margin_x_bomb, camera_x + screen_size.x - margin_x_bomb)
		
		if player:
			if x_new > (player.global_position.x + front_gap):
				found_pos = true
		else:
			found_pos = true
		attempts += 1

	bomb.global_position = Vector2(x_new, -100.0) 
	bomb.z_index = 10
	bomb.add_to_group("bombs")
		
func _on_powerup_spawn():
	if powerup_scene == null: return
		
	var pu = powerup_scene.instantiate()
	get_tree().current_scene.add_child(pu)
	
	var screen_size = get_viewport_rect().size
	var margin_x = 100 
	
	var y_new = randf_range(margin_y, screen_size.y - margin_y)
	var spawn_x = get_viewport_transform().affine_inverse().origin.x + screen_size.x + margin_x
	
	pu.global_position = Vector2(spawn_x, y_new)

func kurangi_skor(jumlah: int):
	score -= jumlah
	if score < 0: score = 0
	
	
func change_background(index):
	if current_bg:
		current_bg.queue_free()
	
	current_bg = backgrounds[index].instantiate()
	bg_container.add_child(current_bg)

func update_background(score):
	var new_state = 0
	if score < 10000:
		new_state = 0
	elif score < 20000:
		new_state = 1
	elif score < 30000:
		new_state = 2
	elif score < 40000:
		new_state = 3
	elif score < 50000:
		new_state = 4
	else:
		new_state = 4
	
	if new_state != bg_state:
		bg_state = new_state
		if new_state != 0:
			$CanvasLayer/Transition/AnimationPlayer.play("transition")
			await get_tree().create_timer(0.45).timeout
		change_background(bg_state)

		
func show_game_over():
	Engine.time_scale = 0.0001
	
	var ui = game_over_scene.instantiate()
	$CanvasLayer.add_child(ui)
