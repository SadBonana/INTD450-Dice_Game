extends Label

# Called when the node enters the scene tree for the first time.
# warning-ignore:return_value_discarded
func _ready():
	# Call _on_fps_displayed function when signal is emitted
	GlobalSettings.fps_displayed.connect(_on_fps_displayed)
	visible = SaveSettings.game_data.display_fps


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	# Updates the FPS live
	# To get FPS, access the engine and get the frames per second
	text = " FPS: %s " % [Engine.get_frames_per_second()]


func _on_fps_displayed(value):
	# value will be true ot false, so visible will be true or false
	# Hiding and showing FPS label
	visible = value
