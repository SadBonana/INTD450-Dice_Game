extends Control

## Global variables
@onready var slots: HFlowContainer = %HFlowContainer
@onready var arrow_label = $MarginContainer/ScrollContainer/VBoxContainer/arrow_label
@onready var slots_preview: HFlowContainer = $MarginContainer/ScrollContainer/VBoxContainer/HFlowContainer2

var is_open = false
var is_side_view_open = false
var scene = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
var side_scene = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")
## If your frame is returning something and you want to
## forward it/use it in the parent scene, use this signal
signal frame_clicked(frame) 

var in_upgrade_scene = false
var in_battle_drop_scene = false
var display_bag

## Initializes our scene
func _ready():	
	close()

## Changes our scene accordingly
## Hides and unhides the Inventory using the i key
## Escape key returns side view to dice view or closes dice view
func _process(delta):
	if (in_upgrade_scene == true or in_battle_drop_scene == true):
		# Not sure why the if-statement is needed, but die side screen does not show without it.
		if is_open == false:
			open()
			show_dice()
		
	if(Input.is_action_just_pressed("i")):
		display_bag = PlayerData.dice_bag
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
	for die in display_bag:
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
	
	is_side_view_open = true
	
	var invside
	var invside_preview
	var duplicate_side_value
	var arrow_text = "%5s" % ""
	
	for side in die.sides:
		invside = side_scene.instantiate()
		slots.add_child(invside)
		invside.update(side)
		
		if in_upgrade_scene == true:
			invside_preview = side_scene.instantiate()
			
			duplicate_side_value = side.duplicate()
			duplicate_side_value.value += 1
			
			slots_preview.add_child(invside_preview)
			invside_preview.update(duplicate_side_value)
			
			arrow_text = arrow_text + "↓" + "%5s" % ""
			arrow_label.text = arrow_text
			
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
	
	for child in slots_preview.get_children():
		slots_preview.remove_child(child)
