extends Area2D

enum PowerType {SHIELD, MULTIPLIER, HEAL, AMMO}
var my_type = PowerType
var SPEED = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var types = [PowerType.SHIELD, PowerType.MULTIPLIER, PowerType.HEAL, PowerType.AMMO]
	my_type = types.pick_random()
	if my_type == PowerType.SHIELD:
		modulate = Color(0, 0, 1) # shield
	elif my_type == PowerType.MULTIPLIER:
		modulate = Color(1, 1, 0) # score x2
	elif my_type == PowerType.HEAL:
		modulate = Color(0, 1, 0) # nyawa +15
	elif my_type == PowerType.AMMO:
		modulate = Color(1, 0, 0) # ammo
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= SPEED * delta
	
	if position.x < -100:
		queue_free()
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		body.apply_powerup(my_type) 
		queue_free() 
	pass
