extends Button

@onready var settings_menu = $settings_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	SoundManager.select_2.play()
	#settings_menu.popup_centered()
	settings_menu.show()
