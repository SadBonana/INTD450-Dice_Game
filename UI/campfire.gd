extends Control

var recover_health_by = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_heal_button_pressed():
	print("I currently have %d health" % State.player_health)
	
	State.player_health += recover_health_by
	
	#var player_health = State.player_health
	
	print("You Healed. You now have %d" % State.player_health)
	
	if State.player_health > State.player_health_max:
		State.player_health = State.player_health_max
		print("Changed health to max")
	
	# Change the transfer scene to be the map scene once that gets made
	get_tree().change_scene_to_file("res://battle.tscn")


func _on_upgrade_die_button_pressed():
	get_tree().change_scene_to_file("res://UI/upgrade_die.tscn")
