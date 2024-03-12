extends Control

@export var map_data : map_resource

@export_file('*.tscn') var battle_path: String
@export_file('*.tscn') var campfire_path: String

'''
@onready var start_button := %battle1
@onready var battle_button := %battle2
@onready var campfire_button := %campfire
@onready var boss_button := %boss
'''
# initializing node variables, any additional nodes will need to be added here
# eventually will need to do this in an _init func with a loop.
# the null value gets replaced with reference to the node, the first value is that nodes index in completion
'''
var battle1 =    ["battle1",[0, null]]
var battle2 =    ["battle2",[1, null]]
var campfire1 =  ["campfire1",[2, null]]
var battle3 =    ["battle3",[3, null]]
var battle4 =    ["battle4",[4, null]]
var campfire2 =  ["campfire2",[5, null]]
var battle5 =    ["battle5",[6, null]]
var campfire3 =  ["campfire3",[7, null]]
var battle6 =    ["battle6",[8, null]]
#var root =     [4, null]
'''
var nodes = [
	["battle1",  0, null],
	["battle2",  1, null],
	["campfire1",2, null],
	["battle3",  3, null],
	["battle4",  4, null],
	["campfire2",5, null],
	["battle5",  6, null],
	["campfire3",7, null],
	["battle6",  8, null],
]
enum {START, BATTLE, CAMPFIRE, TREASURE, SMITH, BOSS}

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
		if map_data.completion.size() > 0:
			map_data.completion[i] = int(map_save.get_line())
		else:
			map_data.completion.append(int(map_save.get_line()))
	map_save.close() #close the file
		

func process(id, dest=null):
	nodes[id][2].disabled = true
	map_data.completion[nodes[id][1]] = 1
	nodes[id+1][1].disabled = false
	map_save()
	#get_tree().change_scene_to_file("res://battle.tscn") #switch to battle scene
	if dest == BATTLE:
		get_tree().change_scene_to_file(battle_path) #switch to battle battle_path scene
	
	if dest == CAMPFIRE:
		get_tree().change_scene_to_file(campfire_path)
	
	if dest == SMITH:
		pass
	
	if dest == TREASURE:
		pass
	
	if dest == BOSS:
		pass

func _ready():
	#map_data = map_data_load.new()
	#map_data = ResourceLoader.load("user://map/map_resource.tres")
	return #killing this script from running
	map_load()
	print(map_data.completion) #check save state
	var path1 = "PanelContainer/MarginContainer/VBoxContainer/"
	var path2 = "PanelContainer/MarginContainer/VBoxContainer2/"
	for i in range(nodes.size()):
		var path = ""
		if i < 4:
			path = path1
		else:
			path = path2
		nodes[i][2] = get_node(str(path,nodes[i][0])) #get the node from the tree and replace null in nodes[i]
	'''
	for i in range(nodes.size()):
		if map_data.completion[nodes[i][1]] == 1: #check completion at index in nodes[i]
			nodes[i][2].disabled = true
			
		if i > 0: #if not the starting node
			if map_data.completion[nodes[i-1][1]] == 0: #check completion at prior node
				nodes[i][2].disabled = true
	'''

func _on_quit_pressed():
	for i in range(map_data.num_nodes):
		map_data.completion[i] = 0 #resetting the save state to the initial one
	map_save()
		#we will likely need a more nuanced reset in the future, but this works for now.
	get_tree().quit() #quits the game rn
	
func _on_battle_1_pressed():
	process(0,BATTLE)

func _on_battle_2_pressed():
	process(1,BATTLE)

func _on_campfire_1_pressed():
	process(2,CAMPFIRE)
	
func _on_battle_3_pressed():
	process(3,BATTLE)

func _on_battle_4_pressed():
	process(4,BATTLE)

func _on_campfire_2_pressed():
	process(5,CAMPFIRE)
	
func _on_battle_5_pressed():
	process(6,BATTLE)

func _on_campfire_3_pressed():
	process(7,CAMPFIRE)

func _on_battle_6_pressed():
	process(8,BATTLE)


