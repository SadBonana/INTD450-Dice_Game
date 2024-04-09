extends BaseElement
class_name Steel

## Constructor
func _init():
	element = ElementType.STEEL
	value = 2
	stack_roll = true
	effect = StatusEffect.EffectType.AUTODEFENSE
	#color = Color.LIGHT_STEEL_BLUE
	color = Color("#9db3bf")
	
## String representation of the element
func _to_string():
	return "Steel"

func info():
	var steel  = "[color=Gray]Steel[/color]"
	return "%s gives the player the current %s stack as defense on their turn." % [steel, steel]
