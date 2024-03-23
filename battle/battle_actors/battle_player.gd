class_name BattlePlayer extends BattleActor

@export var texture: Texture
@export var temp_dice_bag_init: PlayerDataInit
var out_of_dice : bool = false
var dice = []

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
	out_of_dice = false
	for i in range(dice_draws):
		# Handle when the player is out of dice
		if dice_bag.size() <= 0:
			out_of_dice = true
			break
		var d = dice_bag.pop_back() # Draw die from bag
		dice.append(d)
	return dice

func hand_used():
	for drawndie in dice_hand:
		used_dice.append(drawndie.die)
	dice.clear()
	if out_of_dice:
		# Reshuffle dice into bag
		dice_bag.append_array(used_dice)
		used_dice.clear()
		dice_bag.shuffle()
	return

func restore_sprite_color():
	tex_rect.self_modulate = Color.WHITE

