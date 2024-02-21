## Class defining a single side of any given die
class_name DieSide

## The value/cost of this die side
@export var power : int

## The element associated with this die side
@export var element : BaseElement

## The numerical value on this die side
@export var value : int

## The special effects on this die side
@export var effects : Array

## Constructor
## has default values:
## custom_power is false, make it true if you want to bypass the power_calc function
## power is calculated using power_calc func
## element is Fire
## value is a random integer between 1 & 20
## effect is nothing
func _init(custom_power:bool=false,
			_power:int=0,
				_element:BaseElement=Fire.new(),
					_value:int=randi_range(1,20),
						_effects:Array=[]):
				
	if(not custom_power):
		self.power = power_calc(_element, _value, _effects)
	else:
		self.power = _power
	self.element = _element
	self.value = _value
	self.effects = _effects
	

## calculates the power of a side
## requires the element, number value, and effects of the side
## returns an integer
func power_calc(_element:BaseElement, _value:int, _effects:Array) -> int:
	var total:int = 0
	for _effect in _effects:
		total += _effect.value
	total += (_element.value + _value)
	return total

## A string representation of this die side
func _to_string() -> String:
	var text = "%d\n(%s)" % [value,element]
	return text
	
	
	


