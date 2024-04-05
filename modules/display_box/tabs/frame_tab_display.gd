extends TabBar

@onready var tab: TabBar = $"."
@onready var slots = $DisplayScroll/FrameSlots/GridContainer
@onready var scroll: ScrollContainer = %DisplayScroll

@onready var inv_side_visual = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")

## The Tab object reference
var tabobj_ref : Tab
var tabobj_size: int = 0

signal disp_frame_clicked(frame)

func create_tab(_tab: Tab, columns:int):
	self.tabobj_ref = _tab
	tab.name = tabobj_ref.get_tab_title()
	slots.columns = columns
	_show_frames()
	
## Adds the neccessary slots and Die texture models into our scene
func _show_frames() -> void:
	wipe()
	set_tab_title(0, tabobj_ref.get_tab_title())			# Set Title
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


func add_frames(frames) -> void:
	tabobj_ref.frames.append_array(frames)
	update_frames()


func upgrade_frames(frames) -> void:
	#var inv_side = inv_side_visual.instantiate()
	#var frame_visual = tabobj_ref.get_frame_visual().instantiate()
	var frame_size = frames.size()
	
	#print("frames size 1:", tabobj_ref.frames.size())
	#print("tabobj size before:", tabobj_size)
	
	if tabobj_size == 0:
		#frame_visual.get_material().set_shader_parameter("glow_power", 0.0)
		#frame_visual.glow_power = 0.0
		
		new_frames(frames)
		print("equal frames")
		
		tabobj_size += frame_size
		print("tabobj size after:", tabobj_size)
	else:
		#frame_visual.get_material().set_shader_parameter("glow_power", 2.0)
		#inv_side_visual.glow_power = 2.0
		
		'''og die increases to 8'''
		add_frames(frames)
		
		'''var array = []
		for frame in tabobj_ref.get_frames():
			#for i in range(tabobj_ref.get_frames().size() / 2):
			frame_visual.update(frame)
				#array.append(frame)'''
		
		'''for frame in frames:
			#var frame2 = frame.get_frame_visual().instantiate()
			#var frame_visual = tabobj_ref.get_frame_visual().instantiate()
			#frame2.get_material().set_shader_parameter("glow_power", 0.0)
			#inv_side_visual.glow_power = 0.0
			tabobj_ref.frames.append(frame)'''
			
		tabobj_size += frame_size
		tabobj_size = 0
	
	update_frames()


func columns(columns : int):
	slots.columns = columns
	update_frames()


## Clear current frames being shown
func wipe():
	for child in slots.get_children():
		#print("child removed:", child)
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
