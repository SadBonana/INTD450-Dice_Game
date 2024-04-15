extends BaseElement
class_name Lightning

## Constructor
func _init():
	element = ElementType.LIGHTNING
	value = 2
	stack_roll = false
	effect = StatusEffect.EffectType.PARALYSIS
	color = Color("#8c3cee") # purple color from art palette #Color.REBECCA_PURPLE
	icon = preload("res://assets/textures/resources/elements/lightning.tres")
	
## String representation of the element
func _to_string():
	return "Lightning"

func info():
	var lightning = "[color=rebecca_purple]Lightning[/color]"
	var text = "%s decreases the roll of the target's highest rolled die by 2 per stack." % [lightning]
	return text
