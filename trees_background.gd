extends ParallaxBackground

@export var speed := 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for layer in get_children():
		if layer is Parallax2D:
			layer.scroll_offset.x -= speed * delta
	pass
