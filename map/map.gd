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
	#var margins = Vector2(map.margin, 0)
	var margins = Vector2(8,16)
	bg.draw.connect(func ():
		#for con in map.connections:
		#TODO: we might wanna change this back to what sean had previously in the final version
		for node in map.map_nodes:
			if node != null:
				for child in node.get_sons():
					if node.type != NT.ERROR:
						bg.draw_line(node.position + margins, child.position + margins, Color.RED, 2)
					else:
						bg.draw_line(node.position + margins, child.position + margins, Color.HOT_PINK, 2)
		)
	
	# Add nodes to map
	var index = 0
	for node in map.map_nodes:
		if node != null: #and node.type != NT.ERROR:
			if node.type == NT.ERROR:
				#print("Positions: ",map.positions)
				print("Node Position: ", node.position)
				#print("Map Array: ", map.map_array)
				#print("Map Nodes: ", map.map_nodes)
				print("Error Node: ", node)
				print("index: ", index)
				print("Correct Pos: ", map.map_array[index])
				print("Active? : ", map.positions[index])
				print("correct depth: ", map.pos_to_depth(map.map_array[index].y))
				if node.children.size() > 0:
					print("has children")
				
				var grid_width = [ 40 ,6 * 32]
				var grid_height = [40 , 8 * 32]
				
				print("\ngrid_width: ",grid_width)
				print("grid_height: ", grid_height)
				print("")
				
				var p1 = map.map_array[index]
				var grid_w = 6 * 32
				var mid = 640 / 2
				var offset = mid - (grid_w / 2)
				#var grid_height = [0 + margin, map_height * tile_size]
				p1.x = p1.x - offset
				print("position after change: ", p1)
				
				if (p1.x > grid_width[0] and p1.x < grid_width[1] and
					p1.y > grid_height[0] and p1.y < grid_height[1]):
						print("within bounds")
				else:
					print("outside bounds")
				pass
			#print("Node:",node)
			#print("pos:",node.position)
			#print("parents:",node.get_parents())
			#print("children:",node.get_sons())
			#print("type:",node.type)
			#print("depth:",node.depth)
			node.text = str(node.type)
			bg.add_child(node)
		index += 1
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

