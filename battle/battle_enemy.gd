class_name BattleEnemy extends BattleActor

@onready var health_bar: HealthBar = %HealthBar
@onready var roll_label: Label = %Roll  # FIXME: Displaying the enemy's roll over their sprite is prolly not what we want the final game to look like. I thought the empty top panel was where we'd show that info, but I'm running out of energy now so...

@export var res: Resource


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


# HACK: Ideally this could be the same DrawnDie used by the player, but that's troublesome right now.
# This is needed for certain status effects.
class EnemyDrawnDie:
	var roll: int
	var die: Die
	
	func _init(die: Die):
		self.die = die
		self.roll = die.roll()


# Called when the node enters the scene tree for the first time.
func _ready():
	restore_sprite_color()
	roll_label.hide()
	max_health = res.health
	health = res.health
	dice_draws = res.dice_draws
	actor_name = res.name
	
	# Initialize enemy dice bag
	var dice_caps = res.dice_caps.duplicate()
	dice_caps.shuffle()
	dice_bag = Die.to_dice(dice_caps)
	
	# set texture
	tex_rect.texture = res.texture


# Can be used later for fancier enemy decision making
## Commit dice in dice hand to a particular action. For now, just uses all dice for attacking.
func commit_dice():
	damage = dice_hand.reduce(func (accum, die): return accum + die.roll, 0)	# damage = sum of rolls in dice hand


# Will likely need to be rewritten once effect die and enemies defending become a thing.
func draw_dice():
	dice_hand = []	# Reset the hand so we don't use the values from last turn
	for i in range(dice_draws):
		# Whatever we decide to do when the enemy runs out of dice, it'll be here
		if not dice_bag.size() > 0:
			await textbox.quick_beat('enemy out of dice', [actor_name])
			break
		
		# Draw the actual die from the bag, roll it, add it to hand, and consider
		# it a used die (aka discard it but not really)
		var d = dice_bag.pop_back()
		used_dice.append(d)		# TODO: make this happen after the die actually gets used
		var die = EnemyDrawnDie.new(d)
		dice_hand.append(die)
		
	commit_dice()
	
	roll_label.show()


func toggle_target_mode(player_is_targeting: bool, target_selected: Signal):
	# Init logic for player to target enemies
	if player_is_targeting:
		modulate.a = _usual_alpha / 2	# Set unfocused alpha
		set_focus_mode(FOCUS_ALL)	# Enable focus
		
		# Set the _on_gui_input func so we can connect the _on_focus...
		_on_gui_input_factory(target_selected)
		
		# Connect callbacks
		focus_entered.connect(_on_focus_entered)
		focus_exited.connect(_on_focus_exited)
		
	# Cleanup now that targeting is finished
	else:
		set_focus_mode(FOCUS_NONE)	# Disable focusing
		
		# Disconnect callbacks
		Helpers.disconnect_if_connected(focus_entered, _on_focus_entered)
		Helpers.disconnect_if_connected(focus_exited, _on_focus_exited)
		
		modulate.a = _usual_alpha	# Restore alpha


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


var _on_gui_input: Callable

# NOTE: The 2 callback funcs below are intentionally not connected by default
func _on_focus_entered():
	gui_input.connect(_on_gui_input)
	modulate.a = _usual_alpha

func _on_focus_exited():
	Helpers.disconnect_if_connected(gui_input, _on_gui_input)
	modulate.a = _usual_alpha / 2

## Generates a gui_input callback that will emit the given
## target_selected signal when the gui_input signal is received with a
## ui_accept event.
func _on_gui_input_factory(target_selected: Signal):
	_on_gui_input = func (event: InputEvent):
		if event.is_action_pressed("ui_accept") or event.is_action_released("click"):
			target_selected.emit(self)



