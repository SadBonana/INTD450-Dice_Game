extends Control

@onready var slots: GridContainer = $GridContainer/Slots
var is_open = false
var scene = preload("res://modules/inventory/diceinv/inv_frame.tscn")
var array : Array

func _ready():
	close()
	var invframe
	var child
	for die in PlayerData.dice_bag:
		invframe = scene.instantiate()
		slots.add_child(invframe)
		invframe.update(die)
		invframe.owner = get_tree().get_current_scene()
	array = slots.get_children()
	
func _process(delta):
	if(Input.is_action_just_pressed("i")):
		if is_open:
			close()
		else:
			open()
		

func open():
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false
			
