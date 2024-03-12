extends Control

## Global variables
@onready var slots: HFlowContainer = %HFlowContainer
@onready var scroll: ScrollContainer = %ScrollContainer
@onready var dtab: TabContainer = %TabContainer
var is_open = false
var is_side_view_open = false
var scene = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
var side_scene = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")
## If your frame is returning something and you want to
## forward it/use it in the parent scene, use this signal
signal frame_clicked(frame) 

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
			
func _create_tab(tab_object)

## Adds the neccessary slots and Die texture models into our scene
func show_frames(frames : Array,) -> void:
	wipe()
	dtab.set_tab_title(0,"Dice")
	var invframe
	for die in PlayerData.dice_bag:
		invframe = scene.instantiate()
		slots.add_child(invframe)	# Adds scene as a child to slots, the HFlowContainer in Dicebag
		invframe.update(die)		# Adds correct die texture to the scene
		invframe.die_clicked.connect(return_content)	# Emits a 
		invframe.owner = get_tree().get_current_scene()

## When we want to use the info that a frame emitted from its signal
## We may catch and reemit it up 
func return_content(content):
	frame_clicked.emit(content)
	
## This function displays a specific die's sides
func show_sides(die : Die):
	wipe()
	dtab.set_tab_title(0,"Sides")
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

## Clear current dice/sides being shown
func wipe():
	for child in slots.get_children():
		slots.remove_child(child)
		
## 
		

			
