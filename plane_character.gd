extends CharacterBody2D

const SPEED = 300.0
var health: float = 100.0
const JUMP_VELOCITY = -400.0
var max_health: float = 100.0	

var is_shield_active: bool = false
var shield_timer = Timer

@onready var health_bar = get_tree().current_scene.find_child("HealthBar", true, false)

func _ready() -> void:
	if health_bar:
		health_bar.value = health
		
	shield_timer = Timer.new()
	shield_timer.one_shot = true
	shield_timer.wait_time = 10.0
	shield_timer.timeout.connect(_on_shield_timeout)
	add_child(shield_timer)

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

func apply_powerup(type):
	if type == 0: # SHIELD (Efek pelindung)
		is_shield_active = true
		shield_timer.start()
		# Ubah warna pesawat jadi agak biru sebagai tanda shield aktif
		modulate = Color(0.5, 0.8, 1.0) 
		print("SHIELD AKTIF!")
		
	elif type == 1: # SCORE MULTIPLIER (x2)
		# Panggil fungsi di script Root (node paling atas)
		var root_node = get_tree().current_scene
		if root_node.has_method("activate_score_multiplier"):
			root_node.activate_score_multiplier()
		print("SCORE X2 AKTIF!")
		
	elif type == 2: # HEAL (+15% Nyawa)
		health += (max_health * 0.15)
		if health > max_health:
			health = max_health # Pastikan nyawa nggak tembus 100
			
		# Update UI Bar Darah
		if health_bar:
			health_bar.value = health
		
		# Efek kedip hijau saat dapat nyawa
		modulate = Color.GREEN
		await get_tree().create_timer(0.2).timeout
		if is_shield_active:
			modulate = Color(0.5, 0.8, 1.0) # Balik ke warna shield kalau shield aktif
		else:
			modulate = Color.WHITE
		print("NYAWA NAMBAH!")
		
func _on_shield_timeout():
	is_shield_active = false
	modulate = Color.WHITE # Kembalikan ke warna normal
	print("DURASI SHIELD HABIS!")
	
func take_damage(damage_value):
	if is_shield_active:
		# SHIELD PECAH, NYAWA AMAN
		is_shield_active = false
		shield_timer.stop()
		
		# Efek kedip putih/biru tanda shield hancur
		modulate = Color.AQUA
		await get_tree().create_timer(0.2).timeout
		modulate = Color.WHITE
		print("SHIELD PECAH! Nyawa aman.")
		
	else:
		# KENA DAMAGE NORMAL KARENA GAK ADA SHIELD
		health -= damage_value
		
		if health_bar:
			health_bar.value = health
			
		# Efek kedip merah saat tertabrak
		modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE

		# Cek apakah nyawa sudah habis
		if health <= 0:
			die()
	#health -= 10.0 
	#
	#if health_bar:
		#health_bar.value = health
		#
	## Efek kedip merah saat tertabrak
	#modulate = Color.RED
	#await get_tree().create_timer(0.1).timeout
	#modulate = Color.WHITE
#
	## Cek apakah nyawa sudah habis
	#if health <= 0:
		#die()

func die():
	get_tree().change_scene_to_file("res://game_over_scene.tscn")
