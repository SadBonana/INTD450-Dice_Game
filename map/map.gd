extends Node

const NT = NodeType.NodeType

var map
const margin = 5
var points = []

func _init():
	map = MapTree.new()
	#print(map.map_nodes[0].type)
	
	# Setup stuff that lets you scroll the map.
	var scroll_cont = ScrollContainer.new()
	scroll_cont.custom_minimum_size = Vector2(640, 360)
	add_child(scroll_cont)
	
	# Setup the map background
	var bg = TextureRect.new()
	bg.custom_minimum_size = Vector2(640, 1080)
	bg.texture = load("res://icon.svg")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	scroll_cont.add_child(bg)
	
	# Draw Lines
	var margins = Vector2(map.margin, 0)
	bg.draw.connect(func ():
		for con in map.connections:
			bg.draw_line(con[0] + margins, con[1] + margins, Color.RED, 2)
		)
	
	# Add nodes to map
	for node in map.map_nodes:
		if node != null: #and node.type != NT.ERROR:
			#print("Node:",node)
			#print("pos:",node.position)
			#print("parents:",node.get_parents())
			#print("children:",node.get_sons())
			#print("type:",node.type)
			#print("depth:",node.depth)
			node.text = str(node.type)
			bg.add_child(node)
	'''
	var i = 0
	for position in map.map_array:
		var node = Node2D.new()
		node.set_position(position) #= position
		node.set_name("node" + str(i))
		points.append(node)
		add_child(node)
		i += 1
	'''
'''
func _draw():
	
	#for position in map.positions:
		#draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
	for node in map.map_nodes:
		if node != null:
			node.draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
		#print(point.position)
		
	
	for connection in map.connections:
		connection[0].draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
		var line = connection[1].position - connection[0].position
		var normal = line.normalized()
		line -= margin * normal
		var colour = Color.BLACK
		connection[0].draw_line(normal*margin, line, colour, 2, true)
	'''

