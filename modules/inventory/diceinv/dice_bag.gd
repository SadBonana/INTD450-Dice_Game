extends Control

## Global variables
@onready var slots: HFlowContainer = $Scroll/Frames
@onready var scroll: ScrollContainer = $Scroll
var is_open = false
var is_side_view_open = false
var scene = preload("res://modules/inventory/diceinv/inv_frame.tscn")
var side_scene = preload("res://modules/dice/inv_die_side.tscn")
signal die_clicked(die : Die)

## Initializes our scene
func _ready():
	close()

## Changes our scene accordingly
## Hides and unhides the Inventory using the i key
## Escape key returns side view to dice view or closes dice view
func _process(delta):
	if(Input.is_action_just_pressed("i")):
		if is_open:
			close()
		else:
			open()
			show_dice()
			
	if(Input.is_action_just_pressed("close")):
		if is_side_view_open:
			is_side_view_open = false
			show_dice()
		elif is_open:
			close()

## Adds the neccessary slots and Die texture models into our scene
func show_dice() -> void:
	wipe()
	var invframe
	for die in PlayerData.dice_bag:
		invframe = scene.instantiate()
		slots.add_child(invframe)	# Adds scene as a child to slots, the HFlowContainer in Dicebag
		invframe.update(die)		# Adds correct die texture to the scene
		invframe.die_clicked.connect(die_return)
		invframe.owner = get_tree().get_current_scene()

## When die is pressed emit signal with die
func die_return(die : Die):
	die_clicked.emit(die)
	
## This function displays a specific die's sides
func show_sides(die : Die):
	wipe()
	is_side_view_open = true
	var invside
	for side in die.sides:
		invside = side_scene.instantiate()
		slots.add_child(invside)
		invside.update(side)
		invside.owner = get_tree().get_current_scene()
		
	
## Makes scene visible
func open():
	visible = true
	is_open = true

## Makes scene hidden
func close():
	visible = false
	is_open = false
	
func wipe():
	for child in slots.get_children():
		slots.remove_child(child)
		

			
