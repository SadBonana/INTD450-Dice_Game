extends Node

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
var color: String
var colour : Color
var textbox: TextboxController
var textbox_enabled := false
var description_beat: String

var _type = EffectType.BASEEFFECT


func _init(_textbox: TextboxController, _target: BattleActor, _stacks: int):
	stacks = _stacks
	#strength = _strength
	target = _target
	textbox = _textbox
	colour = Color.WHITE


func apply():
	pass


func invoke():
	pass



# For paralysis, stacks is the number of turns remaining.
# This effect adds 1 stack when used on a target that already has it.
# All this stuff is subject to change.
class Paralysis extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor):
		super(_textbox, _target, 1)
		_type = EffectType.PARALYSIS
		color="#8c3cee" # purple from art palette #"REBECCA_PURPLE"
		colour = Color("#8c3cee")
		description_beat = "paralysis description"
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# For now, a new paralysis overwrites an existing one if it's stronger, or misses otherwise.
		# We could alternatively have it refresh the duration as well.
		for effect in target.status_effects:
			if effect._type == EffectType.PARALYSIS:
				SoundManager.lightning_apply.play()
				effect.stacks += 1

				target.update_status_effects()
				if textbox_enabled:
					await textbox.quick_beat("paralyzed", [stacks, target.dice_draws])
				#_invoke_helper()	# We expect this one to take effect immediately
				return true
		SoundManager.lightning_apply.play()
		target.add_status_effect(self)
		if textbox_enabled:
			await textbox.quick_beat("paralyzed", [stacks, target.dice_draws])
		#_invoke_helper()	# We expect this one to take effect immediately
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		#get_node("/root/SoundManager/select").play()
		SoundManager.error.play()
		_invoke_helper()
		if textbox_enabled:
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
		#if stacks > 0 and target.dice_hand.size() > 0:
		if target is BattlePlayer:
			for i in range(stacks):
				var max_die = argmax(target.dice_hand)
				var die = target.dice_hand[max_die]
				#if target is BattlePlayer:
					#target.used_dice.append(die.die)
					#die.visible = false
					#die.roll = max(die.roll - 2 * stacks, 0)
					#target.damage = max(target.attack - 2 * stacks, 0)
				die.mod = -2
				die.data.redo_effects(die.roll)
		else:
			target.commit_dice()

# TODO: Should really be moved to helpers.gd
func argmax(dice_hand : Array) -> int:
	var max = -1
	var index = -1
	for i in range(dice_hand.size()):
		if dice_hand[i].side.value > max:
			max = dice_hand[i].side.value
			index = i
		
		if dice_hand[i].side.value == max:
			
			var rand_f = randf() 
			if rand_f < 0.5:     #breaking ties randomly
				index = i
	return index

class Autodefense extends StatusEffect:
	func _init(_textbox: TextboxController, _target: BattleActor, _stacks: int):
		super(_textbox, _target, _stacks)
		_type = EffectType.AUTODEFENSE
		color="#9db3bf" # grey from art palette #"LIGHT_STEEL_BLUE"
		colour = Color("#9db3bf")
		beneficial = true
		damaging = false
		description_beat = "autodefense description"
	
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Extends duration of existing stacks based on roll, 
		# added defence based on the total number of stacks
		for effect in target.status_effects:
			if effect._type == AUTODEFENSE:

				SoundManager.autodefense_2.play()
				effect.stacks += stacks
				
				#await get_tree().create_timer(0.5).timeout
				
				#SoundManager.defend_2.play()
				target.update_status_effects()
				return true
		SoundManager.autodefense_2.play()
		target.add_status_effect(self)
		if textbox_enabled:
			await textbox.quick_beat("autodefense")
		
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		#get_node("/root/SoundManager/defend").play()
		SoundManager.defend_2.play()
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
		color = "#a90909" # red from art palette #"DARK_RED"
		colour = Color("#a90909")
		description_beat = "ignited description"
	
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Adding ignition stacks extendds duration.
		for effect in target.status_effects:
			if effect._type == EffectType.IGNITED:
				SoundManager.fire_apply.play()
				effect.stacks += stacks
				target.update_status_effects()
				return true
		SoundManager.fire_apply.play()
		target.add_status_effect(self)
		if textbox_enabled:
			await textbox.quick_beat("on fire")
		return true
		
		
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		SoundManager.fire_sfx.play()
		
		#var burning_dice = min(stacks, target.dice_hand.size())
		#if burning_dice > 0:
		#	if textbox_enabled:
		#		await textbox.quick_beat("ignited invoke", [burning_dice])
		#for i in range(burning_dice):
		#	var roll = target.dice_hand[i].die.roll()
		#	# Made it compare values instead of sides cause i think it could be more interesting. Might wanna nerf later tho.
		#	if roll.value == target.dice_hand[i].die.sides[0].value:
		#		# FIXME: If we ever teach enemies shadow clone jutsu, old fire won't spread to the clones this way:
		#		var new_ignition = Ignited.new(textbox, spread_targets.pick_random(), spread_targets)
		#		await new_ignition.apply()

		#	await target.take_damage(roll.value, "ignited")
		#	target.dice_hand[i].side = roll
		#	target.commit_dice()
		#await target.take_damage(2 * stacks,"fire")
		await target.take_damage(2 * stacks, EffectType.find_key(IGNITED))
		
		var rng = randf()
		var limit = min(stacks, 20)
		var reignite_chance = 0.25 + limit / 50 #every stack increases chance by 2% to a max of 65% total 
		#var reignite_chance = 1
		var spread_chance = 0.15 + limit / 50
		var do_nothing = 1 - (reignite_chance + spread_chance)

		if rng < reignite_chance:
			stacks += 2 #extends duration by 2 stacks
		elif rng < reignite_chance + spread_chance:
			var new_ignition = Ignited.new(textbox, spread_targets.pick_random(), spread_targets)
			await new_ignition.apply()
			
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
		color = "#239063" # green from art palette #"WEB_GREEN"
		colour = Color("#239063")
		description_beat = "poisoned description"
		damaging = false
	
	## Attempt to apply the status effect on the target.
	## Return whether the effect landed succesfully or not.
	func apply():
		# Applying stacks refreshes the constant duration. Number of stacks is
		# determined by the roll (or strength).
		for effect in target.status_effects:
			if effect._type == EffectType.POISONED:
				SoundManager.poison_apply.play()
				effect.stacks += stacks
				target.update_status_effects()
				return true
		SoundManager.poison_apply.play()
		target.add_status_effect(self)
		if textbox_enabled:
			await textbox.quick_beat("poisoned")
		return true
	
	
	## Called every turn as long as there are turns remaining. This func defines the behavior of the
	## status effect.
	## Return whether the effect should be removed this turn
	func invoke():
		#get_node("/root/SoundManager/poison_effect").play()
		SoundManager.poison_sfx.play()
		if textbox_enabled:
			await textbox.quick_beat("poison invoke")
		#await target.take_damage(stacks, "poison")
		await target.take_damage(stacks, EffectType.find_key(POISONED))
		stacks -= 1
		if stacks == 0:
			target.remove_status_effect(self)
			return true
		return false
