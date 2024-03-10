extends InvDieFrame
class_name DrawnDie


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
			var new_stylebox_normal = get_theme_stylebox("normal").duplicate()
			new_stylebox_normal.bg_color = side.element.color
			add_theme_stylebox_override("normal", new_stylebox_normal)
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

		# Clean up once targeting is finished
		for option in targets:
			option.toggle_target_mode(false, data.battle.target_selected)
