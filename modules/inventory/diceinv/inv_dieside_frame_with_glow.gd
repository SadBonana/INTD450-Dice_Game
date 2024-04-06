extends Panel
class_name InvDiesideFrameGlow

## Assigning variables when Scene is created
@onready var element_visual : ColorRect = $Element
@onready var side_type: Label = $Type
@onready var side_value: Label = $Value
@onready var side_ref: DieSide
signal frame_clicked(dieside : DieSide)

var glow_power = 1.0
var speed = 2.0

## Changes label and inventory die texture accordingly
func update(dieside: DieSide):
	side_type.text = dieside.element._to_string()
	element_visual.color = dieside.element.color
	side_value.text = str(dieside.value)
	side_ref = dieside

func _process(delta):
	glow_power += delta * speed
	
	# Change 4.0 to 2.0 for blinking effect
	if glow_power >= 3.0 and speed > 0 or glow_power <= 1.0 and speed < 0:
		speed *= -1.0
	
	get_material().set_shader_parameter("glow_color", element_visual.color)
	get_material().set_shader_parameter("glow_power", glow_power)
