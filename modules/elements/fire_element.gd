extends BaseElement
class_name Fire

## Constructor
func _init():
	element = ElementType.FIRE
	value = 2
	effect = StatusEffect.EffectType.IGNITED
	color = Color.DARK_RED
	icon = preload("res://assets/textures/resources/elements/fire.tres")
	
## String representation of the element
func _to_string():
	return "Fire"
