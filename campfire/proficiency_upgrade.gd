class_name ProficiencyUpgrade extends Node

# Textbox
@onready var choices_container := $VBoxContainer/choices_container
@onready var textbox_controller := $"VBoxContainer/choices_container/Textbox Controller"
@onready var inventory := %dice_bag

@onready var upgrade_frame = preload("res://campfire/upgrade_frame.tscn")
@onready var inv_dice_visual = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
@onready var side_name = "Preview Upgrade"

@export var temp_dice_bag_init: PlayerDataInit

var selected_die


func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	match from_beat.unique_name:
		"confirm":
			if from_choice == 0:
				print("player said yes")
				upgrade_die()
				await textbox_controller.quick_beat("congrats", [], _on_dialogue_transitiond)
				queue_free()
				#get_node("/root/Map").show()
				get_node("/root/Map").visible = true
			else:
				print("player said no")
				
				#Close preview
				selected_die = null
				print("selected_die sides after no:", selected_die)
				
				inventory.current_tab = 0
				await textbox_controller.quick_beat("directions", [], _on_dialogue_transitiond)


func show_sides(die : Die):
	var side_view
	var duplicate_side
	
	
	for child in inventory.get_children():
		if child.tabobj_ref.get_tab_title() == side_name:	 #hardcoded cause bro this shit is ass
			side_view = child
	SoundManager.select_3.play()
	var upgrade_frames = []
	var arr
	for side in die.sides:
		arr = []
		arr.append(side)
		duplicate_side = side.duplicate(true)
		duplicate_side.value += 1
		arr.append(duplicate_side)
		upgrade_frames.append(arr)
	
	
	if side_view == null:
		return
	else:
		side_view.new_frames(upgrade_frames)
		inventory.current_tab = side_view.get_index()
	
	print("og die sides size 7:", die.sides.size())


func select_die(frame):
	selected_die = frame
	
	# Open upgrade preview
	show_sides(frame)
	
	# Display prompt
	await textbox_controller.quick_beat("confirm", [], _on_dialogue_transitiond)
 

func upgrade_die():
	# Get the index of the selected die
	var die_index = PlayerData.dice_bag.find(selected_die, 0)
	print("die index:", die_index)
	
	# Make a duplicate of the selected die using it's index
	var upgraded_die = PlayerData.dice_bag[die_index].duplicate(true)
	
	# Init array to store the upgraded die sides, which will also be duplicates
	var duplicated_sides: Array[DieSide] = []
	
	# Loop for each die side
	for i in range(selected_die.sides.size()):
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
	
	print("Congrats! You upgraded your D%d" % selected_die.num_sides)


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("/root/Map").hide()
	get_node("/root/Map").visible = false
	get_node("/root/Map").player_status.visible = false
	
	if PlayerData.dice_bag.size() == 0:
		PlayerData.dice_bag = temp_dice_bag_init.dice.duplicate(true)
	
	## setup for dice inventory tab
	inventory.make_tab("Upgrade Options", PlayerData.dice_bag, inv_dice_visual)
	## setup for die sides inventory tab
	inventory.make_tab(side_name, [], upgrade_frame)
	
	inventory.return_clicked.connect(select_die)
	await textbox_controller.quick_beat("intro", [], _on_dialogue_transitiond)
	inventory.open()
	await textbox_controller.quick_beat("directions", [], _on_dialogue_transitiond)
