extends Area2D

enum PowerType {SHIELD, MULTIPLIER, HEAL}
var my_type = PowerType
var SPEED = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var types = [PowerType.SHIELD, PowerType.MULTIPLIER, PowerType.HEAL]
	my_type = types.pick_random()
	
	# (Opsional) Ubah warna agar kamu tahu ini power-up apa
	if my_type == PowerType.SHIELD:
		modulate = Color(0, 0, 1) # Biru untuk Shield
	elif my_type == PowerType.MULTIPLIER:
		modulate = Color(1, 1, 0) # Kuning untuk Score x2
	elif my_type == PowerType.HEAL:
		modulate = Color(0, 1, 0) # Hijau untuk Nyawa
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= SPEED * delta
	
	if position.x < -100:
		queue_free()
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		body.apply_powerup(my_type) # Beri tahu player power-up apa yang didapat
		queue_free() # Hapus power-up dari layar
	pass # Replace with function body.
