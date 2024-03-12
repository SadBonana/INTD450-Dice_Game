extends Control

@export_file("*.tscn") var map_path

# Textbox
@onready var textbox_controller := $"VBoxContainer/choices_container/Textbox Controller"
@onready var inventory := $dice_bag


# Textbox
'''@export var textbox: Panel
@export var textboxLabel: Label
signal textbox_closed

func display_text(text):
	textbox.show()
	textboxLabel.text = text'''

'''func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")'''



func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	match from_beat.unique_name:
		"confirm":
			if from_choice == 0:
				print("player said yes")
			else:
				print("player said no")


func select_die(frame):
	frame.show_sides

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#display_text("You selected the proficiency upgrade")
	#await textbox_closed
	
	#inventory.frame_clicked.connect(select_die)
	inventory.frame_clicked.connect(inventory.show_sides)
	
	await textbox_controller.quick_beat("confirm", [], _on_dialogue_transitiond)
	
	var die = PlayerData.dice_bag[0]
	
	for i in range(die.num_sides):
				# Change to 10 to test -> allows for easy identification otherwsie you need to roll a 5 to see result
				die.sides[i].value += 1
				die.name = "D%d - prof" % die.num_sides
				print(die.name)
				print(die.sides[i].value)
	
	#display_text("Congrats! You upgraded your D%d" % die.num_sides)
	#await textbox_closed
	
	get_tree().change_scene_to_file(map_path)
