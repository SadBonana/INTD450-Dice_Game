extends ScrollContainer

const NT = NodeType.NodeType

var map
const margin = 16
var points = []

#@onready var bg = %Background
#@export var bg_texture : CompressedTexture2D
#var bg_texture 	= preload("res://assets/textures/map noise paper ninepatch.png")
var map_scene 	= preload("res://map/MapTree.tscn")

#@export var scroll_cont : ScrollContainer
@export var bg 			: NinePatchRect

func _ready():
	setup()
	
func setup():
	map = map_scene.instantiate()
	map.set_textures()
	add_nodes()
	draw()
	# Press the start node for the player for QoL reasons
	for child in bg.get_children():
		if child.type == NT.START:
			child._pressed()
			break


func reset():
	map.queue_free()
	for child in bg.get_children():
		bg.remove_child(child)
		child.queue_free()
	#scroll_cont.scroll_vertical = 0
	scroll_vertical = 0
	setup()

## Draws lines
func draw():
	var margins = Vector2(margin,margin)
	bg.draw.connect(func ():
		for node in map.map_nodes:
			if node != null:
				for child in node.get_sons():
					if node.type != NT.ERROR:
						#bg.draw_line(node.position + margins, child.position + margins, Color.DIM_GRAY, 2)
						#bg.draw_line(node.position + margins, child.position + margins, Color.RED, 2)
						var start = node.position + margins + Vector2(0, margins.y)
						var end = child.position + margins - Vector2(0, margins.y)
						bg.draw_line(start, end, Color("#6a3c33", .8), 4)
						bg.draw_line(start, end, Color("#b57521", .8), 2)
					else:
						bg.draw_line(node.position + margins, child.position + margins, Color.HOT_PINK, 2)
		)
		
func add_nodes():
	# Add nodes to map
	var index = 0
	for node in map.map_nodes:
		if node != null: #and node.type != NT.ERROR:
			var text = str(node.type)
			
			match node.type:
				
				NT.START:
					text = "Start"
					
				NT.BATTLE:
					text = "Battle"
					
				NT.CAMPFIRE:
					text = "Camp"
					
				NT.WORKSHOP:
					text = "Workshop"
					
				NT.TREASURE:
					text = "Treasure"
					
				NT.BOSS:
					text = "Boss"

			
			#node.text = str(node.type)
			#node.text = text
			bg.add_child(node)


func _on_visibility_changed():
	if visible:
		for map_node in bg.get_children():
			if not map_node.disabled:
				map_node.grab_focus()
				break
