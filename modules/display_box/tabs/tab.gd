extends Resource
## This Class is made to be used with the display box.
## Passing an instance of this class to the display box will
## create a tab and populate it with each frame in frames
## and display each frame using the scene held in frame_visual
class_name Tab

@export var tab_title : StringName
@export var frames : Array
@export var frame_visual : PackedScene

## Constructor
func _init(_title : StringName, 
				_frames : Array,
		 			_frame_visual : PackedScene):
	self.tab_title = _title
	self.frames = _frames
	self.frame_visual = _frame_visual
	
func get_tab_title() -> StringName:
	return self.tab_title
	
func get_frames() -> Array:
	return self.frames
	
func get_frame_visual() -> PackedScene:
	return self.frame_visual
	

