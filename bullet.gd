extends Area2D
# AI Generated Mulai
@export var speed: float = 800.0
@export var lifetime: float = 2.0 


func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position.x += speed * delta
# AI Generated Akhir

# AI Assisted Mulai
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.name == "Bullet":
		return
		
	if area.is_in_group("bombs"):
		handle_hit(area)
		return
		
	var parent = area.get_parent()
	if parent and parent.is_in_group("kamikaze"):
		handle_hit(parent)
		return

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return
		
	if body.is_in_group("kamikaze"):
		handle_hit(body)

# AI Assisted Akhir

# AI Generated Mulai
func handle_hit(victim):
	if is_queued_for_deletion():
		return

	if victim.has_method("explode"):
		victim.explode()
	else:
		victim.queue_free()
	queue_free()
#AI Generated Akhir
