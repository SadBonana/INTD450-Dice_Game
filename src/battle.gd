# TODO: Consider making the battle scene paper 3D to make the multiple enemy perspective look better.
# Prolly needed for the 3d dice anyways.

extends Control

# TODO: encounter resources and setting battle enemy resources using it

@export_file("*.tscn") var drawn_die_path


@onready var player_status := %"Player Status"
#@export var player_status: VBoxContainer 
#@export var dieActionMenu: VBoxContainer
@onready var drawn_die_placeholder := %"Die Action Menu"
#@export var statusAndHandMenu: HBoxContainer
@onready var drawn_die_container := %"Hand of Dice"

# TODO: Convert these to @onready var x = %y format
# Player Panel
# Enemy
@export var enemy1: BattleEnemy
@export var enemy2: BattleEnemy
@export var enemy3: BattleEnemy

# Textbox
@onready var textbox_controller := %"Textbox Controller"
#@export var textbox_controller: TextboxController


@export var numEnemies = 3

signal textbox_closed
signal damage_enemy_resolved
signal target_selected(target)

var enemies = []

var player_dice_bag = []
var player_used_dice = []
var player_dice_hand = []

@onready var action_menu := %"Player Action Menu"


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
	# TODO: Might be able to set it as a placeholder in the scene hierarchy and remove this
	# line of code
	drawn_die_placeholder.hide()
	
	# uh oh, yuv been jumped m8!
	await textbox_controller.quick_beat("battle start")
	
	# This function will be called when the player selects an action that requires selecting an enemy
	DrawnDie.targeting_func = func ():
			if enemies.size() == 1:   # No need to select a target if there's only 1
				return enemies[0]
			
			await textbox_controller.quick_beat("targeting instructions")
			
			# Modify enemy opacity to indicate selection and attach callbacks
			# needed to select them
			for enemy in enemies:
				enemy.toggle_target_mode(true, target_selected)
			
			enemies[0].grab_focus()
			var target = await target_selected
			
			# Clean up once targeting is finished
			for enemy in enemies:
				enemy.toggle_target_mode(false, target_selected)
			
			return target
		
	draw_dice()


func draw_dice():
	# Enemy draws their dice and displays their rolls first so the player has more info.
	for enemy in enemies:
		enemy.draw_dice(2, textbox_controller)
	
	# It's the player's turn so show the things they'll need
	# to interact with to take their turn.
	drawn_die_container.show()
	action_menu.show()
	
	for i in range(3): # Hardcoded temp hand size of 3
		# Whatever we decide to do when the player runs out of dice, it'll be here
		if not player_dice_bag.size() > 0:
			textbox_controller.load_dialogue_chain("player out of dice 1",
					func (from_beat: DialogueBeat, destination_beat: String, from_choice: int):
						if from_beat.unique_name == "player out of dice 2":
							match from_choice:
								0:
									await textbox_controller.next()
									run()
								# If more choices are added, can be handled here.
			)
			for j in range(3):	# There are 3 dialogue beats in this chain.
				await textbox_controller.next()
			break
		
		# Draw and roll die
		var d = player_dice_bag.pop_back() # Draw die from bag
		player_used_dice.append(d) # Discard used die # TODO: put this somewhere else, like, after the die is actually used.
		var die = DrawnDie.instantiate(drawn_die_path, drawn_die_container, d)
		player_dice_hand.append(die)
	
	player_status.dice_remaining = player_dice_bag.size()


func enemy_turn(playerDefense=0):
	await textbox_controller.quick_beat("enemy attack")
	for enemy in enemies:
		var damage = Helpers.clamp_damage(enemy.damage, playerDefense)
		playerDefense = Helpers.clamp_damage(playerDefense, enemy.damage)
		PlayerData.hp -= damage
	
		# TODO: Make a temp player hurt anim
	
		await textbox_controller.quick_beat("deal damage", [enemy.enemy_name, damage])
	
	draw_dice()    # Enemy turn is over so player draws dice


func run():
	get_tree().change_scene_to_file("res://UI/campfire.tscn")


# Might not have a run button, it's just here... because... for now.
func _on_run_pressed():
	await textbox_controller.quick_beat("run")
	#await get_tree().create_timer(0.5).timeout
	#get_tree().quit()
	run()


# TODO: try to break this down until we dont need it.
func damageEnemy(damage, enemy: BattleEnemy):
	var defeated = await enemy.take_damage(damage)
	
	await textbox_controller.quick_beat("deal damage", ["You", damage])
	
	if defeated:
		await textbox_controller.next([enemy.enemy_name + " was"])
		# TODO: temp enemy death anim.
		enemy.queue_free()
		enemies.erase(enemy)
		if enemies.size() == 0:
			await textbox_controller.next()
			get_tree().change_scene_to_file("res://UI/campfire.tscn")
		
	emit_signal("damage_enemy_resolved")


func _on_ready_pressed():
	for die in player_dice_hand:
		if not die.item_selected:
			await textbox_controller.quick_beat("not ready")
			return
	
	# Hide things we don't want the player to be able to mess
	# with after they've ended their turn
	drawn_die_container.hide()
	action_menu.hide()
	
	await textbox_controller.quick_beat("ready")
	
	for enemy in enemies:
		enemy.roll_label.hide()
	
	var player_defense = 0
	for die in player_dice_hand:	# TODO: The order of actions should ideally be the order that the player used the die
		match die.selected_action:
			DrawnDie.ATTACK:
				# Account for if a previous die killed the enemy.
				# e.g. used 3 dice when the first 2 will kill the enemy
				# Could warn the player... or punish their stupidity by making the die just miss...
				# Actually yeah, that sounds more fun... 
				if die.target in enemies:
					damageEnemy(die.roll, die.target)
					await damage_enemy_resolved
				else:
					await textbox_controller.quick_beat("missed")
			DrawnDie.DEFEND:
				player_defense += die.roll
		die.queue_free()
		
	player_dice_hand.clear()
	enemy_turn(player_defense)
