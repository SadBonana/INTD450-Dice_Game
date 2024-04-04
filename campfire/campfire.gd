extends Control

@export_file("*.tscn") var map_path
#@export_file("*.tscn") var upgrade_path
var upgrade_path = "res://campfire/proficiency_upgrade.tscn"

var recover_health_by = 15


func _on_heal_button_pressed():
	# TODO: Should prolly be text box rather than a print statement
	SoundManager.heal.play()
	print("I currently have %d health" % PlayerData.hp)
	
	PlayerData.hp += recover_health_by
	
	print("You Healed. You now have %d" % PlayerData.hp)
	
	# Change the transfer scene to be the map scene once that gets made
	#get_tree().change_scene_to_file(map_path)
	queue_free()
	get_node("/root/Map").visible = true
	#get_owner().queue_free()


func _on_upgrade_die_button_pressed():
	get_tree().change_scene_to_file(upgrade_path)
	queue_free()  
	get_node("/root/Map").visible = true        #TODO fix this jank code
	#get_tree().change_scene_to_file("res://campfire/proficiency_upgrade.tscn")
