extends Control

func _on_start_pressed():

	#%battle.disabled = false
	pass # Replace with function body.


func _on_battle_pressed():
	#%campfire.disabled = false
	get_tree().change_scene_to_file("res://battle.tscn") #switch to battle scene


func _on_campfire_pressed():
	#%boss.disabled = false
	#get_tree().change_scene_to_file("") insert path to campfire scene here
	pass


func _on_boss_pressed():
	#get_tree().change_scene_to_file("") insert path to boss scene here
	pass


func _on_quit_pressed():
	get_tree().quit() #quits the game rn
	
