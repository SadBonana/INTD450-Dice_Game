class_name BattlePlayer extends BattleActor

@export var texture: Texture
@export var temp_dice_bag_init: PlayerDataInit

# Called when the node enters the scene tree for the first time.
func _ready():
	if PlayerData.dice_bag.size() == 0:
		PlayerData.dice_bag = temp_dice_bag_init.dice.duplicate(true)
	dice_bag = PlayerData.dice_bag.duplicate() # shallow copy
	dice_bag.shuffle()
	dice_draws = PlayerData.dice_draws
	actor_name = "You"
	
	# set texture
	tex_rect.texture = texture


func _set_health(value):
	PlayerData.hp = value
func _get_health():
	return PlayerData.hp


func draw_dice():
	var dice = []
	for i in range(dice_draws):
		# Handle when the player is out of dice
		if not dice_bag.size() > 0:
			textbox.load_dialogue_chain("player out of dice 1",
					func (from_beat: DialogueBeat, destination_beat: String, from_choice: int):
						if from_beat.unique_name == "player out of dice 2":
							match from_choice:
								0:
									await textbox.next()
									
									# Reshuffle dice into bag
									dice_bag.append_array(used_dice)
									used_dice.clear()
									dice_bag.shuffle()
									for die in dice_hand:
										die.queue_free()
									dice_hand.clear()
								# If more choices are added, can be handled here.
			)
			for j in range(3):	# There are 3 dialogue beats in this chain.
				await textbox.next()
			break
		
		# Draw and roll die
		var d = dice_bag.pop_back() # Draw die from bag
		used_dice.append(d) # Discard used die # TODO: put this somewhere else, like, after the die is actually used.
		dice.append(d)
		
	return dice


func restore_sprite_color():
	tex_rect.self_modulate = Color.WHITE

