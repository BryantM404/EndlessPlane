extends CharacterBody2D

@export var speed : float = 600.0
@export var turn_speed : float = 4.0
@export var chase_distance : float = 200.0 

var player : Node2D
var direction : Vector2 = Vector2.LEFT
var exploded := false

@onready var anim = $Area2D/AnimatedSprite2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim.play("default")
	
func _physics_process(delta):
	if exploded:
		return

	if player:
		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player > chase_distance: 
			var offset = Vector2(randf_range(-50,50), randf_range(-50,50))
			var target_dir = ((player.global_position + offset) - global_position).normalized()
			direction = direction.lerp(target_dir, turn_speed * delta)
		else:
			direction = direction
	if position.x < -100:
		queue_free()

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
		explode()
		
		

func explode():
	if exploded:
		return

	exploded = true

	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	set_physics_process(false)
	set_process(false)

	$CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/CollisionShape2D.call_deferred("set_disabled", true)

	anim.play("explosion")

	await anim.animation_finished
	queue_free()
