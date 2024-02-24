extends Control

@export_file("*.tscn") var battle_path
@export_file("*.tscn") var upgrade_path

var recover_health_by = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_heal_button_pressed():
	# TODO: Should prolly be text box rather than a print statement
	print("I currently have %d health" % PlayerData.hp)
	
	PlayerData.hp += recover_health_by
	
	print("You Healed. You now have %d" % PlayerData.hp)
	
	# Change the transfer scene to be the map scene once that gets made
	get_tree().change_scene_to_file(battle_path)


func _on_upgrade_die_button_pressed():
	get_tree().change_scene_to_file(upgrade_path)
