extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Map").visible = false
