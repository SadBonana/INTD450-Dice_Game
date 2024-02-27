class_name HealthBar extends ProgressBar

@export var label: Label

static var f_string = "HP: %d/%d"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_value_changed(value):
	label.text = f_string % [value, max_value]


func _on_changed():
	label.text = f_string % [value, max_value]
