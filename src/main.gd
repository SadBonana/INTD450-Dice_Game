extends Node2D

#@onready var pause_menu = $pause_menu
#var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	'''if Input.is_action_just_pressed("pause"):
		pause_menu_func()'''
	pass

'''func _input(event):
	if Input.is_action_just_pressed("pause"):
		pause_menu_func()'''

'''func pause_menu_func():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused'''
