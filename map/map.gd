extends Control

@export var map_data : map_resource

@export_file('*.tscn') var battle_path: String
@export_file('*.tscn') var campfire_path: String

@onready var start_button := %start
@onready var battle_button := %battle
@onready var campfire_button := %campfire
@onready var boss_button := %boss

# initializing node variables, any additional nodes will need to be added here
# eventually will need to do this in an _init func with a loop.
# the null value gets replaced with reference to the node, the first value is that nodes index in completion
var start =    [0, null]
var battle =   [1, null]
var campfire = [2, null]
var boss =     [3, null]
var root =     [4, null]

func map_save():
	#map_save will save the completion of the map to a text file
	#opening the file
	var map_save = FileAccess.open("user://mapsave.save",FileAccess.WRITE)
	#var json_string = JSON.stringify(map_data.completion)
	#saving each index of completion as a separate line to the file
	for i in map_data.completion:
		var line = str(i)
		map_save.store_line(line)
	map_save.close() #closing the file
	
	
func map_load():
	#we want to run map_load each time the map opens, so if mapsave.save does not exist
	#we save the default completion state
	if not FileAccess.file_exists("user://mapsave.save"):
		map_save()
	
	#loading data
	var map_save = FileAccess.open("user://mapsave.save", FileAccess.READ)
	
	#for each node, we read a separate line from the file into the respective index in completion
	for i in range(map_data.num_nodes):
		map_data.completion[i] = int(map_save.get_line())
	map_save.close() #close the file
		

func _ready():
	#map_data = map_data_load.new()
	#map_data = ResourceLoader.load("user://map/map_resource.tres")
	map_load()
	print(map_data.completion) #check save state
	
	#following code should be self-explanatory
	#root[1] = get_node("/root")
	start[1] = start_button
	if map_data.completion[start[0]] == 1:
		start[1].disabled = true
	
	battle[1] = battle_button
	if map_data.completion[start[0]] == 0 or map_data.completion[battle[0]] == 1:
		battle[1].disabled = true
	
	campfire[1] = campfire_button
	
	if map_data.completion[battle[0]] == 0 or map_data.completion[campfire[0]] == 1:
		campfire[1].disabled = true
	
	boss[1] = boss_button
	if map_data.completion[campfire[0]] == 0:
		boss[1].disabled = true

func _on_start_pressed():
	#start is a placeholder rn, but we could use it for an initial starting room for the player
	start[1].disabled = true
	map_data.completion[start[0]] = 1
	battle[1].disabled = false
	map_save() #have to save every time a button is pressed if we are swapping scenes.

func _on_battle_pressed():
	#save()
	battle[1].disabled = true
	map_data.completion[battle[0]] = 1
	campfire[1].disabled = false
	map_save()
	#get_tree().change_scene_to_file("res://battle.tscn") #switch to battle scene
	get_tree().change_scene_to_file(battle_path) #switch to battle battle_path scene


func _on_campfire_pressed():
	#save()
	campfire[1].disabled = true
	map_data.completion[campfire[0]] = 1
	boss[1].disabled = false
	map_save()
	#get_tree().change_scene_to_file("res://UI/campfire.tscn") #switch to campfire scene
	get_tree().change_scene_to_file(campfire_path) #switch to campfire scene
	#pass


func _on_boss_pressed():
	boss[1].disabled = true
	map_data.completion[boss[0]] = 1
	map_save()
	#get_tree().change_scene_to_file("") insert path to boss scene here
	# TODO: make a boss encounter and make the scene use it.
	get_tree().change_scene_to_file(battle_path) #switch to battle battle_path scene
	#pass


func _on_quit_pressed():
	for i in range(map_data.num_nodes):
		map_data.completion[i] = 0 #resetting the save state to the initial one
	map_save()
		#we will likely need a more nuanced reset in the future, but this works for now.
	get_tree().quit() #quits the game rn
	
