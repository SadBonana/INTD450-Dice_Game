extends Button

@onready var settings_menu = $settings_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	settings_menu.popup_centered()
