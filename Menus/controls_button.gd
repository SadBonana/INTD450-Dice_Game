extends Button

@export_file("*.tscn") var controls_menu_scene_path

#"res://menus/controls_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	get_tree().change_scene_to_file(controls_menu_scene_path)
