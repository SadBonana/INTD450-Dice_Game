extends Panel

## Assigning variables when Scene is created
@onready var die_visual: TextureRect = $MarginContainer/die_display
@onready var die_type: Label = $Label
@onready var die_ref: Die

## Changes label and inventory die texture accordingly
func update(die: Die):
	die_type.text = die.name
	die_visual.texture = die.texture
	die_visual.visible = true
	die_ref = die
	
func clicked() -> Die:
	return die_ref
