extends Button

class_name MapNode

var id        = 0      #supposed to be index in complete array but might be useless now
#var type_str  = null  #honestly not sure what i was cookin with this
var type      = null   #type of this node
var dest_path = null   #destination path to a specific scene
var children  = []     
var parents   = []
var depth     = 0      #depth of this node in the tree, idk if it's necessary for each node yet

#func _init():
#	self.disabled = true

#initialize the MapNode with it's destination typing
#then find the path to that scene and store it
func _init(_type:NodeType, _depth:int):
	
	self.disabled = true #disable all buttons initially

	#handle different node types
	match _type:
		NodeType.START:
			self.disabled = false
		NodeType.BATTLE:
			pass
		NodeType.CAMPFIRE:
			pass
		NodeType.WORKSHOP:
			pass
		NodeType.TREASURE:
			pass
		NodeType.BOSS:
			pass

#set the parents of this node
func set_parents(_parents:Array[MapNode]=[]) -> void:
	for parent in _parents:
		add_parent(parent)

#add a single parent for this node
func add_parent(parent:MapNode) -> void:
	if parent != null:
		self.parents.append(parent)

#get the array of parents
func get_parents() -> Array[MapNode]:
	return self.parents

#add a child to the children array
#named add_son to avoid name-clashing with built-in add_child()
func add_son(child:MapNode) -> void:
	self.children.append(child)
	child.set_parent(self)

#get the array of children. 
#func is called get_sons to avoid name-clashing with built-in get_children()
func get_sons():
	return self.children

#handler for pressing the button
func _pressed():
	self.disabled = true
	for child in children:
		child.disabled = false
	get_tree().change_scene_to_file(dest_path)
	
