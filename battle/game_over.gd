extends Control

@onready var textbox_controller = $"VBoxContainer/Textbox Controller"

func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	match from_beat.unique_name:
		"winner_1":
			if from_choice == 0:
				pass
			else:
				pass


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Map").canvas_layer.visible = false
	get_node("/root/Map").visible = false
	await textbox_controller.quick_beat("winner_1", [], _on_dialogue_transitiond)
	await textbox_controller.quick_beat("winner_2", [], _on_dialogue_transitiond)
	get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
