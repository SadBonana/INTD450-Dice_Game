extends Popup

# Get video settings refrences
@onready var display_options_button = $settings_tabs/Video/video_margin_container/video_settings/display_options_button
@onready var vsync_button = $settings_tabs/Video/video_margin_container/video_settings/vsync_button
@onready var display_fps_button = $settings_tabs/Video/video_margin_container/video_settings/display_fps_button
@onready var max_fps_slider = $settings_tabs/Video/video_margin_container/video_settings/max_fps_box_container/max_fps_slider
@onready var bloom_button = $settings_tabs/Video/video_margin_container/video_settings/bloom_button
@onready var brightness_slider = $settings_tabs/Video/video_margin_container/video_settings/brightness_slider

# Get audio settings refrences
@onready var master_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/master_volume_slider
@onready var music_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/music_volume_slider
@onready var sfx_volume_slider = $settings_tabs/Audio/audio_margin_container/audio_settings/sfx_volume_slider

# Get gameplay settings refrences
@onready var fov_slider = $settings_tabs/Gameplay/gameplay_margin_container/gameplay_settings/fov_box_container/fov_slider
@onready var mouse_sensitivity_slider = $settings_tabs/Gameplay/gameplay_margin_container/gameplay_settings/mouse_sensitivity_box_container/mouse_sensitivity_slider

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_display_options_button_item_selected(index):
	pass # Replace with function body.


func _on_vsync_button_toggled(toggled_on):
	pass # Replace with function body.


func _on_display_fps_button_toggled(toggled_on):
	pass # Replace with function body.


func _on_max_fps_slider_value_changed(value):
	pass # Replace with function body.


func _on_bloom_button_toggled(toggled_on):
	pass # Replace with function body.


func _on_brightness_slider_value_changed(value):
	pass # Replace with function body.


func _on_master_volume_slider_value_changed(value):
	pass # Replace with function body.


func _on_music_volume_slider_value_changed(value):
	pass # Replace with function body.


func _on_sfx_volume_slider_value_changed(value):
	pass # Replace with function body.


func _on_fov_slider_value_changed(value):
	pass # Replace with function body.


func _on_mouse_sensitivity_slider_value_changed(value):
	pass # Replace with function body.
