extends BaseElement
class_name Basic

## Constructor
func _init():
	element = ElementType.NONE
	value = 2
	effect = StatusEffect.EffectType.BASEEFFECT
	
## String representation of the element
func _to_string():
	return "Basic"
