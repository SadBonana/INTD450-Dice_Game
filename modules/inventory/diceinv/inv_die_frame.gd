extends Button
class_name InvDieFrame

## Assigning variables when Scene is created
@onready var button: Button = $'.'
@onready var die_visual: TextureRect = %die_display
@onready var die_type: Label = %Label
@onready var die_ref: Die
signal die_clicked(die : Die)

func _ready():
	button.pressed.connect(self._on_button_pressed)

## Changes label and inventory die texture accordingly
func update(die: Die):
	die_type.text = die.name
	die_visual.texture = die.texture
	die_visual.visible = true
	die_ref = die
	
func _on_button_pressed():
	print("I am a " + die_type.text + " with the following sides: ")
	for dieside in die_ref.sides:
		print(dieside.element)
	die_clicked.emit(die_ref)
