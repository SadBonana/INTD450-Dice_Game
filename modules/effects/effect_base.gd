extends Resource
## The base class for all effect classes
##
## All effect classes must inherit this one
class_name BaseEffect

## All possible effects
enum EffectType {
	NONE,
}

## The effect's inherent value
@export var value : int
