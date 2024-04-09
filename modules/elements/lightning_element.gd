extends BaseElement
class_name Lightning

## Constructor
func _init():
	element = ElementType.LIGHTNING
	value = 2
	stack_roll = false
	effect = StatusEffect.EffectType.PARALYSIS
	color = Color.YELLOW
	
## String representation of the element
func _to_string():
	return "Lightning"

func info():
	var lightning = "[color=yellow]Lightning[/color]"
	var text = "%s renders a die unusable by the target. Each stack increases the amount by 1." % [lightning]
	return text
