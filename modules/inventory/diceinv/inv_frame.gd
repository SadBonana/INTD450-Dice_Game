extends Panel

## Assigning variables when Scene is created
@onready var die_visual: TextureRect = $MarginContainer/die_display
@onready var die_type: Label = $Label

## Changes label and inventory die texture accordingly
func update(die: Die):
	die_type.text = die.name
	die_visual.texture = die.sprite.texture
	die_visual.visible = true
