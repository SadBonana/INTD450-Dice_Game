extends Control

@export_file("*.tscn") var upgrade_path
@onready var heal_button = $MarginContainer/VBoxContainer/HBocContainer/HealButton
@onready var campfire_scene = $"."

var recover_health_by = int(ceil(PlayerData.hp_max / 2))

func _ready():
	heal_button.text = "Recover %d Health" % recover_health_by
	print("recover by:", recover_health_by)


func _on_heal_button_pressed():
	# TODO: Should prolly be text box rather than a print statement
	print("I currently have %d health" % PlayerData.hp)
	
	PlayerData.hp += recover_health_by
	
	print("You Healed. You now have %d" % PlayerData.hp)
	
	# Change the transfer scene to be the map scene once that gets made
	#get_tree().change_scene_to_file(map_path)
	queue_free()
	get_node("/root/Map").visible = true
	#get_owner().queue_free()


func _on_upgrade_die_button_pressed():
	campfire_scene.hide()
	get_tree().change_scene_to_file(upgrade_path)
