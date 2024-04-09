class_name Die extends Resource

@export var sides : Array[DieSide]
@export var texture: Texture

# NOTE: shadows some built-in's name property, it may be desireable to use that
# property and/or change this to die_name or something instead.
# mainly meant to distinguish e.g. 2 d10's with different effects. e.g. maybe we
# have a special "Gungnir" or "Excalibur" die or something.
@export var name: String

var num_sides: int:
	get:
		return sides.size()

## returns a die side object
func roll():
	return sides.pick_random()
