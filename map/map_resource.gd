extends Resource

class_name map_resource
#resource file for tracking map completion

@export var completion = []
@export var num_nodes = 9

func _init():
	#DO NOT DELETE!!!! THIS IS FOR FUTURE BUILD
	#var map = preload("res://map/map_gen_v2.gd")
	#for index in range(map.nodes):
	#	completion.append(0)
	for i in range(num_nodes):
		completion.append(0)
	#completion = [0,0,0,0,0,0,0,0,0]
