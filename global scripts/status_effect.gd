class_name StatusEffect

enum EffectType {BASEEFFECT, PARALYSIS, AUTODEFENSE, IGNITED, POISONED}
const BASEEFFECT := EffectType.BASEEFFECT
const PARALYSIS := EffectType.PARALYSIS
const AUTODEFENSE := EffectType.AUTODEFENSE
const IGNITED := EffectType.IGNITED
const POISONED := EffectType.POISONED

var target: BattleActor
var stacks: int:
	set (value):
		stacks = max(0, value)
var beneficial: bool = false	# Whether the effect is a buff or a debuff
var damaging: bool = true	# Should a die with this effect also do damage narmally.

var textbox: TextboxController
var description_beat: String

var _type = EffectType.BASEEFFECT


func _init(_textbox: TextboxController, _target: BattleActor, _stacks: int):
	stacks = _stacks
	#strength = _strength
	target = _target
	textbox = _textbox


func apply():
	pass


func invoke():
	pass



# For paralysis, stacks is the number of turns remaining.
# This effect adds 1 stack when used on a target that already has it.
# All this stuff is subject to change.
class Paralysis extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, stacks := 1):
		super(_textbox, _target, stacks)
		_type = EffectType.PARALYSIS
		description_beat = "paralysis description"
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# For now, a new paralysis overwrites an existing one if it's stronger, or misses otherwise.
		# We could alternatively have it refresh the duration as well.
		for effect in target.status_effects:
			if effect._type == EffectType.PARALYSIS:

				effect.stacks += stacks

				target.update_status_effects()
				await textbox.quick_beat("paralyzed", [stacks, target.dice_draws])
				_invoke_helper()	# We expect this one to take effect immediately
				return true
		target.add_status_effect(self)
		await textbox.quick_beat("paralyzed", [stacks, target.dice_draws])
		_invoke_helper()	# We expect this one to take effect immediately
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		_invoke_helper()
		await textbox.quick_beat("paralyzed invoke", [target.actor_name, target.dice_hand.size()])
		stacks -= 1
		if stacks == 0:
			target.remove_status_effect(self)
			return true
		return false
		
		
	func _invoke_helper():
		# Functional but less juicy way to implement paralysis:
		# target discards a die from their hand every turn.
		#for i in range(strength):
		if stacks > 0 and target.dice_hand.size() > 0:
			var die = target.dice_hand.pop_back()
			if target is BattlePlayer:
				die.queue_free()
			target.commit_dice()



class Autodefense extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, _stacks: int):
		super(_textbox, _target, _stacks)
		_type = EffectType.AUTODEFENSE
		beneficial = true
		damaging = false
		description_beat = "autodefense description"
	
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Extends duration of existing stacks based on roll, 
		# added defence based on the total number of stacks
		target.add_status_effect(self)
		await textbox.quick_beat("autodefense")
		for effect in target.status_effects:
			if effect._type == AUTODEFENSE:
				effect.stacks += stacks
				target.defense += effect.stacks# We expect buffs to activate the turn they are used.
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		target.defense += stacks
		stacks -= 1
		if stacks == 0:
			target.remove_status_effect(self)
			return true
		return false



# This was the the effect we seemed least decided on. I had an idea so I made it a certain way,
# but if someone doesn't like it they can change it back to what we talked about in that meeting
# way back when. The OG effect is written on the trello board. Anyways, here's what it does currently:
# Fire die do damage normally and has a 1/num_sides chance to ignite an enemy's die. So a d4 has a 
# 25% chance. If an enemy is already ignited, igniting them ignites another one of their die (aka
# the debuff gets more stacks). At the beginning of the turn, for each stack of ignition the target
# has, reroll a die in their dice hand and deal its roll as damage to the target, also, if the reroll
# lands on the die's first side (aka roll a 1 on any unmodified die), then the ignition will choose
# a random enemy to spread to. If it spreads to an already ignited target, then the number of stacks
# increase. For now, the effect is the same when used against the player.
class Ignited extends StatusEffect:
	var spread_targets: Array		# Array[BattleActor] technically but gdscript is being weird and not letting me cast it.
	
	func _init(_textbox: TextboxController, _target: BattleActor, all_targets: Array):
		super(_textbox, _target, 1)		# Default 1 stack
		spread_targets = all_targets
		_type = EffectType.IGNITED
		description_beat = "ignited description"
	
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Adding ignition stacks extendds duration.
		for effect in target.status_effects:
			if effect._type == EffectType.IGNITED:
				effect.stacks += 1
				target.update_status_effects()
				return true
		target.add_status_effect(self)
		await textbox.quick_beat("on fire")
		return true
		
		
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		var burning_dice = min(stacks, target.dice_hand.size())
		if burning_dice > 0:
			await textbox.quick_beat("ignited invoke", [burning_dice])
		for i in range(burning_dice):
			var roll = target.dice_hand[i].die.roll()
			# Made it compare values instead of sides cause i think it could be more interesting. Might wanna nerf later tho.
			if roll.value == target.dice_hand[i].die.sides[0].value:
				# FIXME: If we ever teach enemies shadow clone jutsu, old fire won't spread to the clones this way:
				var new_ignition = Ignited.new(textbox, spread_targets.pick_random(), spread_targets)
				await new_ignition.apply()

			await target.take_damage(roll.value, "ignited")
			target.dice_hand[i].side = roll
			target.commit_dice()
		stacks -= 1	# NOTE: if high ignited stacks is too overpowered, can nerf it by indenting this line by one. Discovered thanks to a bug lol.
		if stacks == 0:
			target.remove_status_effect(self)
			return true
		return false



class Poisoned extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, _stacks: int):
		#TODO: Determine if this is based on roll.
		super(_textbox, _target, _stacks)
		_type = EffectType.POISONED
		description_beat = "poisoned description"
		damaging = false
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Applying stacks refreshes the constant duration. Number of stacks is
		# determined by the roll (or strength).
		for effect in target.status_effects:
			if effect._type == EffectType.POISONED:
				effect.stacks = stacks
				target.update_status_effects()
				return true
		target.add_status_effect(self)
		await textbox.quick_beat("poisoned")
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		await textbox.quick_beat("poison invoke")
		await target.take_damage(stacks, "poison")
		stacks -= 1
		if stacks == 0:
			target.remove_status_effect(self)
			return true
		return false
