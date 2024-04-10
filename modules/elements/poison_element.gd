extends BaseElement
class_name Poison

## Constructor
func _init():
	element = ElementType.POISON
	value = 2
	effect = StatusEffect.EffectType.POISONED
	color = Color.WEB_PURPLE
	
## String representation of the element
func _to_string():
	return "Poison"
