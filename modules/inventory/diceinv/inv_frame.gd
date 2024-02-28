extends Panel

@onready var die_visual: TextureRect = $MarginContainer/die_display
@onready var die_type: Label = $Label

func update(die: Die):
	die_type.text = die.name
	die_visual.texture = die.sprite.texture
	die_visual.visible = true
