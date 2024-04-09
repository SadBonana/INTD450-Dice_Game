extends BaseElement
class_name Basic

## Constructor
func _init():
	element = ElementType.NONE
	value = 2
	stack_roll = false
	effect = StatusEffect.EffectType.BASEEFFECT
	color = Color.BEIGE
	
## String representation of the element
func _to_string():
	return "Basic"

func info():
	return "Attack/Defend with the number rolled."
