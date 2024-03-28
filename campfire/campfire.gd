extends Control

@export_file("*.tscn") var upgrade_path

var recover_health_by = 15


func _on_heal_button_pressed():
	# TODO: Should prolly be text box rather than a print statement
	print("I currently have %d health" % PlayerData.hp)
	
	PlayerData.hp += recover_health_by
	
	print("You Healed. You now have %d" % PlayerData.hp)
	
	# Change the transfer scene to be the map scene once that gets made
	queue_free()


func _on_upgrade_die_button_pressed():
	get_tree().change_scene_to_file(upgrade_path)
