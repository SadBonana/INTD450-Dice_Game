extends Button
class_name InvDieFrame

## Assigning variables when Scene is created
@onready var button: Button = $'.'
@onready var die_visual: TextureRect = %die_display
@onready var die_type: Label = %Label
@onready var die_ref: Die
signal frame_clicked(die : Die)

func _ready():
	button.pressed.connect(self._on_button_pressed)

## Changes label and inventory die texture accordingly
func update(die: Die):
	die_type.text = die.name
	die_visual.texture = die.texture
	die_visual.visible = true
	die_ref = die
	
func _on_button_pressed():
	button.grab_focus()
	if(die_ref != null):
		print("I am a " + die_type.text + " with the following sides: ")
		for dieside in die_ref.sides:
			print(dieside.element)
		frame_clicked.emit(die_ref)
	else:
		print("Im just a frame with no information big dog")
