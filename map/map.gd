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

## Inventory
@onready var inv_dice_visual = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
@onready var inv_side_visual = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")
@onready var side_name = "Sides"

@onready var canvas_layer = $CanvasLayer
@onready var player_status = $"CanvasLayer/Player Status"
@onready var inventory = %"Display Box"
@export var temp_dice_bag_init: PlayerDataInit
var inventory_open = false

func _ready():
	
	if PlayerData.dice_bag.size() == 0:
		PlayerData.dice_bag = temp_dice_bag_init.dice.duplicate(true)
	
	player_status.dice_remaining = PlayerData.dice_bag.size()
	
	## setup for dice inventory tab
	inventory.make_tab("In Bag", PlayerData.dice_bag, inv_dice_visual)
	## setup for die sides inventory tab
	inventory.make_tab(side_name, [], inv_side_visual)
	
	## connect dice bag button to inventory
	player_status.bag_button.pressed.connect(track_inventory)
	## connect frame clicks to display sides
	inventory.return_clicked.connect(show_sides)
	
	
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


## simple function that changes what is displayed on the sides tab
func show_sides(die : Die):
	var side_view
	for child in inventory.get_children():
		if child.tabobj_ref.get_tab_title() == side_name:	 #hardcoded cause bro this shit is ass
			side_view = child
	if side_view == null:
		return
	else:
		side_view.new_frames(die.sides)
		inventory.current_tab = side_view.get_index()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("I") and inventory_open == false:
		inventory.open()
		inventory_open = true
	elif event.is_action_pressed("I") and inventory_open == true:
		inventory.hide()
		inventory_open = false

func track_inventory():
	if inventory.visible == false:
		inventory.open()
		inventory_open = true
	elif inventory.visible == true:
		inventory.close()
		inventory_open = false

func _on_visibility_changed():
	if visible:
		for map_node in bg.get_children():
			if not map_node.disabled:
				get_tree().create_timer(0.5).timeout.connect(func (): map_node.grab_focus())
				break
