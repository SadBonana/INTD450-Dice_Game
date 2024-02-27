# Represents only the data, and not any ui or whatever. We can use this class as
# a resource in a player scene to inlude ui and sprite and stuff.
class_name PlayerData extends Node

static var hp = 75
static var hp_max = 75
static var dice_bag = Die.to_dice([4, 6, 8, 4, 4, 4, 6, 6, 4, 4, 4, 8, 6, 4, 6, 4, 4, 8, 4, 10])
#var inventory # which may include dice not in the bag if that's what we want later.
