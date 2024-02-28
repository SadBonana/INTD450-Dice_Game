extends Node

const SAVEFILE = "user://SAVEFILE.save"
#const SAVEFILE = "user://save_game.dat"

var game_data = {}

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
	load_data()
	print("pros...")
	print(game_data)
	print("pros2...")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_data():
	if FileAccess.file_exists(SAVEFILE):
		var file = FileAccess.open(SAVEFILE, FileAccess.READ)
		game_data = file.get_var()
		#file.close()
		print(file)
	else:
		print("empty file")
		
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
		
		save_data()
		
	#file.open(SAVEFILE, File.READ)
	#file = FileAccess.open(SAVEFILE, FileAccess.READ)
	
	#game_data = file.get_as_text()
	#game_data = file.get_var()
	
	#file.close()
	
	#ResourceSaver.save(game_data, SAVEFILE)
	print("opened data")
	
func save_data():
	'''var file = File.new()
	file.open(SAVEFILE, File.WRITE)'''
	
	var file = FileAccess.open(SAVEFILE, FileAccess.WRITE)
	
	#file.store_string(game_data)
	file.store_var(game_data)
	
	#file.close()
	print("saved data")
