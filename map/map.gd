extends Node

var map

func _init():
	map = MapTree.new()
	print(map.positions)
	print(map.connections)
	
	
func _draw():
	pass
