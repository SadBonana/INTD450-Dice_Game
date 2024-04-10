extends Resource
## The base class for all element classes
##
## All element classes must inherit this one
class_name BaseElement

## All possible element types
enum ElementType {
	NONE,
	POISON,
	LIGHTNING,
	STEEL,
	FIRE,
}

## The element's type
var element : ElementType

## The element's inherent value
var value : int

## The element's icon
var icon : Texture2D

## The color associated with the die element
var color : Color

## The element's basic effect
var effect : StatusEffect.EffectType
		
## Mandatory to give each element its own string representation
## Override this in your class
func _to_string():
	assert(false,
		"UNIMPLEMENTED ERROR: _to_string()\n
		 PLEASE IMPLEMENT THIS FUNCTION TO YOUR CLASS")

