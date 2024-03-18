extends Control

@export_file("*.tscn") var map_path

# Textbox
@export var textbox: Panel
@export var textboxLabel: Label
signal textbox_closed

func display_text(text):
	textbox.show()
	textboxLabel.text = text

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	display_text("You selected the proficiency upgrade")
	await textbox_closed
	
	var die = PlayerData.dice_bag[0]
	
	for i in range(die.num_sides):
				# Change to 10 to test -> allows for easy identification otherwsie you need to roll a 5 to see result
				die.sides[i].value += 1
				die.name = "D%d - prof" % die.num_sides
				print(die.name)
				print(die.sides[i].value)
	
	display_text("Congrats! You upgraded your D%d" % die.num_sides)
	await textbox_closed
	
	#get_tree().change_scene_to_file(map_path)
	#get_tree().unload_current_scene()
	Helpers.to_map(self)
	
	'''for die in PlayerData.dice_bag:
		display_text(die.name)
		await textbox_closed
		
		display_text("Would you like to select this die for upgrade?")
		await textbox_closed
		
		display_text("Type 'y' for yes, or 'n' for no. Then, press enter.")
		await textbox_closed
		
		grab_focus()
		#var input = os.get_scancode_string(event.scancode)
		var input = "y"
		#var input = ProficiencyUpgrade.get_node("Input")
		
		if input == "y":
			for i in range(die.num_sides):
				# Change to 10 to test -> allows for easy identification otherwsie you need to roll a 5 to see result
				die.sides[i] += 1
				die.name = "D%d - prof" % die.num_sides
				print(die.name)
				print(die.sides[i])
			get_tree().change_scene_to_file("res://battle.tscn")'''
