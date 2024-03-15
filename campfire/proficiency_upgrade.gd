extends Control

@export_file("*.tscn") var map_path

# Textbox
@onready var choices_container := $VBoxContainer/choices_container
@onready var textbox_controller := $"VBoxContainer/choices_container/Textbox Controller"
@onready var inventory := $VBoxContainer/inventory_container/dice_bag
@onready var arrow_label := $VBoxContainer/inventory_container/dice_bag/MarginContainer/ScrollContainer/VBoxContainer/arrow_label

var die

func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	match from_beat.unique_name:
		"confirm":
			if from_choice == 0:
				print("player said yes")
				upgrade_die()
			else:
				print("player said no")
				#choices_container.visible = false
				
				#Close preview
				arrow_label.visible = false
				inventory.is_side_view_open = false
				inventory.show_dice()


func select_die(frame):
	die = frame
	
	# Open upgrade preview
	inventory.show_sides(frame)
	arrow_label.visible = true
	
	# Display prompt
	#choices_container.visible = true
	await textbox_controller.quick_beat("confirm", [], _on_dialogue_transitiond)


func upgrade_die():
	for i in range(die.num_sides):
		# Change to 10 to test -> allows for easy identification otherwsie you need to roll a 5 to see result
		die.sides[i].value += 1
		
		#die.name = "D%d - prof" % die.num_sides
		#print(die.name)
		print(die.sides[i].value)
	
	print("Congrats! You upgraded your D%d" % die.num_sides)
	inventory.in_upgrade_scene = false
	get_tree().change_scene_to_file(map_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory.in_upgrade_scene = true
	inventory.frame_clicked.connect(select_die)
