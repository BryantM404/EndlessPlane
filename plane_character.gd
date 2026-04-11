extends CharacterBody2D

const SPEED = 300.0
var health: float = 100.0
const JUMP_VELOCITY = -400.0

@onready var health_bar = get_tree().current_scene.find_child("HealthBar", true, false)

func _ready() -> void:
	if health_bar:
		health_bar.value = health

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_up", "ui_down")
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	velocity.x = 200
	
	$PlaneCharacter.play('fly')
	$PlaneFireCharacter.play('default')

	move_and_slide()
	var screen_size = get_viewport_rect().size
	position.y = clamp(position.y, 0, screen_size.y)
	
func take_damage():
	health -= 10.0 
	
	if health_bar:
		health_bar.value = health
		
	# Efek kedip merah saat tertabrak
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

	# Cek apakah nyawa sudah habis
	if health <= 0:
		die()

func die():
	get_tree().change_scene_to_file("res://game_over_scene.tscn")
