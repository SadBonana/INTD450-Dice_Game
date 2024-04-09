extends Node2D

@export var speed: int = 30
@export var friction: int = 15

var shift_direction: Vector2 = Vector2.ZERO
#var shift_direction: Vector2 = Vector2.ONE
#var shift_direction: Vector2 = Vector2.DOWN
#var shift_direction: Vector2 = Vector2.UP

@onready var label = $Label



# Called when the node enters the scene tree for the first time.
func _ready():
	shift_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += speed * shift_direction * delta
	#print("global position is:", global_position)
	speed = max(speed - friction * delta, 0)
	#print("speed is:", speed)
