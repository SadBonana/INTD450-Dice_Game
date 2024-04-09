extends Resource
## Class defining a single side of any given die
class_name DieSide

## The value/cost of this die side
@export var power : int

## If true then this die side will use a custom power
## instead of its power calculation function
@export var custom_power : bool

## The element associated with this die side
@export var element : BaseElement

## The numerical value on this die side
@export var value : int

## The special effects on this die side, besides the default element effect
var extra_effects : Array[StatusEffect]
# TODO: USE THIS IF YOU WANT EXTRA EFFECTS:
#@export var extra_effects : Array[StatusEffect.EffectType]

## Constructor
## has default values:
## custom_power is false, make it true if you want to bypass the power_calc function
## power is calculated using power_calc func
## element is Basic
## value is a random integer between 1 & 20
## effect is nothing
func _init(_custom_power:bool=false,
			_power:int=0,
				_element:BaseElement=Basic.new(),
					_value:int=randi_range(1,20),
						_effects:Array[StatusEffect]=[]):
			
	self.custom_power = _custom_power
	if(not self.custom_power):
		self.power = power_calc(_element, _value, _effects)
	else:
		self.power = _power
		
	self.element = _element
	self.value = _value
	self.extra_effects = _effects
	

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

func info() -> String:
	if element is Basic:
		return "Deal %d damage to the target." % [value]
	elif element is Steel:
		return "Add %d shield." % [value]
	var text
	var stacks
	var damage
	if element.stack_roll:
		stacks = value
		damage = 0
	else:
		stacks = 1
		damage = value
		
	text = "Apply %d stack(s) and deal %d damage to the target." % [stacks, damage]
	return text
	
	
	


