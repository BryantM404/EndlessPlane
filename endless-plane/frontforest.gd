extends Sprite2D

@export var speed := 200
@export var reset_x := 1000  # posisi kanan layar
@export var limit_x := -200  # batas kiri (keluar layar)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < limit_x:
		position.x = reset_x
