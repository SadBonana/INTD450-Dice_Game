extends Button

@export_file("*.tscn") var map_scene_path

#@onready var start_button = %start_button


# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	get_node("/root/start_menu").visible = false
