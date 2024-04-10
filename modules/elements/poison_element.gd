extends BaseElement
class_name Poison

## Constructor
func _init():
	element = ElementType.POISON
	value = 2
	effect = StatusEffect.EffectType.POISONED
	color = Color.WEB_GREEN
	icon = preload("res://assets/textures/resources/elements/poison.tres")
	
## String representation of the element
func _to_string():
	return "Poison"
	
func info():
	var poison  = "[color=web_green]Poison[/color]"
	var text = "%s causes enemies to take the current %s stack number as damage on their turn." % [poison, poison]
	return text
