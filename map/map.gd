extends Control

@export var map_data : map_resource

var start =    [0, null]
var battle =   [1, null]
var campfire = [2, null]
var boss =     [3, null]
var root =     [4, null]

func save():
	#var map = preload("map_resource.gd")
	
	#map_data = map_resource.New()
	#var root = get_tree().get_root()
	var file_path = "res://map/map_resource.tres"
	#var scene = PackedScene.new()
	#scene.pack(root)
	ResourceSaver.save(map_data,file_path)
	#pass

func _ready():
	#map_data = map_data_load.new()
	print(map_data.completion)
	
	root[1] = get_node("/root")
	start[1] = get_node("start")
	
	battle[1] = get_node("battle")
	if map_data.completion[start[0]] == 0 or map_data.completion[battle[0]] == 1:
		battle[1].disabled = true
	
	campfire[1] = get_node("campfire")
	
	if map_data.completion[battle[0]] == 0 or map_data.completion[campfire[0]] == 1:
		campfire[1].disabled = true
	
	boss[1] = get_node("boss")
	if map_data.completion[campfire[0]] == 0:
		boss[1].disabled = true

func _on_start_pressed():
	#start is a placeholder rn, but we could use it for an initial starting room for the player
	start[1].disabled = true
	map_data.completion[start[0]] = 1
	battle[1].disabled = false
	save()
	#pass # Replace with function body.

func _on_battle_pressed():
	#save()
	battle[1].disabled = true
	map_data.completion[battle[0]] = 1
	campfire[1].disabled = false
	save()
	get_tree().change_scene_to_file("res://battle.tscn") #switch to battle scene


func _on_campfire_pressed():
	#save()
	campfire[1].disabled = true
	map_data.completion[campfire[0]] = 1
	boss[1].disabled = false
	save()
	get_tree().change_scene_to_file("res://UI/campfire.tscn") #switch to campfire scene
	#pass


func _on_boss_pressed():
	boss[1].disabled = true
	map_data.completion[boss[0]] = 1
	save()
	#get_tree().change_scene_to_file("") insert path to boss scene here
	#pass


func _on_quit_pressed():
	for i in range(map_data.num_nodes):
		map_data.completion[i] = 0
	get_tree().quit() #quits the game rn
	
