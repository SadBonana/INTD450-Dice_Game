extends Node
class_name DrawnDieData

enum DieActions {ATTACK, DEFEND}

# Make the enum easier to use in external scripts. E.g. no DrawnDie.DieActions.ATTACK
const ATTACK = DieActions.ATTACK
const DEFEND = DieActions.DEFEND

var die: Die
var side : DieSide
var action: DieActions
var die_owner: BattleActor		# The actor who has this drawn die in their hand
var battle: Battle		# Reference to the active battle scene
var effect: StatusEffect
var target: BattleActor:		# The actor being targetted by the drawn die
	set (who):
		target = who
		var no_effect = StatusEffect.new(battle.textbox_controller, target, 0)		# dummy effect, none of the parameters mean anything.
		no_effect.damaging = false
		match side.element.effect:
			StatusEffect.BASEEFFECT:
				effect = StatusEffect.new(battle.textbox_controller, target, 0)		# dummy effect... Though we could move the damage logic to the base effect's invoke later if we wanted.
			StatusEffect.PARALYSIS:
				effect = no_effect if target_is_friendly() else StatusEffect.Paralysis.new(battle.textbox_controller, target)
			StatusEffect.AUTODEFENSE:
				# Theoretically allows actors to buff each other.
				effect = StatusEffect.Autodefense.new(battle.textbox_controller, target if target_is_friendly() else die_owner, side.value)
			StatusEffect.IGNITED:
				var spread_targets = battle.enemies if die_owner is BattlePlayer else [battle.player]
				effect = no_effect if target_is_friendly() else StatusEffect.Ignited.new(battle.textbox_controller, target, spread_targets)
			StatusEffect.POISONED:
				effect = no_effect if target_is_friendly() else StatusEffect.Poisoned.new(battle.textbox_controller, target, side.value)
			_:
				assert(false, "Your effect won't work until you instantiate it here in drawn_die_data.gd")

func redo_effects(die_roll: int):
	var no_effect = StatusEffect.new(battle.textbox_controller, target, 0)		# dummy effect, none of the parameters mean anything.
	no_effect.damaging = false
	match side.element.effect:
		StatusEffect.AUTODEFENSE:
			effect = StatusEffect.Autodefense.new(battle.textbox_controller, target if target_is_friendly() else die_owner, die_roll)
		StatusEffect.POISONED:
			effect = no_effect if target_is_friendly() else StatusEffect.Poisoned.new(battle.textbox_controller, target, die_roll)
		_:
			return
			
func _init(die: Die, die_owner: BattleActor, battle_context: Battle):
	self.die = die
	self.die_owner = die_owner
	battle = battle_context
	side = die.roll()


func target_is_friendly():
	if target != null:
		return target.get_script() == die_owner.get_script()
	return false
