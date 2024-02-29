extends Node

const file_path = "user://SAVEFILE.save"
#const file_path = "user://save_game.dat"

var game_data

'''var game_data = {
	"fullscreen_on": false,
	"vsync_on": false,
	"display_fps": false,
	"max_fps": 0,
	"bloom_on": false,
	"brightness": 1,
	"master_vol": -10,
	"music_vol": -10,
	"sfx_vol": -10,
	"fov": 70,
	"mouse_sens": 0.1,
}'''

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Before:")
	print(game_data)
	
	'''game_data = {
		"fullscreen_on": false,
		"vsync_on": false,
		"display_fps": false,
		"max_fps": 0,
		"bloom_on": false,
		"brightness": 1,
		"master_vol": -10,
		"music_vol": -10,
		"sfx_vol": -10,
		"fov": 70,
		"mouse_sens": 0.1,
	}'''
		
	load_data()
	
	print("After:")
	print(game_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_data():
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		
		if file == null:
			print(FileAccess.get_open_error())
			return
			
		#var game_data_temp = file.get_var()
		#print(game_data_temp)
		
		var content = file.get_as_text()
		
		file.close()
		
		var game_data_temp = JSON.parse_string(content)
		
		if game_data_temp == null:
			#printerr("Can't parse")
			#return
			
			save_data_to_new_file()
		else:
			game_data = game_data_temp
			print("loaded old data")
	else:
		save_data_to_new_file()

func save_data():
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	var json_string = JSON.stringify(game_data, "\t")
	file.store_string(json_string)
	
	#file.store_var(game_data)
	
	file.close()
	
	print("saved data")

func save_data_to_new_file():
	#var file = FileAccess.open(file_path, FileAccess.READ)
	
	game_data = {
		"fullscreen_on": false,
		"vsync_on": false,
		"display_fps": false,
		"max_fps": 0,
		"bloom_on": false,
		"brightness": 1,
		"master_vol": -10,
		"music_vol": -10,
		"sfx_vol": -10,
		"fov": 70,
		"mouse_sens": 0.1,
	}
	
	save_data()
		
	print("loaded data into empty file")
