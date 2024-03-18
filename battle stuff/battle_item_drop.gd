extends Control

@export var loot_table: LootTable

@export_file("*.tscn") var map_path

# Textbox
@export var textbox: Panel
@export var textboxLabel: Label
signal textbox_closed

var item_dict = {"D4": 50, "D6": 25, "D8": 15, "D10": 7, "D20": 3}

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	display_text("Congrats, you beat the enemy")
	await textbox_closed
	
	var item_drop = item_generation()
	
	display_text("Congrats, you just received a D%s" % item_drop.get_slice("D", 1))
	await textbox_closed
	
	# Change to map once done
	#get_tree().change_scene_to_file(map_path)
	get_tree().unload_current_scene()

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	textbox.show()
	textboxLabel.text = text

func item_generation():
	var new_item_rarity
	var item_rarities = item_dict.keys()
	randomize()
	var rarity_roll = randi() % 100 + 1
	
	for item in item_rarities:
		if rarity_roll <= item_dict[item]:
			new_item_rarity = item
			break
		else:
			rarity_roll -= item_dict[item]
	
	#var drop = Die.new( int(new_item_rarity.get_slice("D", 1)) )
	# FIXME: Die.new() doesnt and won't ever work. now we have LootTable,
	# but the rest of this code hasn't been adapted to use it, so this is
	# currently a very half assed fix:
	var drop = loot_table.pick_loot()
	PlayerData.dice_bag.append(drop)
	print("Drop is D%s" % new_item_rarity.get_slice("D", 1))
	
	'''if new_item_rarity == "D4":
		var drop = Die.new(4)
		PlayerData.dice_bag.append(drop)
		print("Drop is D%d" % 4)
	
	if new_item_rarity == "D6":
		var drop = Die.new(6)
		PlayerData.dice_bag.append(drop)
		print("Drop is D%d" % 6)
	
	if new_item_rarity == "D8":
		var drop = Die.new(8)
		PlayerData.dice_bag.append(drop)
		print("Drop is D%d" % 8)
	
	if new_item_rarity == "D10":
		var drop = Die.new(10)
		PlayerData.dice_bag.append(drop)
		print("Drop is D%d" % 10)
	
	if new_item_rarity == "D20":
		var drop = Die.new(20)
		PlayerData.dice_bag.append(drop)
		print("Drop is D%d" % 20)'''
	
	return new_item_rarity
