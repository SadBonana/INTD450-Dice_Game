extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Init signals
signal fps_displayed(value)
signal bloom_toggled(value)
signal brightness_updated(value)
signal fov_updated(value)
signal mouse_sensitivity_updated(value)


# toggle_value is the value passed in the settings menu
func toggle_fullscreen(toggle_value):
	if toggle_value == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if toggle_value == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	#OS.window_fullscreen = toggle
	
	Save.game_data.fullscreen_on = toggle_value
	Save.save_data()


# toggle_value is the value passed in the settings menu
func toggle_vsync(toggle_value):
	if toggle_value == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	if toggle_value == false:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
	#OS.vsync_enabled = toggle_value
	
	Save.game_data.vsync_on = toggle_value
	Save.save_data()


# toggle_fps_value is the value passed in the settings menu	
# Emits signal that shows FPS label
func toggle_fps_display(toggle_fps_value):
	# Emit signal, the name is the same as under "init signals" above
	emit_signal("fps_displayed", toggle_fps_value)
	
	Save.game_data.display_fps = toggle_fps_value
	Save.save_data()
	
# max_fps_value is the value passed in the settings menu
func set_max_fps(max_fps_value):
	# The maximum number of frames per second that can be rendered
	# When 500, we don't want to limit FPS -> a value of 0 means no limit
	Engine.max_fps = max_fps_value if max_fps_value < 500 else 0
	
	Save.game_data.max_fps = Engine.max_fps if value < 500 else 500
	Save.save_data()
	
# bloom_value is the value passed in the settings menu
func toggle_bloom(bloom_value):
	emit_signal("bloom_toggled", bloom_value)
	
	Save.game_data.bloom_on = bloom_value
	Save.save_data()
	
# brightness_value is the value passed in the settings menu
func update_brightness(brightness_value):
	emit_signal("brightness_updated", brightness_value)
	
	Save.game_data.brightness = value
	Save.save_data()
	
# master_volume is the value passed in the settings menu
func update_master_vol(master_volume):
	# Access audio server, then access the master bus volume (index 0) and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(0, master_volume)
	
	Save.game_data.master_vol = master_volume
	Save.save_data()


# audio_index is accosicated with which slider is being changed:
# 	index 0 : master volume
# 	index 1 : music volume
# 	index 3 : SFX volume
# volume is the value passed in the settings menu
'''func update_vol(audio_index, volume):
	# Access audio server, then access the bus associated with the audio_index and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(audio_index, volume)'''


# music_volume is the value passed in the settings menu
func update_music_vol(music_volume):
	# Access audio server, then access the music bus volume (index 1) and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(1, music_volume)
	
# sfx_volume is the value passed in the settings menu
func update_sfx_vol(sfx_volume):
	# Access audio server, then access the SFX bus volume (index 2) and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(2, sfx_volume)
	
# fov_value is the value passed in the settings menu
# FOV is property of camera, so no easy access to it, so need to emit signal
func update_fov(fov_value):
	emit_signal("fov_updated", fov_value)
	
	Save.game_data.fov = fov_value
	Save.save_data()
	
# mouse_value is the value passed in the settings menu
# Mouse sensitivity will affect the player, not mouse globally	
func update_mouse_sensitivity(mouse_value):
	emit_signal("mouse_sensitivity_updated", mouse_value)
	
	Save.game_data.mouse_sens = mouse_value
	Save.save_data()
