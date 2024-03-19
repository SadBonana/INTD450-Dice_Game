extends Control

@export var loot_table: LootTable
@export_file("*.tscn") var map_path

@onready var textbox_controller := $"VBoxContainer/HBoxContainer2/Textbox Controller"
@onready var inventory := $VBoxContainer/HBoxContainer/dice_bag

var item_dict = {"D3": 40, "D4": 30, "D6": 20, "D8": 10}
var selected_die
var dropped_die_array: Array[Die] = []


func get_drop_array():
	return dropped_die_array


func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	match from_beat.unique_name:
		"confirm":
			if from_choice == 0:
				print("player said yes")
				PlayerData.dice_bag.append(selected_die)
				# Change to map once done
				get_tree().change_scene_to_file(map_path)
			else:
				print("player said no")
				#choices_container.visible = false
				
				#Close preview
				inventory.is_side_view_open = false
				inventory.show_dice()


func select_die(frame):
	selected_die = frame
	
	# Open upgrade preview
	inventory.show_sides(frame)
	
	# Display prompt
	#choices_container.visible = true
	await textbox_controller.quick_beat("confirm", [], _on_dialogue_transitiond)


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(3):
		var dropped_die = item_generation()
		dropped_die_array.append(dropped_die)
		print("stored die")
	
	inventory.display_bag = dropped_die_array
	inventory.in_battle_drop_scene = true
	inventory.frame_clicked.connect(select_die)


func item_generation():
	'''var new_item_rarity
	var item_rarities = item_dict.keys()
	randomize()
	var rarity_roll = randi() % 100 + 1
	print("Probability is:", rarity_roll)
	var drop
	
	for item in item_rarities:
		if rarity_roll <= item_dict[item]:
			new_item_rarity = item
			break
		else:
			rarity_roll -= item_dict[item]
	
	if rarity_roll >= 0 and rarity_roll <= 40:
		drop = loot_table.basic_loot[0]
	if rarity_roll > 40 and rarity_roll <= 70:
		drop = loot_table.basic_loot[1]
	if rarity_roll > 70 and rarity_roll <= 90:
		drop = loot_table.basic_loot[2]
	if rarity_roll > 90 and rarity_roll <= 100:
		drop = loot_table.basic_loot[3]'''
	
	#var drop = Die.new( int(new_item_rarity.get_slice("D", 1)) )
	# FIXME: Die.new() doesnt and won't ever work. now we have LootTable,
	# but the rest of this code hasn't been adapted to use it, so this is
	# currently a very half assed fix:
	var drop = loot_table.pick_loot()
	print("The dropped die has:", drop.num_sides)
	
	PlayerData.dice_bag.append(drop)
	#print("Drop is D%s" % new_item_rarity.get_slice("D", 1))
	
	return drop
