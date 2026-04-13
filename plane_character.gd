extends CharacterBody2D

@export var bullet_scene : PackedScene

const SPEED = 300.0
var health: float = 100.0
var max_health: float = 100.0	

var ammo: int = 30          
var max_ammo: int = 30

var is_shield_active: bool = false
var shield_timer: Timer 

@onready var ammo_label = get_tree().current_scene.find_child("AmmoLabel", true, false)
@onready var health_bar = get_tree().current_scene.find_child("HealthBar", true, false)

signal show_powerup_text(text)

func _ready() -> void:
	if health_bar:
		health_bar.value = health
	
	update_ammo_ui()
	
	shield_timer = Timer.new()
	shield_timer.one_shot = true
	shield_timer.wait_time = 10.0
	shield_timer.timeout.connect(_on_shield_timeout)
	add_child(shield_timer)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		shoot()

	var direction := Input.get_axis("ui_up", "ui_down")
	velocity.y = direction * SPEED if direction else move_toward(velocity.y, 0, SPEED)
	
	velocity.x = 200 
	
	$PlaneCharacter.play('fly')
	$PlaneFireCharacter.play('default')

	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	position.y = clamp(position.y, 0, screen_size.y)

func shoot():
	if ammo > 0 and bullet_scene:
		$ShootSound.play()
		var bullet = bullet_scene.instantiate()
	
		if has_node("Muzzle"):
			bullet.global_position = $Muzzle.global_position
		else:
			bullet.global_position = global_position + Vector2(80, 0)
			
		get_tree().current_scene.add_child(bullet)
		
		ammo -= 1
		update_ammo_ui()
	else:
		print("Peluru Habis!")

func update_ammo_ui():
	if ammo_label:
		ammo_label.text = "Ammo: " + str(ammo) + " / " + str(max_ammo)
		
		var warna_baru: Color
		
		if ammo > 15:
			warna_baru = Color.GREEN  
		elif ammo >= 7:
			warna_baru = Color.ORANGE 
		else:
			warna_baru = Color.RED    
		
		if ammo_label.label_settings:
			ammo_label.label_settings.font_color = warna_baru
		else:
			ammo_label.add_theme_color_override("font_color", warna_baru)
		
func take_damage(damage_value):
	$HitSound.play()
	if is_shield_active:
		is_shield_active = false
		shield_timer.stop()
		_flash_effect(Color.AQUA)
	else:
		health -= damage_value
		if health_bar:
			health_bar.value = health
		_flash_effect(Color.RED)
		if health <= 0:
			die()

func _flash_effect(flash_color: Color):
	modulate = flash_color
	get_tree().create_timer(0.1).timeout.connect(func(): modulate = Color.WHITE)

func apply_powerup(type):
	$PowerupSound.play()
	if type == 0: # SHIELD
		is_shield_active = true
		shield_timer.start()
		modulate = Color(0.5, 0.8, 1.0)
		emit_signal("show_powerup_text", "SHIELD ACTIVE!")
	elif type == 1: # SCORE
		var root_node = get_tree().current_scene
		if root_node.has_method("activate_score_multiplier"):
			root_node.activate_score_multiplier()
		emit_signal("show_powerup_text", "DOUBLE SCORE!")
	elif type == 2: # HEAL
		health = min(health + (max_health * 0.15), max_health)
		if health_bar: health_bar.value = health
		_flash_effect(Color.GREEN)
		emit_signal("show_powerup_text", "HEAL +15%")
	elif type == 3: # AMMO
		ammo = min(ammo + 20, max_ammo) 
		update_ammo_ui()
		_flash_effect(Color.RED)
		emit_signal("show_powerup_text", "AMMO +20") 

func _on_shield_timeout():
	is_shield_active = false
	modulate = Color.WHITE

func die():
	var game = get_tree().get_first_node_in_group("game")
	game.show_game_over()
