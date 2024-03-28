extends Control

# Attach 2 loot tables (common loot tables, uncommon loot table)
@export var common_loot_table: LootTable
@export var uncommon_loot_table: LootTable

@onready var textbox_controller := $"VBoxContainer/HBoxContainer2/Textbox Controller"
@onready var inventory := $VBoxContainer/HBoxContainer/dice_bag

var selected_die
var dropped_die_array: Array[Die] = []
var index_of_dropped_die = []
var chosen_loot_table


func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	
	match from_beat.unique_name:
		"confirm":
			if from_choice == 0:
				print("player said yes")
				await textbox_controller.quick_beat("confirm2", [], _on_dialogue_transitiond)
				await textbox_controller.quick_beat("confirm3", [], _on_dialogue_transitiond)
			else:
				print("player said no")
				#choices_container.visible = false
				
				#Close preview
				inventory.is_side_view_open = false
				inventory.show_dice()
	
	match from_beat.unique_name:
		"confirm3":
			if from_choice == 0:
				PlayerData.dice_bag.append(selected_die)
				#inventory.is_side_view_open = false
				#inventory.close()
				await textbox_controller.quick_beat("drop_confirm", [], _on_dialogue_transitiond)
				# Change to map once done
				queue_free()
			else:
				await textbox_controller.quick_beat("no_die", [], _on_dialogue_transitiond)
				queue_free()


func select_die(frame):
	selected_die = frame
	
	# Open upgrade preview
	inventory.show_sides(frame)
	
	# Display prompt
	#choices_container.visible = true
	await textbox_controller.quick_beat("confirm", [], _on_dialogue_transitiond)


# Called when the node enters the scene tree for the first time.
func _ready():
	item_generation()
	inventory.display_bag = dropped_die_array
	await textbox_controller.quick_beat("congrats", [], _on_dialogue_transitiond)
	inventory.in_battle_drop_scene = true
	inventory.frame_clicked.connect(select_die)


func item_generation():
	# Use probability to determine only ONE loot table 
	var rarity_roll = randi() % 100 + 1
	print("Probability is:", rarity_roll)
	
	if rarity_roll >= 0 and rarity_roll <= 1:
		chosen_loot_table = common_loot_table
	else:
		chosen_loot_table = uncommon_loot_table
	
	# <= does not work, you get 4 die objects
	while index_of_dropped_die.size() < 3:
		# Use pick_loot (uses pick_random) to grab 3 random die from that ONE loot table
		var drop = chosen_loot_table.pick_loot()
		print("Drop sides are:", drop.sides)
		
		var drop_index = chosen_loot_table.basic_loot.find(drop)
		print("drop index is:", drop_index)	
	
		if drop_index not in index_of_dropped_die:
			index_of_dropped_die.append(drop_index)
			dropped_die_array.append(drop)
		
		print("index of dropped die array:", index_of_dropped_die)
