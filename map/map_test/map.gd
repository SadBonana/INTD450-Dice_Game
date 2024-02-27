extends Node2D

const plane_len = 30
const point_count = (plane_len ** 2)/12 
const path_count = 12

const map_scale = 20.0

var events = {}
var event_scene = preload("res://map/map_test/event.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var map_generator = preload("res://map/map_test/map_gen.gd")
	var generator = map_generator.new()
	var map_data = generator.generate(plane_len, point_count, path_count)
	
	for k in map_data.nodes.keys():
		var point = map_data.nodes[k]
		var event = event_scene.instance()
		event.position = point * map_scale + Vector2(200,0)
		add_child(event)
		events[k] = event
			
	for path in map_data.paths:
		for i in range(path.size() - 1):
			var index = path[i]
			var child_index = path[i+1]
			
			events[index].add_child_event(events[child_index])
	 
