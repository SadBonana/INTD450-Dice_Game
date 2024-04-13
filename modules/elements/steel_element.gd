extends BaseElement
class_name Steel

## Constructor
func _init():
	element = ElementType.STEEL
	value = 2
	stack_roll = true
	effect = StatusEffect.EffectType.AUTODEFENSE
	color = Color.LIGHT_STEEL_BLUE
	icon = preload("res://assets/textures/resources/elements/steel.tres")
	
## String representation of the element
func _to_string():
	return "Steel"

func info():
	var steel  = "[color=light_steel_blue]Steel[/color]"
	return "%s gives the player the current %s stack as defense on their turn." % [steel, steel]
