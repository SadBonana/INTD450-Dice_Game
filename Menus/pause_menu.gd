extends Control


var _is_paused:bool = false:
	set = set_paused


# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()
	#visible = false
	hide()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused


func set_paused(value:bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused


func _on_resume_pressed():
	set_paused(false)
