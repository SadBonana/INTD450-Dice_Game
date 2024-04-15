#extends Popup
extends Window

@onready var settings_menu = $"."

# Get video settings refrences
@onready var display_options_button = $settings_tabs/Video/video_margin_container/video_settings/display_options_button
@onready var display_fps_button = $settings_tabs/Video/video_margin_container/video_settings/display_fps_button
@onready var max_fps_value = $settings_tabs/Video/video_margin_container/video_settings/max_fps_box_container/max_fps_value
@onready var max_fps_slider = $settings_tabs/Video/video_margin_container/video_settings/max_fps_box_container/max_fps_slider

# Get audio settings refrences
@onready var master_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/master_volume_slider
@onready var music_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/music_volume_slider
@onready var sfx_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/sfx_volume_slider

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	display_options_button.select(1 if SaveSettings.game_data.fullscreen_on else 0)
	
	GlobalSettings.toggle_fullscreen(SaveSettings.game_data.fullscreen_on)
	
	display_fps_button.button_pressed = SaveSettings.game_data.display_fps
	#GlobalSettings.toggle_fps_display(SaveSettings.game_data.display_fps)
	
	max_fps_slider.value = SaveSettings.game_data.max_fps
	#GlobalSettings.set_max_fps(SaveSettings.game_data.max_fps)
	
	master_volume_slider.value = SaveSettings.game_data.master_vol
	#GlobalSettings.update_master_vol(SaveSettings.game_data.master_vol)
	
	music_volume_slider.value = SaveSettings.game_data.music_vol
	#GlobalSettings.update_music_vol(SaveSettings.game_data.music_vol)
	
	sfx_volume_slider.value = SaveSettings.game_data.sfx_vol
	#GlobalSettings.update_sfx_vol(SaveSettings.game_data.sfx_vol)


func _on_display_options_button_item_selected(index):
	# true means it's fullscreen (index 1 of display options)
	GlobalSettings.toggle_fullscreen(true if index == 1 else false)


func _on_display_fps_button_toggled(toggled_on):
	GlobalSettings.toggle_fps_display(toggled_on)


func _on_max_fps_slider_value_changed(value):
	GlobalSettings.set_max_fps(value)
	# Display the max FPS value
	max_fps_value.text = str(value) if value < max_fps_slider.max_value else "Max"


func _on_master_volume_slider_value_changed(value):
	GlobalSettings.update_master_vol(value)


func _on_music_volume_slider_value_changed(value):
	GlobalSettings.update_music_vol(value)


func _on_sfx_volume_slider_value_changed(value):
	GlobalSettings.update_sfx_vol(value)


func _on_close_requested():
	settings_menu.hide()
