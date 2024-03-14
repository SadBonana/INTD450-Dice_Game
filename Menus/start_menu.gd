extends Control

@export_file("*.tscn") var map_scene_path
@export_file("*.tscn") var controls_menu_scene_path

@onready var settings_menu = %settings_menu
@onready var start_button = %start_button


# Called when the node enters the scene tree for the first time.
func _ready():
	# Allows player to control buttons using keyboard
	start_button.grab_focus()


func _on_start_button_pressed():
	# Change to map scene once done
	visible = false
	#get_tree().change_scene_to_file(map_scene_path)


func _on_controls_button_pressed():
	get_tree().change_scene_to_file(controls_menu_scene_path)


func _on_settings_button_pressed():
	settings_menu.popup_centered()


func _on_quit_button_pressed():
	get_tree().quit()
