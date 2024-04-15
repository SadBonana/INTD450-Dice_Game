extends Control

@export_file("*.tscn") var upgrade_path
@onready var heal_button = $MarginContainer/VBoxContainer/HBocContainer/HealButton

var recover_health_by = int(ceil(PlayerData.hp_max / 2))

func _ready():
	heal_button.text = "Recover %d Health" % recover_health_by
	print("recover by:", recover_health_by)


func _on_heal_button_pressed():
	# TODO: Should prolly be text box rather than a print statement
	SoundManager.heal.play()
	PlayerData.hp += recover_health_by
	
	# Back to the map
	queue_free()
	get_node("/root/Map").visible = true
	get_node("/root/Map").canvas_layer.visible = true


func _on_upgrade_die_button_pressed():
	queue_free()
	get_tree().change_scene_to_file(upgrade_path)
