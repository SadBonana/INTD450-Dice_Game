extends VBoxContainer

@onready var current_die_side := %CurrentDieSide
@onready var upgraded_die_side := %UpgradedDieSide
@onready var side_ref: DieSide
signal frame_clicked()


## Changes label and inventory die texture accordingly
func update(arr: Array):
	assert(arr.size() == 2, "There must be 2 diesides passed into the update frame")
	current_die_side.update(arr[0])
	upgraded_die_side.update(arr[1])
