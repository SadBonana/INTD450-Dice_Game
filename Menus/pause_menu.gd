extends Control

#@onready var settings_menu = $settings_menu

var _is_paused:bool = false:
	set = set_paused


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused

func set_paused(value:bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused
	
func _input(event):
	'''if (Input.is_action_just_pressed()):
		get_tree().change_scene_to_file("res://UI/Menus/pause_menu.tscn")'''
	'''if InputEvent.is_action_pressed("pause"):
		_is_paused = !_is_paused'''
	pass


func _on_resume_button_pressed():
	_is_paused = false

'''func _on_controls_button_pressed():
	get_tree().change_scene_to_file("res://Menus/controls_menu.tscn")


func _on_settings_button_pressed():
	settings_menu.popup_centered()

func _on_quit_button_pressed():
	get_tree().quit()'''
