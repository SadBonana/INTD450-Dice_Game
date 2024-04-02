extends Node

const NT = NodeType.NodeType

var map
const margin = 5
var points = []

#@onready var bg = %Background
#@export var bg_texture : CompressedTexture2D
var bg_texture = preload("res://assets/textures/map noise paper ninepatch.png")

func _init():
	map = MapTree.new()
	
	# Setup stuff that lets you scroll the map.
	var scroll_cont = ScrollContainer.new()
	scroll_cont.custom_minimum_size = Vector2(640, 360)
	add_child(scroll_cont)
	
	# Setup the map background
	#var bg = TextureRect.new()
	var bg = NinePatchRect.new()
	
	bg.patch_margin_bottom = 32
	bg.patch_margin_left = 32
	bg.patch_margin_right = 32
	bg.patch_margin_top = 32
	
	bg.custom_minimum_size = Vector2(0, 1080)
	bg.texture = bg_texture
	#bg.stretch_mode = TextureRect.STRETCH_TILE
	scroll_cont.add_child(bg)
	
	# Draw Lines
	#var margins = Vector2(map.margin, 0)
	var margins = Vector2(8,16)
	bg.draw.connect(func ():
		for node in map.map_nodes:
			if node != null:
				for child in node.get_sons():
					if node.type != NT.ERROR:
						#TODO: uncomment when actual background is added
						#bg.draw_line(node.position + margins, child.position + margins, Color.DIM_GRAY, 2)
						bg.draw_line(node.position + margins, child.position + margins, Color.RED, 2)
					else:
						bg.draw_line(node.position + margins, child.position + margins, Color.HOT_PINK, 2)
		
		)
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
			node.text = text
			bg.add_child(node)
	
