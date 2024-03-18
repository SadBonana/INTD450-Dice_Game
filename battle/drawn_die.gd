class_name DrawnDie extends VBoxContainer

# TODO: Would be ideal if BattleEnemy also used this class later so that letting them target things
# and decide whether to attack or defend or whatever could be done smoother.

enum DieActions {ATTACK, DEFEND}

# Make the enum easier to use in external scripts. E.g. no DrawnDie.DieActions.ATTACK
const ATTACK = DieActions.ATTACK
const DEFEND = DieActions.DEFEND

static var targeting_func: Callable


## Loads, attaches to parent, and initializes required parameters all in one go.
static func instantiate(node_path: String, parent: Node, _die: Die):
	var scene = load(node_path).instantiate()
	scene.die = _die
	parent.add_child(scene)
	scene.dieside = _die.roll()
	scene.roll = scene.dieside.value
	scene.effect = scene.dieside.element.effect
	scene.die_sprite.set_self_modulate(scene.dieside.element.color)
	return scene

var roll: int:
	set (value):
		roll = value
		roll_label.text = "%d" % roll	 # TODO: This doesn't tell you the kind of dice it is, juct the roll.
var die: Die	# Could later be accessed to provide the player with die info and such
var dieside : DieSide
var selected_action: DieActions
var target: BattleEnemy
var effect: StatusEffect.EffectType
var item_selected = false

@onready var action_menu := %"Die Actions"
@onready var roll_label := %Roll
@onready var die_sprite = $"Die Sprite"


# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Find a way to do this without breaking controller support, as right
	# now, if you use arrow keys/dpad to select attack, it will go straight to
	# targeting even though you didn't confirm that that is what you wanted, but
	# if we change it to item_activated instead, then mouse and touch players
	# will have to double click, which is annoying.
	# For that matter, make kb/m, controller, and touch support better in the
	# game in general. None of them are amazing rn.
	
	# Set the callback for the attack/defend buttons.
	action_menu.item_selected.connect(func (index):
			item_selected = true
			selected_action = index
			
			# Prevent player from getting distracted and crashing teh game
			# It's bad news if the player presses attack before they finish targeting
			# TODO: press esc to cancel targeting
			action_menu.hide()
			
			
			if index == DieActions.ATTACK:
				# TODO: Below 3 lines are temp stuff
				target = await targeting_func.call()
				
			# TODO: Rather than reroll, implement dice drafting
			
			action_menu.show()
	)
