extends BaseElement
class_name Fire

## Constructor
func _init():
	element = ElementType.FIRE
	value = 2
	
## This is the override for the base function: apply_element_effect()
func apply_element_effect():
	print("applying fire effect")
	
## String representation of the element
func _to_string():
	return "Fire"
