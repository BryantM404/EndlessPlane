extends Node2D

@export var game_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.time_scale = 1
	$OpeningButton/StartButton.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(game_scene)
