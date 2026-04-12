extends Node2D

# Called when the node enters the scene tree for the first time.

func _ready():
	$GameoverSound.play()
	$GOButton/HomeButton.pressed.connect(_on_home_button_pressed)
	$GOButton/RetryButton.pressed.connect(_on_retry_button_pressed)

func _on_home_button_pressed():
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://background_opening.tscn")

func _on_retry_button_pressed():
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://root.tscn")
