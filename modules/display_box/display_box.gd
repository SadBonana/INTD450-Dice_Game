extends TabContainer

## Global Variables
@onready var frame_tab_display = preload("res://modules/display_box/tabs/frame_tab_display.tscn")

## Modifiable start variables
@export var is_open : bool = false 			# set to true if you want it open when scene begins
@export var open_action : String = ""		# action to open display box
@export var close_action : String = "" 		# action to close display box
var tabs : Array[Tab]						# all the tabs we want the Display box to display

## If your frame is returning something and you want to
## forward it/use it in the parent scene, use this signal
signal frame_clicked(frame) 

## Initializes our scene
func _ready():
	if is_open:
		open()
	else:
		close()

## Changes our scene accordingly
## Hides and unhides the Inventory using the i key
## Escape key returns side view to dice view or closes dice view
func _input(event):	
	if(open_action): # if string is left empty this is false
		if(event.is_action_just_pressed(open_action)):
			open()
			
	if(close_action): # if string is left empty this is false
		if(event.is_action_just_pressed(open_action)):
			close()
			
## Use this function when you want to add a new tab to your Display box
func add_tab_child(tab_object :  Tab):
	var tab_scene = frame_tab_display.instantiate()
	tab_scene.create_tab(tab_object)
	add_child(tab_scene)
	tabs.append(tab_object)

## When we want to use the info that a frame emitted from its signal
## We may catch and reemit it up 
func return_content(content):
	frame_clicked.emit(content)		
	
## Makes scene visible
func open():
	visible = true
	is_open = true

## Makes scene hidden
func close():
	visible = false
	is_open = false
		

			
