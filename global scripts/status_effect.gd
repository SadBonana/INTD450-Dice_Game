class_name StatusEffect

enum EffectType {BASEEFFECT, PARALYSIS, AUTODEFENSE, IGNITED, POISONED}

var target: BattleActor
var remaining_turns: int:
	set (value):
		remaining_turns = max(0, value)
var strength: int 	# Can be base turns, base damage/defense, anything really.
var beneficial: bool = false

var textbox: TextboxController
var description_beat: String

var _type = EffectType.BASEEFFECT


func _init(_textbox: TextboxController, _target: BattleActor, turns: int, _strength: int):
	remaining_turns = turns
	strength = _strength
	target = _target
	textbox = _textbox


func apply():
	pass


func invoke():
	pass



# For paralysis, strength is the number of dice to disable.
# This effect either refreshes, overwrites, or misses when used on a
# target that already has it.
# All this stuff is subject to change.
class Paralysis extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, turns := 3, _strength := 1):
		super(_textbox, _target, turns, _strength)
		_type = EffectType.PARALYSIS
		description_beat = "paralysis description"
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# For now, a new paralysis overwrites an existing one if it's stronger, or misses otherwise.
		# We could alternatively have it refresh the duration as well.
		# Could add status resist later if we want, including some kind of tolerance building mechanic
		for effect in target.status_effects:
			if effect._type == EffectType.PARALYSIS:
				if effect.strength >= strength and effect.remaining_turns > 0:
					await textbox.quick_beat("already paralyzed")
					return false
				# Replace the weaker effect with the stronger one.
				effect.remaining_turns = remaining_turns
				effect.strength = strength
				target.update_status_effects()
				await textbox.quick_beat("paralyzed", [strength, target.dice_draws])
				_invoke_helper()	# We expect this one to take effect immediately
				return true
		target.add_status_effect(self)
		await textbox.quick_beat("paralyzed", [strength, target.dice_draws])
		_invoke_helper()	# We expect this one to take effect immediately
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		_invoke_helper()
		await textbox.quick_beat("paralyzed invoke", [target.actor_name, target.dice_hand.size()])
		remaining_turns -= 1
		if remaining_turns == 0:
			target.remove_status_effect(self)
			return true
		return false
		
		
	func _invoke_helper():
		# Functional but less juicy way to implement paralysis:
		# target discards a die from their hand every turn.
		for i in range(strength):
			if target.dice_hand.size() > 0:
				var die = target.dice_hand.pop_back()
				if target is BattlePlayer:
					die.queue_free()
				target.commit_dice()



class Autodefense extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, turns: int, _strength:=2):
		super(_textbox, _target, turns, _strength)
		_type = EffectType.AUTODEFENSE
		beneficial = true
		description_beat = "autodefense description"
	
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Does not refresh duration of existing stacks, but adds new stacks with
		# durations based on the roll (this is controlled buring initialization,
		# so it could also be a constant or abritrary duration)
		target.add_status_effect(self)
		await textbox.quick_beat("autodefense")
		target.defense += strength		# We expect buffs to activate the turn they are used.
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		target.defense += strength
		remaining_turns -= 1
		if remaining_turns == 0:
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
		super(_textbox, _target, 5, 1)		# Default 5 turns, strength of 1
		spread_targets = all_targets
		_type = EffectType.IGNITED
		description_beat = "ignited description"
	
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Adding ignition stacks does not refresh or overwrite the duration of existing stacks.
		# New stacks receive the duration of existing stacks.
		for effect in target.status_effects:
			if effect._type == EffectType.IGNITED:
				effect.strength += 1
				target.update_status_effects()
				return true
		target.add_status_effect(self)
		await textbox.quick_beat("on fire")
		return true
		
		
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		var burning_dice = min(strength, target.dice_hand.size())
		if burning_dice > 0:
			await textbox.quick_beat("ignited invoke", [burning_dice])
		for i in range(burning_dice):
			var roll = target.dice_hand[i].die.roll()
			# NOTE: With the way things currently are, this means that if a victim's die has multiple
			# sides with the same value as its first side, it will be much more flammable. Which
			# could be interesting?
			if roll == target.dice_hand[i].die.sides[0]:
				# FIXME: If we ever teach enemies shadow clone jutsu, old fire won't spread to the clones this way:
				var new_ignition = Ignited.new(textbox, spread_targets.pick_random(), spread_targets)
				await new_ignition.apply()
			await target.take_damage(roll, "ignited")
			target.dice_hand[i].roll = roll
			target.commit_dice()
		remaining_turns -= 1	# NOTE: if high ignited stacks is too overpowered, can nerf it by indenting this line by one. Discovered thanks to a bug lol.
		if remaining_turns == 0:
			target.remove_status_effect(self)
			return true
		return false



class Poisoned extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, _strength):
		super(_textbox, _target, 5, _strength)	# Default 5 turns
		_type = EffectType.POISONED
		description_beat = "poisoned description"
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Applying stacks refreshes the constant duration. Number of stacks is
		# determined by the roll (or strength).
		for effect in target.status_effects:
			if effect._type == EffectType.POISONED:
				effect.strength += strength
				effect.remaining_turns = remaining_turns
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
		await target.take_damage(strength, "poison")
		remaining_turns -= 1
		if remaining_turns == 0:
			target.remove_status_effect(self)
			return true
		return false
