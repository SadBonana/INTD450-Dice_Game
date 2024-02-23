extends Resource

class_name map_resource

@export var completion = []
@export var num_nodes = 0

func _init():
	#var map = preload("res://map/map_gen_v2.gd")
	#for index in range(map.nodes):
	#	completion.append(0)
	completion = [0,0,0,0,0]
