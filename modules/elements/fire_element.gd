extends BaseElement
class_name Fire

## Constructor
func _init():
	element = ElementType.FIRE
	value = 2
	stack_roll = false
	effect = StatusEffect.EffectType.IGNITED
	color = Color.DARK_RED
	icon = preload("res://assets/textures/resources/elements/fire.tres")
	
## String representation of the element
func _to_string():
	return "Fire"
	
func info():
	var fire = "[color=red]Fire[/color]"
	var text = "%s causes enemies to roll 1 of their dice and take that number as damage. %s also has a chance to spread to enemies." % [fire, fire]
	return text
