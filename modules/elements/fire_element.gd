extends BaseElement
class_name Fire

## Constructor
func _init():
	element = ElementType.FIRE
	value = 2
	effect = StatusEffect.EffectType.IGNITED
	#color = Color.FIREBRICK
	color = Color("#a90909")
	
## String representation of the element
func _to_string():
	return "Fire"
