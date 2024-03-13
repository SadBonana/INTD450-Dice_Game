extends Button

class_name MapNode

#@export var early_game_encounter_table: BaseEncounter

const NT = NodeType.NodeType

var id        = 0      #supposed to be index in complete array but might be useless now
#var type_str  = null  #honestly not sure what i was cookin with this
var type      = NT.ERROR   #type of this node
var dest_path = null   #destination path to a specific scene
var children  = []     
var parents   = []
var depth     = 0      #depth of this node in the tree, idk if it's necessary for each node yet

#initialize the button as disabled
#_init is NOT enough to set up a MapNode, set_type and set_depth MUST be ran first
#before the button should be used, otherwise it will break things
func _init():
	self.disabled = true

#set the depth of this node
func set_depth(_depth:int):
	depth = _depth

#return the depth
func get_depth() -> int:
	return depth
	
#initialize the MapNode with it's destination typing
#then find the path to that scene and store it
func set_type(_type:NT) -> void:
	type = _type
	
	#handle different node types
	match _type:
		NT.START:
			self.disabled = false #all buttons start disabled, so if it's a "start" node, enable it
		NT.BATTLE:
			#dest_path = "res://battle/battle.tscn" #set path to battle scene
			pass
		NT.CAMPFIRE:
			dest_path = "res://campfire/campfire.tscn" #set path to rest scene
		NT.WORKSHOP:
			pass
		NT.TREASURE:
			pass
		NT.BOSS:
			pass

#return the type of the node
func get_type() -> NT:
	return type

#return the destination path
func get_dest() -> String:
	return dest_path

#set the parents of this node
func set_parents(_parents:Array[MapNode]=[]) -> void:
	for parent in _parents:
		add_parent(parent)

#add a single parent for this node
func add_parent(parent:MapNode) -> void:
	if parent != null:
		for existing in parents:
			if existing == parent:
				return
		self.parents.append(parent)

#get the array of parents
func get_parents() -> Array:
	return self.parents

#add a child to the children array
#named add_son to avoid name-clashing with built-in add_child()
func add_son(child:MapNode) -> void:
	if child != null:
		for existing in children:
				if existing == child:
					return

		self.children.append(child)
		child.add_parent(self)

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

'''
func _draw():
	draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
'''
