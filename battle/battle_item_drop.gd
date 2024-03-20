extends Control

@export var loot_table: LootTable
@export var common_loot_table: LootTable
@export var uncommon_loot_table: LootTable
@export_file("*.tscn") var map_path

@onready var textbox_controller := $"VBoxContainer/HBoxContainer2/Textbox Controller"
@onready var inventory := $VBoxContainer/HBoxContainer/dice_bag

var item_dict = {"D3": 40, "D4": 30, "D6": 20, "D8": 10}
var selected_die

var dropped_die_array: Array[Die] = []
var index_of_dropped_die = []
var chosen_loot_table


func get_drop_array():
	return dropped_die_array


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
				#get_tree().change_scene_to_file(map_path)
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
	#await textbox_controller.quick_beat("congrats2", [], _on_dialogue_transitiond)
	inventory.in_battle_drop_scene = true
	inventory.frame_clicked.connect(select_die)


func item_generation():
	'''var new_item_rarity
	var item_rarities = item_dict.keys()
	randomize()
	var rarity_roll = randi() % 100 + 1
	print("Probability is:", rarity_roll)
	
	for item in item_rarities:
		if rarity_roll <= item_dict[item]:
			new_item_rarity = item
			break
		else:
			rarity_roll -= item_dict[item]'''
	
	# Attach muliple loot tables (common loot tables, uncommon loot table, etc)
	# Use probability to determine only ONE loot table
	# Use pick_random to grab 3 random die from that ONE loot table 
	
	'''if rarity_roll >= 0 and rarity_roll <= 40:
		drop = loot_table.basic_loot[0]
		drop_index = 0
		#index_of_dropped_die.append(0)
	if rarity_roll > 40 and rarity_roll <= 70:
		drop = loot_table.basic_loot[1]
		drop_index = 1
		#index_of_dropped_die.append(0)
	if rarity_roll > 70 and rarity_roll <= 90:
		drop = loot_table.basic_loot[2]
		drop_index = 2
		#index_of_dropped_die.append(0)
	if rarity_roll > 90 and rarity_roll <= 100:
		drop = loot_table.basic_loot[3]
		drop_index = 3
		#index_of_dropped_die.append(0)'''
	
	var rarity_roll = randi() % 100 + 1
	print("Probability is:", rarity_roll)
	
	if rarity_roll >= 0 and rarity_roll <= 50:
		chosen_loot_table = common_loot_table
	else:
		chosen_loot_table = uncommon_loot_table
	
	# <= does not work, you get 4 die objects
	while index_of_dropped_die.size() < 3:
		var drop = chosen_loot_table.pick_loot()
		var drop_index = chosen_loot_table.basic_loot.find(drop)
		print("drop index is:", drop_index)
	
		if drop_index not in index_of_dropped_die:
			index_of_dropped_die.append(drop_index)
			dropped_die_array.append(drop)
			print("stored die")
		
		print("index of dropped die array:", index_of_dropped_die)
	
	#var drop = Die.new( int(new_item_rarity.get_slice("D", 1)) )
	# FIXME: Die.new() doesnt and won't ever work. now we have LootTable,
	# but the rest of this code hasn't been adapted to use it, so this is
	# currently a very half assed fix:
	#var drop = loot_table.pick_loot()
	#print("The dropped die has:", drop.num_sides)
	
	#PlayerData.dice_bag.append(drop)
	#print("Drop is D%s" % new_item_rarity.get_slice("D", 1))
	
	#return drop
