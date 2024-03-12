extends Node

var map
const margin = 5
var points = []

func _init():
	map = MapTree.new()
	print(map.positions)
	#print(map.connections)
	#print(map.map_array)
	var i = 0
	for position in map.map_array:
		var node = Node2D.new()
		node.set_position(position) #= position
		node.set_name("node" + str(i))
		points.append(node)
		add_child(node)
		i += 1
		
	#var start = Node2D.new()
	#start.position = map.connections[0][0]
	#points.push_front(start)
		
	
func _draw():
	#for position in map.positions:
		#draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
	for point in points:
		point.draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
		#print(point.position)
	'''
	for connection in map.connections:
		connection[0].draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
		var line = connection[1].position - connection[0].position
		var normal = line.normalized()
		line -= margin * normal
		var colour = Color.BLACK
		connection[0].draw_line(normal*margin, line, colour, 2, true)
	'''
