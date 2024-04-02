# Represents only the data, and not any ui or whatever. We can use this class as
# a resource in a player scene to inlude ui and sprite and stuff.
class_name PlayerData extends Node

enum Difficulty {NOVICE, STANDARD, EXPERT}

# Use signals to notify the UI when the player's health changes
# Dunno if this is the best way to make sure health bars get updated,
# but at least it allows PlayerData to be decoupled from the UI.
static var _instance = PlayerData.new() # Signals can't be static
signal _hp_changed(new_hp)
signal _hp_max_changed(new_hp_max)
static var hp_changed: Signal:
	get:
		return _instance._hp_changed
	# set: # raise an error, prolly unnecessary
static var hp_max_changed: Signal:
	get:
		return _instance._hp_max_changed
	# set: # raise an error, prolly unnecessary

static var difficulty := Difficulty.STANDARD

static var hp = 75:
	set (value):
		hp = clamp(value, 0, hp_max)
		hp_changed.emit(hp)
static var hp_max = 75:
	set (value):
		hp_max = value
		hp_max_changed.emit(value)

#static var dice_bag = Die.to_dice([4, 6, 8, 4, 4, 4, 6, 6, 4, 4, 4, 8, 6, 4, 6, 4, 4, 8, 4, 10])
static var dice_bag = []
#var inventory # which may include dice not in the bag if that's what we want later.
#status_effects or whatever

# How many dice to draw from bag each turn during battle
static var dice_draws 	:= 5
static var dice_choices	:= 3

