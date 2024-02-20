extends Control

@onready var main = $"../../"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
'''func _input(event):
	if (Input.is_action_just_pressed()):
		get_tree().change_scene_to_file("res://UI/Menus/pause_menu.tscn")'''

func _on_resume_button_pressed():
	main.pause_menu_func()


func _on_controls_button_pressed():
	get_tree().change_scene_to_file("res://UI/Menus/controls_menu.tscn")


func _on_settings_button_pressed():
	#var options = load("res://UI/settings_menu.tscn").instance()
	#get_tree().current_scene.add_child(options)
	
	get_tree().change_scene_to_file("res://UI/Menus/settings_menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
