extends Control

var start
var battle
var campfire
var boss
var root

func save():
	#var root = get_tree().get_root()
	var file_path = "res://map/map.tscn"
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(file_path,scene)

func _ready():
	root = get_node("/root")
	start = get_node("start")
	
	battle = get_node("battle")
	battle.disabled = true
	
	campfire = get_node("campfire")
	campfire.disabled = true
	
	boss = get_node("boss")
	boss.disabled = true

func _on_start_pressed():
	#start is a placeholder rn, but we could use it for an initial starting room for the player
	start.disabled = true
	battle.disabled = false
	save()
	#pass # Replace with function body.

func _on_battle_pressed():
	battle.disabled = true
	campfire.disabled = false
	save()
	get_tree().change_scene_to_file("res://battle.tscn") #switch to battle scene


func _on_campfire_pressed():
	campfire.disabled = true
	boss.disabled = false
	save()
	get_tree().change_scene_to_file("res://UI/campfire.tscn") #switch to campfire scene
	#pass


func _on_boss_pressed():
	boss.disabled = true
	save()
	#get_tree().change_scene_to_file("") insert path to boss scene here
	pass


func _on_quit_pressed():
	get_tree().quit() #quits the game rn
	
