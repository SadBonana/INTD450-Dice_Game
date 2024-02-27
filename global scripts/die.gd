class_name Die

var num_sides: int
var sides
#var effect
#var sprite or 3d model or reference to some other thing related to the die
var name # mainly meant to distinguish e.g. 2 d10's with different effects.
	
	
func _init(number_sides, actual_sides=range(1, number_sides+1), dice_name="d%d"%number_sides):
	num_sides = number_sides
	sides = actual_sides
	name = dice_name


func roll():
	return sides.pick_random()


### int_arr should be an array of ints representing max rolls
### NOTE: Mutates the array.
#static func to_dice(int_arr: Array):
	#for i in range(int_arr.size()):
		#int_arr[i] = Die.new(int_arr[i])
	#return int_arr


## int_arr should be an array of ints representing max rolls
## NOTE: No longer mutates int_arr. idk y I wrote it that way in the first place, was really dumb.
static func to_dice(int_arr: Array[int]):
	var die_arr: Array[Die] = []
	for max_roll in int_arr:
		die_arr.append(Die.new(max_roll))
	return die_arr
