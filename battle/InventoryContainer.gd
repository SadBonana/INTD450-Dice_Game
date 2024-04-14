extends MarginContainer

@onready var inventory = %Inventory
@onready var close_button = %Close

func _ready():
	close_button.pressed.connect(toggle)
	
func toggle():
	inventory.toggle()
	get_tree().paused = inventory.is_open
	self.visible = inventory.is_open
