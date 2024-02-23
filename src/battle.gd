# TODO: Consider making the battle scene paper 3D to make the multiple enemy perspective look better.
# Prolly needed for the 3d dice anyways.

extends Control

# TODO: encounter resources and setting battle enemy resources using it

# Player Panel
@export var player_status: VBoxContainer 
@export var dieActionMenu: VBoxContainer
@export var statusAndHandMenu: HBoxContainer

# Enemy
@export var enemy1: BattleEnemy
@export var enemy2: BattleEnemy
@export var enemy3: BattleEnemy

# Textbox
@export var textbox_controller: TextboxController

@export var numEnemies = 3 


var dieActionMenuPath = load("res://die_action_menu.tscn")


signal textbox_closed
signal damage_enemy_resolved
signal target_selected(target)

var enemies = []

var player_dice_bag = []
var player_used_dice = []
var player_dice_hand = []

enum DieActions {ATTACK, DEFEND, REROLL}


class DrawnDie:
	static var targetingFunc: Callable
	
	var roll: int
	var actionMenu: ItemList
	var dieActionMenu: VBoxContainer
	var selectedAction: DieActions
	var target: BattleEnemy
	var itemSelected = false
	
	func _init(actual, menu):
		roll = actual
		dieActionMenu = menu
		actionMenu = dieActionMenu.find_child("Die Actions")
		
		# TODO: Find a way to do this without breaking controller support,
		# For that matter, make kb/m, controller, and touch support better.
		# None of them are amazing rn.
		actionMenu.item_selected.connect(func (index):
			itemSelected = true
			selectedAction = index
			if index == DieActions.ATTACK:
				target = await targetingFunc.call()
			# TODO: Rather than reroll, implement dice drafting
		)
	
	# TODO: Consider instead hiding the menus
	func set_all_actions_selectable(selectable: bool):
		for i in range(actionMenu.get_item_count()):
			actionMenu.set_item_selectable(i, selectable)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Initilize enemy data and hide enemies that shouldn't show up in teh encounter
	if numEnemies >= 1:
		enemies.append(enemy3)
	if numEnemies >= 2:
		enemies.append(enemy2)
	if numEnemies >= 3:
		enemies.append(enemy1)
	match numEnemies:
		1:
			enemy1.hide()
			enemy2.hide()
		2:
			enemy1.hide()
	
	# Initialize player data and player UI
	player_dice_bag = PlayerData.dice_bag.duplicate() # shallow copy
	player_dice_bag.shuffle()
	
	# This will never be shown, instead, they will be instantiated as needed
	# The die action menu here is just so designers can see what one looks like in engine.
	dieActionMenu.hide()
	
	textbox_controller.load_dialogue_chain("battle start 1")
	await textbox_controller.next()
	await textbox_controller.next([
		enemies[0].enemy_name,
		enemies[1].enemy_name,
		enemies[2].enemy_name,
		])	# FIXME: won't work with other encounter sizes, only did it this way for testing purposes.
	
	# This function will be called when the player selects an action that requires selecting an enemy
	DrawnDie.targetingFunc = func ():
			if enemies.size() == 1:   # No need to select a target if there's only 1
				return enemies[0]
			
			await textbox_controller.quick_beat("targeting instructions")
			
			# Prevent player from getting distracted and crashing teh game
			# It's bad news if the player presses attack before they finish targeting
			# TODO: press esc to cancel targeting
			for die in player_dice_hand:
				die.set_all_actions_selectable(false)
			
			# Modify enemy opacity to indicate selection and attach callbacks
			# needed to select them
			for enemy in enemies:
				enemy.toggle_target_mode(true, target_selected)
			
			enemies[0].grab_focus()
			var target = await target_selected
			
			# Clean up once targeting is finished
			for enemy in enemies:
				enemy.toggle_target_mode(false, target_selected)
			for die in player_dice_hand:
				die.set_all_actions_selectable(true)
			
			return target
		
	draw_dice()


func draw_dice():
	# Enemy draws their dice and displays their rolls first so the player has more info.
	for enemy in enemies:
		enemy.draw_dice(2, textbox_controller)
	
	for i in range(3): # Hardcoded temp hand size of 3
		# Whatever we decide to do when the player runs out of dice, it'll be here
		if not player_dice_bag.size() > 0:
			textbox_controller.load_dialogue_chain("player out of dice 1",
					func (from_beat: DialogueBeat, destination_beat: String, from_choice: int):
						if from_beat.unique_name == "player out of dice 2":
							match from_choice:
								0:
									run()
								# If more choices are added, can be handled here.
			)
			for j in range(3):	# There are 3 dialogue beats in this chain.
				await textbox_controller.next()
			break
		
		# Draw and roll die
		var d = player_dice_bag.pop_back() # Draw die from bag
		var roll = d.roll()
		player_used_dice.append(d) # Discard used die
		
		# Display the rolled value in the UI
		var die = dieActionMenuPath.instantiate()
		die.find_child("Roll").text = "%d" % roll    # TODO: This doesn't tell you the kind of dice it is, juct the roll. This will need to be implemented in the die_action_menu scene
		var drawnDie = DrawnDie.new(roll, die)
		player_dice_hand.append(drawnDie)
		statusAndHandMenu.add_child(die)
	
	player_status.dice_remaining = player_dice_bag.size()


func enemy_turn(playerDefense=0):
	for enemy in enemies:
		textbox_controller.load_dialogue_chain("enemy attack")
		await textbox_controller.next([enemy.enemy_name])
	
		var damage = Helpers.clamp_damage(enemy.damage, playerDefense)
		playerDefense = Helpers.clamp_damage(playerDefense, enemy.damage)
		PlayerData.hp -= damage
	
		# TODO: Make a temp player hurt anim
	
		await textbox_controller.next([enemy.enemy_name, damage])
	
	draw_dice()    # Enemy turn is over so player draws dice


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Rather than just deleting this, might need to disable processing for this
# thing or something, otherwise it'll be called even thought we're not using it.
# TODO
func _process(delta):
	pass


func run():
	get_tree().change_scene_to_file("res://UI/campfire.tscn")


# Might not have a run button, it's just here... because... for now.
func _on_run_pressed():
	await textbox_controller.quick_beat("run")
	#await get_tree().create_timer(0.5).timeout
	#get_tree().quit()
	run()


# TODO: make this generic to any actor? maybe even try to break this down until we dont need it.
func damageEnemy(damage, enemy: BattleEnemy):
	textbox_controller.load_dialogue_chain("player attack")
	await textbox_controller.next()
	
	var defeated = await enemy.take_damage(damage)
	
	await textbox_controller.next(["You", damage])
	
	if defeated:
		await textbox_controller.next([enemy.enemy_name + "was"])
		# TODO: temp enemy death anim.
		enemy.queue_free()
		enemies.erase(enemy)
		if enemies.size() == 0:
			await textbox_controller.next()
			get_tree().change_scene_to_file("res://UI/campfire.tscn")
		
	emit_signal("damage_enemy_resolved")


func _on_ready_pressed():
	for die in player_dice_hand:
		if not die.itemSelected:
			await textbox_controller.quick_beat("not ready")
			return
	
	await textbox_controller.quick_beat("ready")
	
	for enemy in enemies:
		enemy.roll_label.hide()
	
	var player_defense = 0
	for die in player_dice_hand:	# TODO: The order of actions should ideally be the order that the player used the die
		match die.selectedAction:
			DieActions.ATTACK:
				# Account for if a previous die killed the enemy.
				# e.g. used 3 dice when the first 2 will kill the enemy
				# Could warn the player... or punish their stupidity by making the die just miss...
				# Actually yeah, that sounds more fun... 
				if die.target in enemies:
					damageEnemy(die.roll, die.target)
					await damage_enemy_resolved
				else:
					await textbox_controller.quick_beat("missed")
			DieActions.DEFEND:
				player_defense += die.roll
			DieActions.REROLL:
				#TODO: take away rerolling. Implement dice drafting.
				pass
		die.dieActionMenu.queue_free()
		# FIXME: Disable most UI interaction until the effects of a previous interaction are resolved
		# This will prevent numerous issues, among them, the game crashing if you press enter to dismiss
		# a text box after pressing the to battle button (the enter goes through the textbox and also hits
		# the to battle button again, causing it to try to access a freed drawn die object).
		# Not all interaction should be disabled in some cases though, for example, while targeting,
		# the players still needs to be able to click/focus the enemies, and press the to battle button
		# that one is already implemented, but for example, the textbox doesn't disable other ui.
		
	player_dice_hand.clear()
	enemy_turn(player_defense)
