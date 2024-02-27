extends Popup

# Get video settings refrences
@onready var display_options_button = $settings_tabs/Video/video_margin_container/video_settings/display_options_button
@onready var vsync_button = $settings_tabs/Video/video_margin_container/video_settings/vsync_button
@onready var display_fps_button = $settings_tabs/Video/video_margin_container/video_settings/display_fps_button
@onready var max_fps_value = $settings_tabs/Video/video_margin_container/video_settings/max_fps_box_container/max_fps_value
@onready var max_fps_slider = $settings_tabs/Video/video_margin_container/video_settings/max_fps_box_container/max_fps_slider
@onready var bloom_button = $settings_tabs/Video/video_margin_container/video_settings/bloom_button
@onready var brightness_slider = $settings_tabs/Video/video_margin_container/video_settings/brightness_slider

# Get audio settings refrences
@onready var master_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/master_volume_slider
@onready var music_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/music_volume_slider
@onready var sfx_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/sfx_volume_slider

# Get gameplay settings refrences
@onready var fov_value = $settings_tabs/Gameplay/gameplay_margin_container/gameplay_settings/fov_box_container/fov_value
@onready var fov_slider = $settings_tabs/Gameplay/gameplay_margin_container/gameplay_settings/fov_box_container/fov_slider
@onready var mouse_sensitivity_value = $settings_tabs/Gameplay/gameplay_margin_container/gameplay_settings/mouse_sensitivity_box_container/mouse_sensitivity_value
@onready var mouse_sensitivity_slider = $settings_tabs/Gameplay/gameplay_margin_container/gameplay_settings/mouse_sensitivity_box_container/mouse_sensitivity_slider

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	'''display_options_button.select(1 if SaveSettings.game_data.fullscreen_on else 0)
	GlobalSettings.toggle_fullscreen(SaveSettings.game_data.fullscreen_on)
	vsync_button.pressed = SaveSettings.game_data.vsync_on
	display_fps_button.pressed = SaveSettings.game_data.display_fps
	max_fps_slider.value = SaveSettings.game_data.max_fps
	bloom_button.pressed = SaveSettings.game_data.bloom_on
	brightness_slider.value = SaveSettings.game_data.brightness
	
	master_volume_slider.value = SaveSettings.game_data.master_vol
	music_volume_slider.value = SaveSettings.game_data.music_vol
	sfx_volume_slider.value = SaveSettings.game_data.sfx_vol
	
	fov_slider.value = SaveSettings.game_data.fov
	mouse_sensitivity_slider.value = SaveSettings.game_data.mouse_sens'''


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_display_options_button_item_selected(index):
	# true means it's fullscreen (index 1 of display options)
	GlobalSettings.toggle_fullscreen(true if index == 1 else false)


func _on_vsync_button_toggled(toggled_on):
	# toggled_on will be true or false, and you get it from signal
	GlobalSettings.toggle_vsync(toggled_on)


func _on_display_fps_button_toggled(toggled_on):
	GlobalSettings.toggle_fps_display(toggled_on)


func _on_max_fps_slider_value_changed(value):
	GlobalSettings.set_max_fps(value)
	# Display the max FPS value
	max_fps_value.text = str(value) if value < max_fps_slider.max_value else "max"


func _on_bloom_button_toggled(toggled_on):
	GlobalSettings.toggle_bloom(toggled_on)


func _on_brightness_slider_value_changed(value):
	GlobalSettings.update_brightness(value)


func _on_master_volume_slider_value_changed(value):
	GlobalSettings.update_master_vol(value)


func _on_music_volume_slider_value_changed(value):
	GlobalSettings.update_music_vol(value)


func _on_sfx_volume_slider_value_changed(value):
	GlobalSettings.update_sfx_vol(value)


func _on_fov_slider_value_changed(value):
	GlobalSettings.update_fov(value)
	fov_value.text = str(value)


func _on_mouse_sensitivity_slider_value_changed(value):
	GlobalSettings.update_mouse_sensitivity(value)
	mouse_sensitivity_value.text = str(value)
