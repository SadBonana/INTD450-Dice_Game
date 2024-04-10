extends TabBar

@onready var tab: TabBar = $"."
@onready var slots: HFlowContainer = %FrameSlots
@onready var scroll: ScrollContainer = %DisplayScroll

## The Tab object reference
var tabobj_ref : Tab

signal disp_frame_clicked(frame)

func create_tab(_tab: Tab):
	self.tabobj_ref = _tab
	tab.name = tabobj_ref.get_tab_title()
	_show_frames()
	
## Adds the neccessary slots and Die texture models into our scene
func _show_frames() -> void:
	wipe()
	tab.name = tabobj_ref.get_tab_title()					# Set Title
	var frame_visual = tabobj_ref.get_frame_visual().instantiate()	# Get frame visual
	
	check_validity(frame_visual)
	
	for frame in tabobj_ref.get_frames():
		slots.add_child(frame_visual)	# Adds scene as a child to slots, the HFlowContainer in Dicebag
		frame_visual.update(frame)		# Adds frame information to scene
		frame_visual.frame_clicked.connect(return_content)
		frame_visual.owner = get_tree().get_current_scene()
		frame_visual = tabobj_ref.get_frame_visual().instantiate()
		
func update_frames() -> void:
	_show_frames()

func new_frames(frames) -> void:
	tabobj_ref.frames = frames
	update_frames()

## Clear current frames being shown
func wipe():
	for child in slots.get_children():
		slots.remove_child(child)
		
## When we want to use the info that a frame emitted from its signal
## We may catch and reemit it up 
func return_content(content):
	disp_frame_clicked.emit(content)

## Checks the validity of the passed frame. Frame must have these functions
## to be valid, even if they dont do anything
func check_validity(frame_visual):
	## We need this function in order to update the information in the
	## frame_visual to match what is in the frame.
	if(not frame_visual.has_method("update")):
		assert(false,
			"UNIMPLEMENTED METHOD: update()\n
		 		PLEASE IMPLEMENT THIS METHOD TO YOUR FRAME VISUAL")
				
	## We need this signal in order to notify the parent scene that
	## a frame has been clicked
	elif(not frame_visual.has_signal("frame_clicked")):
		assert(false,
			"UNIMPLEMENTED SIGNAL: frame_clicked\n
		 		PLEASE IMPLEMENT THIS SIGNAL TO YOUR FRAME VISUAL")
