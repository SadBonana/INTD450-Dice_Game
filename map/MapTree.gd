extends Node

class_name MapTree

#constants
const NT = NodeType.NodeType
const d = 8
const b_lower = 0 #lower limit on number of branches
const b_upper = 3 #upper limit on number of branches
const num_paths = 4 #number of complete paths in the game

#const tile_width = 32 #width and height of a square on our grid
#const tile_height = 32
const tile_size = 32
const margin = 20

const screen_width =  640 #640 pixels wide
const screen_height = 360 #360 pixels tall

#tree functionality
#idk if this is still needed
var leafnodes = []
var num_nodes #?
var root
var end

#map data
var map_width = 6
var map_height = 8
var map_array = range(map_width*map_height + 1)
var connections = []
var positions = []

#front-end probabilities
#these are the expected chances of getting a room of this type
var camp_prob     = 0.0 #initialized at 0 until depth = 3
var wshop_prob    = 0.3
var battle_prob   = 0.7 #70% chance of selecting battle as first room
var treasure_prob = 0.0 #initialized at 0 until depth = 3
#var elite_prob
#var rand_enc_prob 

func _init():
	
	positions.resize(map_array.size())
	positions.fill(0)
	
	init_grid()
	map_array.push_front(Vector2(screen_width/2, margin))
	map_array.push_back(Vector2(screen_width / 2, screen_height - margin))
	
	root = MapNode.new()
	root.set_depth(0)
	root.set_type(NT.START)
	root.position = map_array[0]
	#positions.append(root.position)
	positions[0] = 1
	#num_nodes += 1
	
	var path_starts = select_starts()
	assert(path_starts.size() != 0)
	
	for start in path_starts: #creating each path
		add_connection(root.position,map_array[start])
		generate(start,1)
	
	end = MapNode.new()
	end.set_depth(d+1)
	end.set_type(NT.BOSS)
	end.position = map_array[map_array.size() - 1]
	#positions.append(end.position)
	positions[positions.size()-1] = 1
	
	for leafnode in leafnodes:
	#	leafnode.add_son(end) #linking each path to the boss
		add_connection(leafnode,end.position)
	
func pos_to_index(row:int,col:int) -> int:
	#var x = pos_to_width(col)
	#var y = pos_to_depth(row)
	#return x + map_width*y
	return col + map_width*row + 1

func pos_to_depth(y:int) -> int:
	return (y - margin) / tile_size

func pos_to_width(x:int) -> int:
	return (x - margin) / tile_size

func index_to_pos(index:int):
	for col in range(0,map_width):
		for row in range(0,map_height):
			if col + map_width*row + 1 == index:
				return [row,col]

func init_grid():
	#map_array[0] = Vector2(margin, screen_width / 2)
	#map_array.append(Vector2(screen_height - margin, screen_width / 2))
	for col in range(0,map_width):
		for row in range(0,map_height):
			var index = pos_to_index(row,col)
			map_array[index] = Vector2(row * tile_size + margin, col * tile_size + 2*margin)

func select_starts():
	var starts = []
	var possible_starts = map_array.slice(1,map_width)
	for path in num_paths:
		var start_index = randi_range(0,possible_starts.size()-1)
		var start = possible_starts.pop_at(start_index)
		#positions.append(start)
		var index = pos_to_index(start.y,start.x)
		positions[index] = 1
		starts.append(start)
	return starts

func select() -> NT:
	#back-end probabilities for making the conditional work
	var battle_prob_b = battle_prob
	var wshop_prob_b = wshop_prob + battle_prob_b
	var camp_prob_b = camp_prob + wshop_prob_b
	var treasure_prob_b = treasure_prob  + camp_prob_b
	
	var select
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

func random_type(prev:NT, depth:int) -> NT:
	var selection = NT.ERROR   #if error is returned something went wrong
	
	if depth == 3:           #only want this to run once, at depth=3
		camp_prob = 0.15     #i.e., chance for node 3 in a path of being a campfire is 15%
		wshop_prob = 0.25    # 25%
		battle_prob = 0.50   # 50%
		treasure_prob = 0.10 # 10%
	
	if depth == 4:
		selection = NT.TREASURE
	
	if depth == 6:
		selection = NT.WORKSHOP
		
	if depth == d:
		selection = NT.CAMPFIRE

	var fin = false

	while !fin:                #preventing selecting campfires and workshops multiple times in a row
		selection = select()
		match selection:
			NT.BATTLE:         #if battle selected
				if battle_prob > 0.06: #if current chance for battle > 6%
					battle_prob     -= 0.06 #reduce battle_prob by 6%
					camp_prob       += 0.02 #increase other probs by 2%
					wshop_prob      += 0.02
					treasure_prob   += 0.02		
				fin = true	                #selection successful so stop
						
			NT.CAMPFIRE:
				if prev != NT.CAMPFIRE: #if campfire was previous selection then skip
					if camp_prob > 0.06:     #otherwise, proceed same as for battle
						battle_prob     += 0.02
						camp_prob       -= 0.06
						wshop_prob      += 0.02
						treasure_prob   += 0.02
					fin = true

			NT.WORKSHOP:                     #same as before
				if prev != NT.WORKSHOP:
					if wshop_prob > 0.06:
						battle_prob     += 0.02
						camp_prob       += 0.02
						wshop_prob      -= 0.06
						treasure_prob   += 0.02
					fin = true

			NT.TREASURE:                     #same as before
				if prev != NT.TREASURE:
					if treasure_prob > 0.06:
						battle_prob     += 0.02
						wshop_prob      += 0.02
						camp_prob       += 0.02
						treasure_prob   -= 0.06
					fin = true
	return selection


#func generate(prev:MapNode, depth:int, branch:bool, pathID:int, branchID:int=1):
func generate(prev:Vector2, depth:int):
	
	if depth >= d:
		leafnodes.append(prev)
		return
	
	var children = []
	
	var p1 = Vector2(prev.x-tile_size,prev.y+tile_size)
	var p2 = Vector2(prev.x, prev.y + tile_size)
	var p3 = Vector2(prev.x + tile_size, prev.y + tile_size)
	
	if (p1.x > 0 + margin and p1.x < screen_width - margin and 
			p1.y > 0 + margin and p1.y < screen_height - margin):
		children.append(p1)
		
	if (p2.x > 0 + margin and p2.x < screen_width - margin and 
			p2.y > 0 + margin and p2.y < screen_height - margin):
		children.append(p2)
		
	if (p3.x > 0 + margin and p3.x < screen_width - margin and 
			p3.y > 0 + margin and p3.y < screen_height - margin):
		children.append(p3)
		
	var paths = randi_range(1,children.size())
	for path in paths:
		var child_index = randi_range(0,paths-1)
		var child = children.pop_at(child_index)
		#positions.append(child)
		var index = pos_to_index(child.y,child.x)
		positions[index] = 1
		
		#var connection = [prev,child]
		#connections.append(connection)
		add_connection(prev,child)
		generate(child,depth + 1)

func add_connection(start:Vector2, end:Vector2) -> void:
	var connection = [start,end]
	connections.append(connection)

func check_connections(current_pos:Vector2, dest_pos:Vector2) -> bool:
	#var offset_current = (current_pos.x - margin) / tile_size #accounting for pixel width and margins
	#we don't offset y because it we don't need to
	#var offset_dest = (dest_pos.x - margin) / tile_size
	for connection in connections:
		#we use greater than or equal to account for connected nodes below ours
		if connection[1].y == dest_pos.y and connection[1].x == dest_pos.x - tile_size:
			if connection[0].x == current_pos.x + tile_size and connection[0].y == current_pos.y:
				return true
				
		if connection[1].y == dest_pos.y and connection[1].x == dest_pos.x + tile_size:
			if connection[0].x == current_pos.x - tile_size and connection[0].y == current_pos.y:
				return true
	return false

func add_nodes():
	var prev = NT.START
	for pos in positions:
		if pos == 1:
			var point = index_to_pos(pos)
			var node = MapNode.new()
			node.position = point
			var depth = pos_to_depth(point.y)
			node.set_depth(depth)
			var selection = random_type(prev, depth)
			node.set_type(selection)
