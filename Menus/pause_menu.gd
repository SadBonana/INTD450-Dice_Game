extends Control

#@onready var settings_menu = $settings_menu

var _is_paused:bool = false:
	set = set_paused

var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()
	#visible = false
	#set_paused(false)
	#_is_paused = false
	
	#visible = false
	#is_paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused
		
		'''is_paused = !is_paused
		print("is paused is:", is_paused)
		get_tree().paused = is_paused
		visible = is_paused
		get_viewport().set_input_as_handled()'''
	
	'''if event.is_action_pressed("close"):
		#_is_paused = !_is_paused
		is_paused = false
		print("is paused is:", is_paused)
		get_tree().paused = false
		visible = false'''

func set_paused(value:bool) -> void:
	_is_paused = value
	#is_paused = value
	
	get_tree().paused = _is_paused
	#get_tree().paused = value
	#get_tree().set_pause(_is_paused)
	
	visible = _is_paused
	#visible = value


func _on_resume_button_pressed():
	_is_paused = false
	#is_paused = false
	#get_tree().paused = false
	#visible = false



func _input(event: InputEvent):
	'''if (Input.is_action_just_pressed()):
		get_tree().change_scene_to_file("res://UI/Menus/pause_menu.tscn")'''
	'''if InputEvent.is_action_pressed("pause"):
		_is_paused = !_is_paused'''
	
	'''if event.is_action_pressed("pause"):
		is_paused = !is_paused
		print("is paused is:", is_paused)
		get_tree().paused = is_paused
		visible = is_paused'''
		
	pass


'''func _on_controls_button_pressed():
	get_tree().change_scene_to_file("res://Menus/controls_menu.tscn")


func _on_settings_button_pressed():
	settings_menu.popup_centered()

func _on_quit_button_pressed():
	get_tree().quit()'''
