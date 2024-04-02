extends Button

@export_file("*.tscn") var map_scene_path

@onready var start_menu = %start_menu_panel


# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	# Change to map scene once done
	#get_tree().change_scene_to_file(map_scene_path)
	get_node("/root/Map/BattleMusic").play()
	start_menu.get_parent_control().visible = false
