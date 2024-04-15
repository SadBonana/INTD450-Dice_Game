extends Control

# Attach 2 loot tables (common loot tables, uncommon loot table)
@export var common_loot_table: LootTable
@export var uncommon_loot_table: LootTable

@onready var textbox_controller := %"Textbox Controller"
@onready var inventory := %item_drop_display
@onready var loot_drop_container := %LootDropContainer
@onready var inv_dice_visual = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
@onready var inv_side_visual = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")
@onready var side_name = "Sides"
@onready var skip_rewards = %skip_reward

var selected_die
var dropped_die_array: Array[Die] = []
var index_of_dropped_die = []
var chosen_loot_table


func _on_dialogue_transitiond(from_beat: DialogueBeat, destination_beat: String, from_choice: int):
	
	match from_beat.unique_name:
		"confirm":
			if from_choice == 0:
				PlayerData.dice_bag.append(selected_die)
				await textbox_controller.quick_beat("drop_confirm", [], _on_dialogue_transitiond)
				exit_drop_screen()
			else:
				print("player said no")
				inventory.current_tab = 0
				await textbox_controller.quick_beat("directions", [], _on_dialogue_transitiond)

func show_sides(die : Die):
	var side_view
	
	for child in inventory.get_children():
		if child.tabobj_ref.get_tab_title() == side_name:	 #hardcoded cause bro this shit is ass
			side_view = child
	
	if side_view == null:
		return
	else:
		side_view.new_frames(die.sides)
		inventory.current_tab = side_view.get_index()


func select_die(frame):
	selected_die = frame
	# Open side preview
	show_sides(frame)
	# Display prompt
	textbox_controller.visible = true
	await textbox_controller.quick_beat("confirm", [], _on_dialogue_transitiond)


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Map").hide()
	get_node("/root/Map").canvas_layer.visible = true
	get_node("/root/Map").player_status_container.visible = false
	
	# Generate 3 random battle drop items from a randomly selected loot table
	item_generation()
	
	## setup for dice inventory tab
	inventory.make_tab("Dropped Items", dropped_die_array, inv_dice_visual)
	## setup for die sides inventory tab
	inventory.make_tab(side_name, [], inv_side_visual)
	
	skip_rewards.pressed.connect(skip_reward)
	inventory.return_clicked.connect(select_die)
	
	await textbox_controller.quick_beat("congrats", [], _on_dialogue_transitiond)
	
	inventory.open()
	skip_rewards.visible = true
	get_node("/root/Map").player_status_container.visible = true
	
	await textbox_controller.quick_beat("directions", [], _on_dialogue_transitiond)


func skip_reward():
	inventory.hide()
	await textbox_controller.quick_beat("no_die", [], _on_dialogue_transitiond)
	exit_drop_screen()


func item_generation():
	# Use probability to determine only ONE loot table 
	var rarity_roll = randi() % 100 + 1
	print("Probability is:", rarity_roll)
	
	if rarity_roll >= 0 and rarity_roll <= 60:
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


func exit_drop_screen():
	queue_free()
	get_node("/root/Map").canvas_layer.visible = true
	get_node("/root/Map").show()
