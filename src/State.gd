extends Node

var player_health = 75
var player_health_max = 75
var player_damage = 20

class dice:
	var num_sides: int
	var sides
	#var effect
	#var roll
	var name
	
	
	func _init(number_sides, actual_sides, dice_name):
		num_sides = number_sides
		sides = actual_sides
		name = dice_name

var D4 = dice.new(4, [1, 2, 3, 4], "D4")
var D6 = dice.new(6, [1, 2, 3, 4, 5, 6], "D6")
var D8 = dice.new(8, [1, 2, 3, 4, 5, 6, 7, 8], "D8")
var D10 = dice.new(10, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "D10")

# Gonna do this the dumb way for now so I can focus on the bigger picture:
# Number in the array represents max roll
#var player_dice_bag = [4, 6, 8, 4, 4, 4, 6, 6, 4, 4, 4, 8, 6, 4, 6, 4, 4, 8, 4, 10]
var player_dice_bag = []

# Called when the node enters the scene tree for the first time.
func _ready():
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	player_dice_bag.append(D4)
	
	player_dice_bag.append(D6)
	player_dice_bag.append(D6)
	player_dice_bag.append(D6)
	player_dice_bag.append(D6)
	player_dice_bag.append(D6)
	
	player_dice_bag.append(D8)
	player_dice_bag.append(D8)
	player_dice_bag.append(D8)
	
	player_dice_bag.append(D10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
