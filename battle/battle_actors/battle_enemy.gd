class_name BattleEnemy extends BattleActor

@onready var health_bar: HealthBar = %HealthBar
@onready var roll_label: Label = %Roll  # FIXME: Displaying the enemy's roll over their sprite is prolly not what we want the final game to look like. I thought the empty top panel was where we'd show that info, but I'm running out of energy now so...

@export var res: Resource


var battle: Battle
var max_health: int:
	set (value):
		max_health = value
		health_bar.max_value = value
var damage: int:
	set (value):
		damage = value
		roll_label.text = "%d" % damage

func _set_health(value):
	health = clamp(value, 0, max_health)
	health_bar.value = health
func _get_health():
	return health


# Called when the node enters the scene tree for the first time.
func _ready():
	restore_sprite_color()
	roll_label.hide()
	max_health = res.health
	health = res.health
	dice_draws = res.dice_draws
	actor_name = res.name
	
	# Initialize enemy dice bag
	dice_bag = res.dice.duplicate()
	dice_bag.shuffle()
	
	# set texture
	tex_rect.texture = res.texture


# Can be used later for fancier enemy decision making
## Commit dice in dice hand to a particular action. For now, just uses all dice for attacking.
func commit_dice():
	for die in dice_hand:
		die.target = battle.player
		die.action = DrawnDieData.ATTACK
	var paralyzed = false
	for effect in status_effects:
		if effect._type == StatusEffect.PARALYSIS:
			paralyzed = true
			
	damage = dice_hand.reduce(func (accum, die): return accum + die.side.value, 0)	# damage = sum of rolls in dice hand
	if paralyzed:
		damage =  max(0, damage-2)

# Will likely need to be rewritten once effect die and enemies defending become a thing.
func draw_dice():
	dice_hand = []	# Reset the hand so we don't use the values from last turn
	for i in range(dice_draws):
		# Whatever we decide to do when the enemy runs out of dice, it'll be here
		if not dice_bag.size() > 0:
			await textbox.quick_beat('enemy out of dice', [actor_name])
			# Reshuffle dice into bag
			dice_bag = used_dice
			used_dice = []
			dice_bag.shuffle()
			dice_hand.clear()
			break
		
		# Draw the actual die from the bag, roll it, add it to hand, and consider
		# it a used die (aka discard it but not really)
		var d = dice_bag.pop_back()
		used_dice.append(d)		# TODO: make this happen after the die actually gets used
		var die = DrawnDieData.new(d, self, battle)
		dice_hand.append(die)
		
	commit_dice()
	
	roll_label.show()


## Restore the texture rect's self_modulate property to res.sprite_color
##
## AnimationPlayer doesnt work well with dynamic or unknown keyframe values,
## hence why restore_sprite_color() is needed, in case someone wants an enemy
## with a self modulate alpha value set to something less than 1. E.g. maybe
## they made an opaque ghost sprite and wanted to use a ghost resource file to
## change the opacity in godot. Without restore_sprite_color(), the ghost will
## permanently lose its transparency after the hurt animation plays. The only
## other solution is to use Tweens, which cannot be seen in the editor like the
## AnimationPlayer can.
func restore_sprite_color():
	tex_rect.self_modulate = res.sprite_color
