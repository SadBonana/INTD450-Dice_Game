class_name Die

@export var num_sides: int
@export var sides : Array[DieSide]
var sprite : Sprite2D # the sprite representing the die
var name # mainly meant to distinguish e.g. 2 d10's with different effects.
	
	
func _init(number_sides, actual_sides=range(1, number_sides+1), dice_name="d%d"%number_sides):
	self.num_sides = number_sides
	for side in actual_sides:
		self.sides.append(DieSide.new())
	self.name = dice_name
	sprite = Sprite2D.new()
	sprite.texture = sprite_decider(num_sides)

## returns a die side object
func roll():
	return sides.pick_random()

## Based off the number given, this function will return the
## proper InvDie Resource to represent the die visually
## There has to be a better way to do this, but idk how
func sprite_decider(total_sides : int):
	var sprite
	match total_sides:
		4: ## Its a D4
			sprite = load("res://modules/inventory/images/D4.png")
		6: ## Its a D6
			sprite = load("res://modules/inventory/images/D6.png")
		8: ## Its a D8
			sprite = load("res://modules/inventory/images/D8.png")
		10: ## Its a D10
			sprite = load("res://modules/inventory/images/D10.png")
		12: ## Its a D12
			sprite = load("res://modules/inventory/images/D12.png")
		20: ## Its a D20
			sprite = load("res://modules/inventory/images/D20.png")
	return sprite

# Should be an array of ints representing max rolls
# Note: Mutates the array.
static func to_dice(int_arr: Array):
	for i in range(int_arr.size()):
		int_arr[i] = Die.new(int_arr[i])
	return int_arr
