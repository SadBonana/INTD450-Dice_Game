extends Node

class_name MapTree

#constants
const NT = NodeType.NodeType #defining NT so that we can shortcut nodetypes
const d = 8       #depth limit on tree generation
const b_lower = 0 #lower limit on number of branches
const b_upper = 3 #upper limit on number of branches
const num_paths = 4 #number of complete paths in the game

const tile_size = 32 * 3 #96x96 space to allow randomized positions for tiles. Tile icons are 32x32.
const margin = 40    #generic margin for the side of our screen so we have space for UI

const screen_width =  640 #pixels wide
const screen_height = 720 #pixels tall

#tree functionality
var leafnodes = [] #track leafnodes so we can connect to boss
var num_nodes = 2  #for start and end
var root           #"start" room, also root of our map tree
var end            #"boss" room

#map data
var map_width = 6  #how many columns in the map grid
var map_height = 8 #how many rows in the map grid
var map_array = range(map_width*map_height) #initializing an array to hold the map positions
var connections = [] #array for connections
var positions = []   #binary array showing which positions are "active"

var map_nodes = []   #array of MapNodes 

#front-end probabilities
#these are the expected chances of getting a room of this type
var camp_prob     = 0.0 #initialized at 0 until depth = 3
var wshop_prob    = 0.3
var battle_prob   = 0.7 #70% chance of selecting battle as first room
var treasure_prob = 0.0 #initialized at 0 until depth = 3
#var elite_prob
#var rand_enc_prob 

func _init():
	'''
	Overloading the _init function to initialize our MapTree
	Parameters:
		None
	Returns:
		None
	'''
	positions.resize(map_array.size()) #set the positions array to have the same size as map_array
	positions.fill(0)                  #fill positions with 0
	
	map_nodes.resize(map_array.size()) #same as for positions
	map_nodes.fill(null)               #initialize map_nodes with null values
	init_grid()                        #initialize the grid
	
	#add the start position to the map_array
	map_array.push_front(Vector2((screen_width - 2*margin) / 2, margin))
	
	#create a new MapNode for the starting room
	root = MapNode.new()
	root.set_depth(0)
	root.set_type(NT.START)
	root.position = map_array[0] #set the position
	
	#randomly select the start nodes
	var path_starts = select_starts()
	
	for start in path_starts: #creating each path
		#grabbing the start index
		var start_index = pos_to_index((start.x - margin) / tile_size,(start.y - margin) / tile_size)
		
		#adding a connection from the root to each path start
		add_connection(root.position,map_array[start_index])

		#generate a path for that start
		generate(start,1)
	
	#initialize the map_nodes array with MapNodes at each active position
	init_nodes()
	
	#for each path start, add the path start as a node
	for start in path_starts: #creating each path
		var start_node = add_node(root,start,1)
	
	#add all the other nodes
	add_nodes()
	set_types()
	
	#insert the root at the front
	map_nodes.push_front(root)
	
	#insert the root position at the front as active
	positions.push_front(1)
	
	#adding the boss position to the map_array
	var leafnode_y = leafnodes[0].position.y
	map_array.push_back(Vector2((screen_width - 2*margin) / 2, leafnode_y + tile_size))
	
	#create the end node (boss)
	end = MapNode.new()
	end.set_depth(d+1) 
	end.set_type(NT.BOSS)
	end.position = map_array[map_array.size() - 1]
	
	#put the boss at the end of the array
	map_nodes.push_back(end)
	
	#put an active position at the back of the array for the boss
	positions.push_back(1)
	
	#for each leafnode, we connect to the boss
	for leafnode in leafnodes:
		add_connection(leafnode.position,end.position)
		leafnode.add_son(end) 
	
	centre_points() #centring points on the map
	#randomize_positions()

#we use a 1D array to represent a 2D array, so we use some clever indexing
func pos_to_index(col:int,row:int) -> int:
	'''
	This function will convert row and column positions of a point into an index
	in the map_array, position, and map_nodes arrays.
	Parameters:
		row (int): the current row value 
		col (int): the current column value
	Returns:
		index (int): index in map_array, position, or map_nodes
	'''
	return col + map_width*row

#this will give the depth of a position IN THE TREE
#this WILL NOT GIVE THE Y-VALUE OF A POSITION
func pos_to_depth(y:int) -> int:
	'''
	This function will convert a y-position to a tree-depth.
	Parameters:
		y (int): y-value of the position
	Returns:
		depth (int): depth in the tree of this node
	'''
	return (y - margin) / tile_size + 1

#This function is unused currently
func pos_to_width(x:int) -> int:
	'''
	This function will convert an x-position to the position in the tree.
	Parameters:
		x (int): the x-value of the position
	Returns:
		row/col (int): Not sure which it returns honestly
	'''
	return (x - margin) / tile_size

#converting from index back to position
func index_to_pos(index:int):
	'''
	This function will convert a given index in map_array, map_nodes, or positions to 
	a position in the map space.
	Parameters:
		index (int): position in the array
	Returns:
		pos (int): the position in the map space. Value -1,-1 used for error checking
	'''
	for col in range(0,map_width):
		for row in range(0,map_height):
			#checking if this combination of rows and cols gives the position we want
			if col + map_width*row == index:
				return Vector2(col,row)
	#position not found, return -1,-1
	return Vector2(-1,-1)

func init_grid():
	'''
	This function is designed to initialize the map_array with every possible position
	in our grid.
	Parameters:
		None
	Returns:
		None
	'''
	for col in range(0,map_width):
		for row in range(0,map_height):
			#getting the index so we can properly update map_array
			var index = pos_to_index(col,row)
			var start_height = margin + tile_size
			
			#initialize position at that index
			map_array[index] = Vector2(col * tile_size + margin, row * tile_size + start_height)

func select_starts() -> Array:
	'''
	This function is designed to randomly select starting positions at depth = 1.
	Parameters:
		None
	Returns:
		starts: array of starting positions
	'''
	#array of starting positions
	var starts = []
	
	#grab possible starting positions from the map_array
	var possible_starts = map_array.slice(1,map_width)
	
	#for each path
	for path in num_paths:
		#randomly select an index
		var start_index = randi_range(0,possible_starts.size()-1)
		
		#at that index in possible_starts, pop the value (remove and return)
		var start = possible_starts.pop_at(start_index)
		
		#convert that starting position into an index for our array
		var index = pos_to_index((start.x - margin) / tile_size,(start.y - margin) / tile_size)
		
		#set that position to active
		positions[index] = 1
		
		#add the starting postion that was selected to the starts array
		starts.append(start)
	return starts

func select() -> NT:
	'''
	This function will properly set up the conditional for random selection and then
	will randomly select a NodeType.
	Parameters:
		None
	Returns:
		select (NT): A random selection of NodeType
	'''
	#back-end probabilities for making the conditional work
	var battle_prob_b = battle_prob
	var wshop_prob_b = wshop_prob + battle_prob_b
	var camp_prob_b = camp_prob + wshop_prob_b
	var treasure_prob_b = treasure_prob  + camp_prob_b
	
	var select
	
	#random generation
	var random_float = randf()
	
	if random_float < battle_prob_b: # chance of random float < battle_prob_b is battle_prob*100%
		select = NT.BATTLE
		
	elif random_float < wshop_prob_b:# chance of float < wshop_prob_b is wshop_prob*100%
		select = NT.WORKSHOP
		
	elif random_float < camp_prob_b: # camp_prob*100%
		select = NT.CAMPFIRE
		
	elif random_float < treasure_prob_b: #treasure_prob*100%
		select = NT.TREASURE
		
	return select

#func select_type(prev:NT, depth:int) -> NT:
func select_type(node:MapNode) -> NT:
	'''
	This function will adjust the probabilities of getting each NodeType before randomly
	selecting a NodeType.
	Parameters:
		prev (NT): the last generated node's type. Used to adjust probabilities and to 
				prevent repeat generation
		depth (int): the depth of the node in the tree
	Returns:
		selection (NT): the selected type for the current node 
	'''
	var selection = NT.ERROR   #if error is returned something went wrong
	var depth = node.depth
	var prevent_double = false
	
	for parent in node.get_parents():
		if (parent.get_type() == NT.CAMPFIRE or 
				parent.get_type() == NT.WORKSHOP or 
				parent.get_type() == NT.TREASURE):
					prevent_double = true
	
	#if depth is 1 then set type to BATTLE
	if depth == 1:
		return NT.BATTLE
	
	if depth == 3:           #only want this to run once, at depth=3 to increase probs
		camp_prob = 0.15     #i.e., chance for node 3 in a path of being a campfire is 15%
		wshop_prob = 0.25    # 25%
		battle_prob = 0.50   # 50%
		treasure_prob = 0.10 # 10%
	
	#hardcode depth 4 as treasure, we dont have to do this
	if depth == 4:
		return NT.TREASURE
	
	#hardcode depth 6 as workshop
	if depth == 6:
		return NT.WORKSHOP
	
	#if depth is d then its a leafnode, and all leafnodes are rest sites
	if depth == d:
		return NT.CAMPFIRE
	
	#initialize finished selection as false
	var fin = false

	while !fin:                #preventing selecting campfires and workshops multiple times in a row
		#randomly select a type
		selection = select()
		
		#match = switch-case in other languages
		match selection:
			NT.BATTLE:         #if battle selected
				if battle_prob > 0.06: #if current chance for battle > 6%
					battle_prob     -= 0.06 #reduce battle_prob by 6%
					camp_prob       += 0.02 #increase other probs by 2%
					wshop_prob      += 0.02
					treasure_prob   += 0.02		
				fin = true	                #selection successful so stop
						
			NT.CAMPFIRE:
				#if campfire was previous selection then skip
				#also skip if the depth is d-1 since d is hardcoded to be campfires
				if not prevent_double and depth != d-1:
					if camp_prob > 0.06:     #otherwise, proceed same as for battle
						battle_prob     += 0.02
						camp_prob       -= 0.06
						wshop_prob      += 0.02
						treasure_prob   += 0.02
					fin = true

			NT.WORKSHOP:                     #same as before
				if not prevent_double:
					if wshop_prob > 0.06:
						battle_prob     += 0.02
						camp_prob       += 0.02
						wshop_prob      -= 0.06
						treasure_prob   += 0.02
					fin = true

			NT.TREASURE:                     #same as before
				if not prevent_double:
					if treasure_prob > 0.06:
						battle_prob     += 0.02
						wshop_prob      += 0.02
						camp_prob       += 0.02
						treasure_prob   -= 0.06
					fin = true
	return selection

func generate(prev:Vector2, depth:int) -> void:
	'''
	This function will generate a tree.
	Parameters:
		prev (Vector2): a position in the grid of the previous node.
		depth (int): the depth of the current node
	Returns:
		None
	'''
	#Just in case somehow we get depth > d
	if depth >= d: #if depth is d then we stop generating children
		return
	
	var children = []
	
	#get the points for the possible children of prev
	var p1 = Vector2(prev.x-tile_size,prev.y+tile_size)
	var p2 = Vector2(prev.x, prev.y + tile_size)
	var p3 = Vector2(prev.x + tile_size, prev.y + tile_size)
	
	#initialize the min and max widths/heights for the grid
	#index 0 is the min, index 1 is the max
	var grid_width = [ 0 + margin ,map_width * tile_size]
	var grid_height = [0 + margin, map_height * tile_size]
	
	#if (p1.x > 0 + margin and p1.x < screen_width - margin and 
	#		p1.y > 0 + margin and p1.y < screen_height - margin):
	#if position is within the boundaries, then add to children array
	if (p1.x >= grid_width[0] and p1.x < grid_width[1] and
			p1.y > grid_height[0] and p1.y < grid_height[1]):
		children.append(p1)
		
	#if (p2.x > 0 + margin and p2.x < screen_width - margin and 
	#		p2.y > 0 + margin and p2.y < screen_height - margin):
	#same as for p1
	if (p2.x >= grid_width[0] and p2.x < grid_width[1] and
			p2.y > grid_height[0] and p2.y < grid_height[1]):
		children.append(p2)
		
	#if (p3.x > 0 + margin and p3.x < screen_width - margin and 
	#		p3.y > 0 + margin and p3.y < screen_height - margin):
	#same as for p1
	if (p3.x >= grid_width[0] and p3.x < grid_width[1] and
			p3.y > grid_height[0] and p3.y < grid_height[1]):
		children.append(p3)
	
	#randomly select the number of paths (the number of children)
	var paths = randi_range(1,children.size())
	
	#print("Children points: ", children)
	
	#for each path
	for path in paths:
		var done = false
		while not done:
				
			#randomly select WHICH child we are pathing to
			var child_index = randi_range(0,children.size()-1)

			#when we select the child we path to, we remove that child 
			#this way if we randomly generate 2 paths, we don't select the same child for each
			var child = children.pop_at(child_index)
			
			#if there was no child
			if not child:
				return #stop generating
			
			#otherwise, find the index of the child in the various arrays
			var index = pos_to_index((child.x - margin) / tile_size,(child.y - margin) / tile_size)
			
			#add a connection between parent and child
			if not check_connections(prev,child):
				done = true
				add_connection(prev,child)
				
				#activate the child
				positions[index] = 1
				
				#recursive call to generate more children
				generate(child, depth + 1)

func add_connection(start:Vector2, end:Vector2) -> void:
	'''
	This function will add a connection between two positions to the connections array.
	Parameters:
		start (Vector2): the start position of the connection (parent)
		end (Vector2): the end position of the connection (child)
	Returns:
		None
	'''
	
	#recently added. Should check if the line will intersect and return if it will
	#if check_connections(start,end):
	#	return
	
	#init connection as an array with start and end
	var connection = [start,end]
	
	#add connection to connections
	connections.append(connection)

func check_connections(current_pos:Vector2, dest_pos:Vector2) -> bool:
	'''
	This function will check whether or not there is an existing path that would
	intersect with the one we are trying to make. 
	Parameters:
		current_pos (Vector2): the "start" of the connection we want to make
		dest_pos (Vector2): the destination position of the end of the path we want to make
	Returns:
		(bool): true if a conflicting connection already exists, false otherwise
	'''
	#var offset_current = (current_pos.x - margin) / tile_size #accounting for pixel width and margins
	#we don't offset y because it we don't need to
	#var offset_dest = (dest_pos.x - margin) / tile_size
	
	#for each existing connection in connections
	
	for connection in connections:
		var start = connection[0]
		var end = connection[1]
		#we use greater than or equal to account for connected nodes below ours
		if end.y == dest_pos.y and end.x == dest_pos.x - tile_size:
			if start.x == current_pos.x + tile_size and start.y == current_pos.y:
				return true
				
		if end.y == dest_pos.y and end.x == dest_pos.x + tile_size:
			if start.x == current_pos.x - tile_size and start.y == current_pos.y:
				return true
	return false


func init_nodes():
	#print(positions)
	for index in range(positions.size()):
		if positions[index] == 1:
			var node = MapNode.new()
			node.name = "node: " + str(index)
			map_nodes[index] = node

func add_nodes() -> void:
	'''
	This function is designed to add MapNodes to the map at every position.
	Parameters:
		None
	Returns:
		None
	'''
	for connection in connections:
		var start = connection[0]
		var end = connection[1]
		if start != root.position:
			var index = pos_to_index((start.x - margin) / tile_size,(start.y - margin) / tile_size)
			var prev = map_nodes[index]
			var depth = pos_to_depth(end.y)
			
			add_node(prev,end,depth)
		
	
func add_node(prev:MapNode, pos: Vector2, depth:int) -> MapNode:
	'''
	This function is designed to add a MapNode at the designated position.
	Parameters:
		prev (MapNode) - The previous node added. AKA the parent of this node.
		pos (Vector2)  - The position of the node being added.
		depth (int)    - The depth of the node.
	Returns:
		node (MapNode) - reference to the node that was added.
	'''
	#var point = index_to_pos(pos)
	#var node = MapNode.new()
	
	var index = pos_to_index((pos.x - margin) / tile_size,(pos.y - margin) / tile_size)
	var node = map_nodes[index]
	
	if node == null:
		return
			
	node.position = pos
	node.set_depth(depth)
	
	if depth == d:
		leafnodes.append(node)

	prev.add_son(node)
	num_nodes += 1
	return node

func set_types() -> void:
	for node in map_nodes:
		if node != null:
			var select = select_type(node)
			node.set_type(select)
	return

func centre_points() -> void:
	'''
	This function is designed to centre the grid properly on the screen.
	Parameters:
		None
	Returns:
		None
	'''
	var grid_width = map_width * tile_size
	var mid = screen_width / 2
	var offset = mid - (grid_width / 2)
	#var grid_height = [0 + margin, map_height * tile_size]
	for index in range(map_array.size()):
		map_array[index].x = map_array[index].x + offset
		
		var node = map_nodes[index]
		if node != null:
			node.position.x = node.position.x + offset

func randomize_positions() -> void:
	for index in range(map_array.size()):
		var offset_x = randi_range(-24,24)
		var offset_y = randi_range(-16,16)
		
		#TODO: make sure the change is within bounds
		#initialize the min and max widths/heights for the grid
		#index 0 is the min, index 1 is the max
		var grid_width = [ 0 + margin ,map_width * tile_size]
		var grid_height = [0 + margin, map_height * tile_size]
		
		var rand_pos = Vector2(map_array[index].x + offset_y,map_array[index].y + offset_y )
		
		var grid_size = map_width * tile_size
		var mid = screen_width / 2
		var uncentre = mid - (grid_size / 2)
		var p = Vector2(rand_pos.x - uncentre,rand_pos.y)
		
		if (p.x >= grid_width[0] and p.x < grid_width[1] and
				p.y > grid_height[0] and p.y < grid_height[1]):
		
			#map_array[index].x = rand_pos.x
			#map_array[index].y = map_array[index].y + offset_y
			map_array[index] = rand_pos
			
			var node = map_nodes[index]
			if node != null:
				#node.position.x = node.position.x + offset_x
				#node.position.y = node.position.y + offset_y
				node.position = rand_pos

