extends Panel

## Assigning variables when Scene is created
@onready var element_visual : ColorRect = $Element
@onready var side_type: Label = $Type
@onready var side_value: Label = $Value
@onready var side_ref: DieSide
signal frame_clicked(dieside : DieSide)

## Changes label and inventory die texture accordingly
func update(dieside: DieSide):
	side_type.text = dieside.element._to_string()
	element_visual.color = dieside.element.color
	side_value.text = str(dieside.value)
	side_ref = dieside
