extends ScrollContainer

## Variable containing reference to the ScrollContainer itself
@onready var scrollcon : ScrollContainer = $"."

## Variable that determines scrollspeed
@export var scrollspeed : int = 100

## Just takes care of scrolling with the mousewheel
func _process(delta):
	if Input.is_action_just_released("MWD"):
		scrollcon.scroll_vertical += scrollspeed
	elif Input.is_action_just_released("MWU"):
		scrollcon.scroll_vertical -= scrollspeed
		
