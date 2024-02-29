extends Control

@onready var settings_menu = $settings_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	# Allows player to control buttons using keyboard
	$VBoxContainer/start_button.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	# Change to map scene once done
	get_tree().change_scene_to_file("res://Battle/battle.tscn")

func _on_controls_button_pressed():
	get_tree().change_scene_to_file("res://Menus/controls_menu.tscn")

func _on_settings_button_pressed():
	settings_menu.popup_centered()

func _on_quit_button_pressed():
	get_tree().quit()
