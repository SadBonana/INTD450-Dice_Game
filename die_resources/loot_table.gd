class_name LootTable extends Resource

# TODO: make it fancy schmancy with stuff like better drops depending on
# some level or progress variable and whatnot.

@export var basic_loot: Array[Die]
#@export var rare_loot: Array[Die]

# TODO: make fancier
func pick_loot():
	return basic_loot.pick_random()
