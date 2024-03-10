extends BaseElement
class_name Lightning

## Constructor
func _init():
	element = ElementType.LIGHTNING
	value = 2
	effect = StatusEffect.EffectType.PARALYSIS
	color = Color.REBECCA_PURPLE
	
## String representation of the element
func _to_string():
	return "Lightning"
