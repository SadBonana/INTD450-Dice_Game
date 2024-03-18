extends ScrollContainer

@export_file("*.tscn") var battle_path
@export_file('*.tscn') var campfire_path

# TODO: paths temporarily set to campfire scene, set to proper scenes when they exist.
@export_file('*.tscn') var treasure_path
@export_file('*.tscn') var workshop_path

@export_group("Battle Encounters")
# TODO: Add a boss encounter in the inspector, and probably more encounter progress stages
# Could consider adding a progress stage for every layer or two in the map.
@export var boss_encounter: BaseEncounter
# CAUTION: The size of this array should not be higher than the number of rows in the map.
# See the start_battle() function below.
# NOTE: The array must be in the order that the player is expected to fight first.
# e.g. early game ecounter tables go first.
@export var encounter_tables: Array[EncounterTable]


@export_group("Icon Textures")
@export_subgroup("Normal")
@export var camp_texture: AtlasTexture
@export var treasure_texture: AtlasTexture
@export var battle_texture: AtlasTexture
@export var start_texture: AtlasTexture
@export var workshop_texture: AtlasTexture
@export var boss_texture: AtlasTexture

@export_subgroup("Disabled")
@export var camp_disabled: AtlasTexture
@export var treasure_disabled: AtlasTexture
@export var battle_disabled: AtlasTexture
@export var start_disabled: AtlasTexture
@export var workshop_disabled: AtlasTexture
@export var boss_disabled: AtlasTexture

@export_subgroup("Focused")
@export var camp_focused: AtlasTexture
@export var treasure_focused: AtlasTexture
@export var battle_focused: AtlasTexture
@export var start_focused: AtlasTexture
@export var workshop_focused: AtlasTexture
@export var boss_focused: AtlasTexture


@onready var bg = %Background

const NT = NodeType.NodeType

var map
const margin = 5
var points = []

func _init():
	map = MapTree.new()


func _ready():
	# Add nodes to map
	var index = 0
	for node in map.map_nodes:
		if node != null: #and node.type != NT.ERROR:
			# Set node textures and attach callbacks
			match node.type:
				NT.ERROR:
					print("Error node found in map")
				NT.START:
					node.texture_normal = start_texture
					node.texture_disabled = start_disabled
					node.texture_focused = start_focused
					node.texture_hover = start_focused
					#node.icon = start_texture
				NT.BATTLE:
					node.texture_normal = battle_texture
					node.texture_disabled = battle_disabled
					node.texture_focused = battle_focused
					node.texture_hover = battle_focused
					#node.icon = battle_texture
					node.pressed.connect(func (): start_battle(node.depth))
				NT.BOSS:
					node.texture_normal = boss_texture
					node.texture_disabled = boss_disabled
					node.texture_focused = boss_focused
					node.texture_hover = boss_focused
					#node.icon = boss_texture
					node.pressed.connect(_on_boss_button_pressed)
				NT.CAMPFIRE:
					node.texture_normal = camp_texture
					node.texture_disabled = camp_disabled
					node.texture_focused = camp_focused
					node.texture_hover = camp_focused
					#node.icon = camp_texture
					node.pressed.connect(_on_camp_button_pressed)
				NT.TREASURE:
					node.texture_normal = treasure_texture
					node.texture_disabled = treasure_disabled
					node.texture_focused = treasure_focused
					node.texture_hover = treasure_focused
					#node.icon = treasure_texture
					node.pressed.connect(_on_treasure_button_pressed)
				NT.WORKSHOP:
					node.texture_normal = workshop_texture
					node.texture_disabled = workshop_disabled
					node.texture_focused = workshop_focused
					node.texture_hover = workshop_focused
					#node.icon = workshop_texture
					node.pressed.connect(_on_workshop_button_pressed)
			
			bg.add_child(node)
		index += 1


## Starts a battle scene with an encounter based on the player's map progress.
func start_battle(node_depth: int):
	var num_map_levels = MapTree.d + 2		# Number of node rows including start and boss
	@warning_ignore("integer_division")
	var stage_size = num_map_levels / encounter_tables.size()
	for i in range(encounter_tables.size()):
		if node_depth < stage_size * (i+1):
			Battle.start(battle_path, encounter_tables[i], get_tree())
			break


# NOTE: The following 4 functions are connected by code, and not the inspector
func _on_camp_button_pressed():
	get_tree().change_scene_to_file(campfire_path)
func _on_workshop_button_pressed():
	get_tree().change_scene_to_file(workshop_path)
func _on_treasure_button_pressed():
	get_tree().change_scene_to_file(treasure_path)
func _on_boss_button_pressed():
	Battle.start(battle_path, boss_encounter, get_tree())


# NOTE: Connected by the inspector
func _on_background_draw():
	# Draw Lines
	#var margins = Vector2(map.margin, 0)
	var margins = Vector2(8,16)
	#for con in map.connections:
	#TODO: we might wanna change this back to what sean had previously in the final version
	for node in map.map_nodes:
		if node != null:
			for child in node.get_sons():
				if node.type != NT.ERROR:
					bg.draw_line(node.position + margins, child.position + margins, Color.RED, 2)
				else:
					bg.draw_line(node.position + margins, child.position + margins, Color.HOT_PINK, 2)
