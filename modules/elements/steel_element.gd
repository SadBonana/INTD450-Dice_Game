extends BaseElement
class_name Steel

## Constructor
func _init():
	element = ElementType.STEEL
	value = 2
	effect = StatusEffect.EffectType.AUTODEFENSE
	
## String representation of the element
func _to_string():
	return "Steel"
