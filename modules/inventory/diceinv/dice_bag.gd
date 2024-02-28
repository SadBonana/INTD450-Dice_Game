extends Control

## Global variables
@onready var slots: GridContainer = $GridContainer/Slots
var is_open = false
var scene = preload("res://modules/inventory/diceinv/inv_frame.tscn")

## Initializes our scene
func _ready():
	close()
	add_inv_dice()

## Changes our scene accordingly
## Currently only hides and unhides the Inventory using the i key
func _process(delta):
	if(Input.is_action_just_pressed("i")):
		if is_open:
			close()
		else:
			open()
		

## Adds the neccessary slots and Die texture models into our scene
func add_inv_dice() -> void:
	var invframe
	for die in PlayerData.dice_bag:
		invframe = scene.instantiate()
		slots.add_child(invframe)	# Adds scene as a child to slots, the GridContainer in Dicebag
		invframe.update(die)		# Adds correct die texture to the scene
		invframe.owner = get_tree().get_current_scene()

## Makes scene visible
func open():
	visible = true
	is_open = true

## Makes scene hidden
func close():
	visible = false
	is_open = false
			
