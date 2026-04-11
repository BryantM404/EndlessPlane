extends Area2D
var speed = 100.0 
var is_exploded = false

@onready var anim = $AnimatedSprite2D

func _ready():
	if anim.sprite_frames.has_animation("default"):
		anim.play("default")

func _process(delta):
	if not is_exploded:
		position.y += speed * delta
	
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if not is_exploded:
			if body.has_method("take_damage"):
				body.take_damage()
			
			explode()

func explode():
	is_exploded = true
	$CollisionShape2D.call_deferred("set_disabled", true)
	
	if anim.sprite_frames.has_animation("explosion"):
		anim.play("explosion")
		await anim.animation_finished
	queue_free()
func set_speed(new_speed):
	speed = new_speed
