extends Control

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
	# Get the index of the selected die
	var die_index = PlayerData.dice_bag.find(die, 0)
	print("die index:", die_index)
	
	# Make a duplicate of the selected die using it's index
	var upgraded_die = PlayerData.dice_bag[die_index].duplicate(true)
	
	# Init array to store the upgraded die sides, which will also be duplicates
	var duplicated_sides: Array[DieSide] = []
	
	# Loop for each die side
	for i in range(die.sides.size()):
		# Duplicate the current die side
		var die_side = upgraded_die.sides[i].duplicate(true)
		
		# Increase the die side's value by 1
		die_side.value += 1
		#print(die_side.value)
		
		# Store the die side in the duplicated die sides array
		duplicated_sides.append(die_side)
	
	# Set the sides of the duplicated die to be the upgraded sides (which are also duplicates)
	upgraded_die.sides = duplicated_sides
	
	# Set the old die to equal the new upgraded die
	PlayerData.dice_bag[die_index] = upgraded_die
	
	print("Congrats! You upgraded your D%d" % die.num_sides)
	inventory.in_upgrade_scene = false
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory.in_upgrade_scene = true
	inventory.frame_clicked.connect(select_die)
	inventory.display_bag = PlayerData.dice_bag
