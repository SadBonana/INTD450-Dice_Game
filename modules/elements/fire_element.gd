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
	var text = "%s does 2 damage per stack. %s also has a chance to reignite and add stacks or to spread to enemies." % [fire, fire]
	return text
