extends InvDieFrame
class_name DrawnDie

## paths to the styleboxes we need
var focused_press_path : StyleBox = preload("res://battle/drawn_die/styles/button_battle_focused_pressed.tres")
var pressed_path : StyleBox = preload("res://battle/drawn_die/styles/button_battle_pressed.tres")
## name of the styleboxes we wish to change
var pressed_style = "pressed"
var normal_style = "normal"

var data: DrawnDieData:
		set (ddd):
			data = ddd
			side = ddd.side
			die_ref = ddd.die
var side : DieSide:
		set (side):
			data.side = side
			die_type.text = "%d" % side.value
			# Set the color based on the effect of the side.
			var new_stylebox_normal = get_theme_stylebox(normal_style).duplicate()
			new_stylebox_normal.bg_color = side.element.color
			add_theme_stylebox_override(normal_style, new_stylebox_normal)
		get:
			return data.side
var roll: int:
		set (value):
			assert(false, "attempt to directly set roll of a DrawnDie object. Set the dieside instead")
		get:
			return side.value
var effect: StatusEffect.EffectType:
		set (value):
			assert(false, "attempt to directly set roll of a DrawnDie object. Set the dieside instead")
		get:
			return side.element.effect
var selected_action: DrawnDieData.DieActions:
		set (which):
			data.action = which
		get:
			return data.action
var target: BattleActor:
		set (who):
			data.target = who
		get:
			return data.target
var die: Die:
		set (whatnow):
			assert(false, "attempt to directly set die of a DrawnDie object. Set the data instead")
		get:
			return die_ref


## Loads, attaches to parent, and initializes required parameters all in one go.
static func instantiate(node_path: String, parent: Node, _die: Die, battle_context: Battle):
	var scene = load(node_path).instantiate()
	parent.add_child(scene)
	scene.data = DrawnDieData.new(_die, battle_context.player, battle_context)

	return scene


## called when the player selects a die in their hand. allows player to target actors.
func _on_toggled(toggled_on):
	if toggled_on:
		make_focused_pressed()
		var targets = data.battle.enemies.duplicate()
		targets.append(data.battle.player)

		await data.battle.textbox_controller.quick_beat("targeting instructions")

		# Set targeting callback and give the player visual queues for targeting
		for option in targets:
			option.toggle_target_mode(true, data.battle.target_selected)
		
		# Default to targetting the player if it's autodefense, because autodefense is a buff.
		if effect == StatusEffect.AUTODEFENSE:
			targets[-1].grab_focus()
		else:
			targets[0].grab_focus()
		target = await data.battle.target_selected
		
		selected_action = data.ATTACK if target is BattleEnemy else data.DEFEND
		
		make_pressed()
		# Clean up once targeting is finished
		for option in targets:
			option.toggle_target_mode(false, data.battle.target_selected)
			

## A function that changes the style box of the drawn_die
## in order to make it clear what die is currently selected
## effectively mimics what focus does visually
func make_focused_pressed():
	button.remove_theme_stylebox_override(pressed_style)
	button.add_theme_stylebox_override(pressed_style, focused_press_path)
	var new_stylebox_pressed = get_theme_stylebox(pressed_style)
	new_stylebox_pressed.bg_color = side.element.color

## A function that changes the style box of the drawn_die
## once it is no longer the selected die
func make_pressed():
	button.remove_theme_stylebox_override(pressed_style)
	button.add_theme_stylebox_override(pressed_style, pressed_path)


	
