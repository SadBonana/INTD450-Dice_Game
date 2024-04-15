extends Node

# Init signals
signal fps_displayed(value)


# toggle_value is the value passed in the settings menu
func toggle_fullscreen(toggle_value):
	if toggle_value == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if toggle_value == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	SaveSettings.game_data.fullscreen_on = toggle_value
	SaveSettings.save_data()


# toggle_fps_value is the value passed in the settings menu	
# Emits signal that shows FPS label
func toggle_fps_display(toggle_fps_value):
	# Emit signal, the name is the same as under "init signals" above
	emit_signal("fps_displayed", toggle_fps_value)
	
	SaveSettings.game_data.display_fps = toggle_fps_value
	SaveSettings.save_data()


# max_fps_value is the value passed in the settings menu
func set_max_fps(max_fps_value):
	# The maximum number of frames per second that can be rendered
	# When 500, we don't want to limit FPS -> a value of 0 means no limit
	Engine.max_fps = max_fps_value if max_fps_value < 500 else 0
	
	SaveSettings.game_data.max_fps = Engine.max_fps if max_fps_value < 500 else 500
	SaveSettings.save_data()


# master_volume is the value passed in the settings menu
func update_master_vol(master_volume):
	# Access audio server, then access the master bus volume (index 0) and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(0, master_volume)
	
	SaveSettings.game_data.master_vol = master_volume
	SaveSettings.save_data()


# music_volume is the value passed in the settings menu
func update_music_vol(music_volume):
	# Access audio server, then access the music bus volume (index 1) and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(1, music_volume)
	
	SaveSettings.game_data.music_vol = music_volume
	SaveSettings.save_data()


# sfx_volume is the value passed in the settings menu
func update_sfx_vol(sfx_volume):
	# Access audio server, then access the SFX bus volume (index 2) and change it's volume to the specified amount
	AudioServer.set_bus_volume_db(2, sfx_volume)
	
	SaveSettings.game_data.sfx_vol = sfx_volume
	SaveSettings.save_data()
