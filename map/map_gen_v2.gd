extends Node

const d = 6
const b = [0,3]
var leafnodes = []

func populate(path,root,depth,max_d):
	var node = root
	for d in range(depth,max_d):
		var num_children = randi_range(1,3)
	
		for c in range(num_children):
			var child = path.create_item(node)
			populate(path,child,depth+1,max_d)
			if depth == max_d:
				leafnodes.append(child)
	return path

func _ready():
	var path1 = Tree.new()
	var path1_root = path1.create_item()
	
	path1 = populate(path1,path1_root,0,d-1)
	#need to set every child at depth d-1 to be a specific child
	leafnodes = path1.get_children()
	for child in leafnodes:
		var end_child = path1.create_item(child)

