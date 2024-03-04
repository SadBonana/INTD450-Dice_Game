extends Node

class_name MapTree

#constants
const NT = NodeType.NodeType
const d = 6
const b = [0,3]
const paths = 4     #number of complete paths in the game

#tree functionality
var leafnodes = []
var num_nodes #?
var root
var end

#front-end probabilities
#these are the expected chances of getting a room of this type
var camp_prob     = 0.0 #initialized at 0 until depth = 3
var wshop_prob    = 0.3
var battle_prob   = 0.7 #70% chance of selecting battle as first room
var treasure_prob = 0.0 #initialized at 0 until depth = 3
#var elite_prob
#var rand_enc_prob 

func _init():
	root = MapNode.new()
	root.set_depth(0)
	root.set_type(NT.START)
	num_nodes += 1
	
	dfg(root,1)
	
	end = MapNode.new()
	end.set_depth(d+1)
	end.set_type(NT.BOSS)
	
	for leafnode in leafnodes:
		leafnode.add_son(end)
	

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

func random_type(prev:MapNode, depth:int) -> NT:
	
	if depth == 3:           #only want this to run once, at depth=3
		camp_prob = 0.15     #i.e., chance for node 3 in a path of being a campfire is 15%
		wshop_prob = 0.25    # 25%
		battle_prob = 0.50   # 50%
		treasure_prob = 0.10 # 10%

	var fin = false
	var selection = NT.ERROR   #if error is returned something went wrong
	
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
				if prev.type != NT.CAMPFIRE: #if campfire was previous selection then skip
					if camp_prob > 0.06:     #otherwise, proceed same as for battle
						battle_prob     += 0.02
						camp_prob       -= 0.06
						wshop_prob      += 0.02
						treasure_prob   += 0.02
					fin = true

			NT.WORKSHOP:                     #same as before
				if prev.type != NT.WORKSHOP:
					if wshop_prob > 0.06:
						battle_prob     += 0.02
						camp_prob       += 0.02
						wshop_prob      -= 0.06
						treasure_prob   += 0.02
					fin = true

			NT.TREASURE:                     #same as before
				if treasure_prob > 0.06:
					battle_prob     += 0.02
					wshop_prob      += 0.02
					camp_prob       += 0.02
					treasure_prob   -= 0.06
				fin = true
	return selection

#"depth-first" generation
func dfg(prev:MapNode, depth:int=0):
	'''
	Depth-first generation is designed to work similarly to DFS, where we generate a complete 
	path of the game before generating side branches. We will run this as many times as there
	are "starting" paths on the tree.
	'''
	
	if depth > d:   #just in case base case
		return
	
	num_nodes += 1  #we always add at least one node so this is safe
	
	'''
	commented out because this won't properly link all paths to one final boss, and will
	instead create # of paths bosses at the end of each path
	if depth == d:  #base case
		var end = MapNode.new() #new MapNode
		end.set_type(NT.BOSS)   #set type to be boss
		end.set_depth(depth)    #set the depth
		prev.add_son(end)       #add the new node as a child of the previous one
		return
	'''
	
	#if depth == d-1:
	if depth == d:    #adjust d if you want to add a boss at the end or not
		var node = MapNode.new()
		node.set_type(NT.CAMPFIRE) #set new node as a campfire
		node.set_depth(depth)      #set node depth
		prev.add_son(node)         #set node as child of previous node
		leafnodes.append(node)     #add node to leafnodes
		#dfg(node,depth+1)
		return
	var node = MapNode.new()
	
	#biased random selection of NodeType
	var selection = random_type(prev,depth)
	
	node.set_type(selection)
	node.set_depth(depth)
	prev.add_son(node)
	'''
	var shop_count = wshops
	var camp_count = camps
	var treasure_count = treasure
	
	if selection == NT.WORKSHOP:
		shop_count += 1
	if selection == NT.CAMPFIRE:
		camp_count += 1
	if selection == NT.TREASURE:
		treasure_count += 1
	'''
	dfg(node,depth+1)
	return
	
func populate():
	#this function will populate the rest of the tree
	pass
		
	
