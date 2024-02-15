extends Node

var paths = []
var points = {}

#putting the generated paths and points into the map's data
func set_paths(paths, points) :
	self.paths = paths
	
	for path in paths:
		for id in path:
			self.points[id] = points[id]
