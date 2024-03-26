# TODO: Consider making the battle scene paper 3D to make the multiple enemy perspective look better.
# Prolly needed for the 3d dice anyways.

extends Control
class_name Battle

signal textbox_closed
signal damage_enemy_resolved
signal target_selected(target)

# File paths for scene changes and sub-scene instantiations.
@export_file("*.tscn") var drawn_die_path
@export_file("*.tscn") var map_path
@export_file("*.tscn") var loot_screen_path

# Enemy
# If given an EncounterTable, will randomly choose a BaseEncounter based on the difficulty setting.
@export var encounter_res: BaseEncounter

@export var boss_encounter: BaseEncounter
# CAUTION: The size of this array should not be higher than the number of rows in the map.
# See the start_battle() function below.
# NOTE: The array must be in the order that the player is expected to fight first.
# e.g. early game ecounter tables go first.
@export var encounter_tables: Resource#Array[EncounterTable]

# TODO: Convert these to @onready var x = %y format.
# Don't do this unless you plan on making encounter loading
# better too, because making these @onready when they're being
# referenced in _enter_tree() will cause a crash.
@export var enemy1: BattleEnemy
@export var enemy2: BattleEnemy
@export var enemy3: BattleEnemy

var enemies = []
var defeated_enemies = []
# Textbox
@onready var textbox_controller := %"Textbox Controller"

# Player Panel
@onready var bottom_container := %"Player Status and Hand"
@onready var player_status := %"Player Status"
@onready var drawn_die_placeholder := %"Die Action Menu"
@onready var drawn_die_container := %"Hand of Dice"
@onready var action_menu := %"Player Action Menu"
@onready var inventory := %"Inventory"
@onready var player := %"Battle Player"
@onready var ready_button := %Ready

## Inventory
@onready var inv_dice_visual = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
@onready var inv_side_visual = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")
@onready var side_name = "Sides"

## Starts a battle scene with the given encounter resource
##
## Parameters:
##         battle_scene_path:
##             the filepath of battle.tscn
##         encounter_res:
##             Can be a BaseEncounter for a guaranteed encounter, or an EncounterTable to randomly
##             select from a small set of encounters based on the game difficulty setting.
##             Note: encounters specify what enemies, and how many of them the player will fight.
##         tree:
##             Usually you will put get_tree() for this argument.
static func start(battle_scene_path: String, encounter_res: BaseEncounter, tree: SceneTree):
	var battle_node = load(battle_scene_path).instantiate()
	battle_node.encounter_res = encounter_res
	var scene = PackedScene.new()
	scene.pack(battle_node)
	tree.change_scene_to_packed(scene)

func _enter_tree():
	# Slight HACK: The better way is probably to load and instantiate the enemies
	# similar to how it is done for the DrawnDie.
	# Initilize enemy data and hide enemies that shouldn't show up in teh encounter
	var enemy_resources = encounter_res.enemies
	if enemy_resources.size() >= 1:
		enemy3.res = enemy_resources[0]
		enemy3.battle = self
		enemies.append(enemy3)
	if enemy_resources.size() >= 2:
		enemy2.res = enemy_resources[1]
		enemy2.battle = self
		enemies.append(enemy2)
	if enemy_resources.size() >= 3:
		enemy1.res = enemy_resources[2]
		enemy1.battle = self
		enemies.append(enemy1)
	match enemy_resources.size():
		1:
			enemy1.hide()
			enemy2.hide()
		2:
			enemy1.hide()

func _setup(node_depth: int):
	#Hard to do this here without hardcoding the value
	var num_map_levels = 10 # Number of node rows including start and boss
	
	#var encounter_tables = preload("res://encounter resources/early_game_encounters.tres")
	
	@warning_ignore("integer_division")
	assert(encounter_tables.size() > 0)
	var stage_size = num_map_levels / encounter_tables.size()
	for i in range(encounter_tables.size()):
		if node_depth < stage_size * (i+1):
			#Battle.start(battle_path, encounter_tables[i], get_tree())
			if encounter_tables:
				encounter_res = encounter_tables.get_enemies()
			#encounter_res = encounter_tables[i]
			break

# Called when the node enters the scene tree for the first time.
func _ready():
	# This will never be shown, instead, they will be instantiated as needed
	# The die action menu here is just so designers can see what one looks like in engine.
	# TODO: Might be able to set it as a placeholder in the scene hierarchy and remove this
	# line of code
	drawn_die_placeholder.hide()
	
	## setup for dice inventory tab
	inventory.make_tab("In Bag", player.dice_bag,inv_dice_visual)
	## setup for used inventory tab
	inventory.make_tab("Used", player.used_dice,inv_dice_visual)
	## setup for dice hand inventory tab
	inventory.make_tab("Hand", player.dice,inv_dice_visual)
	## setup for die sides inventory tab
	inventory.make_tab(side_name, [], inv_side_visual)
	## connect dice bag button to inventory
	player_status.bag_button.pressed.connect(inventory.open)
	## connect frame clicks to display sides
	inventory.return_clicked.connect(show_sides)
	
	# uh oh, yuv been jumped m8!
	await textbox_controller.quick_beat("battle start")
	
	# Give battle actors access to the textbox and determine what happens when they die
	for enemy in enemies:
		enemy.textbox = textbox_controller
		enemy.on_defeat = func ():
				# this code will run when the enemy is defeated
				await textbox_controller.quick_beat("actor defeated", [enemy.actor_name + " was"])
				# TODO: temp enemy death anim.
				if enemy != null:
					enemy.hide()	# Seems like queue_free isn't always instant so this is to coverup until it happens.
				if not enemy in defeated_enemies:
					defeated_enemies.append(enemy)
					enemies.erase(enemy)
				if enemies.size() == 0:
					await textbox_controller.next()
					get_tree().change_scene_to_file(loot_screen_path)
	player.textbox = textbox_controller
	player.on_defeat = func ():
### ALERT FIXME: MAKE IT RESET PROGRESS AND GO TO THE START MENU INSTEAD OF CRASHING THE GAME !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			# this code will run when the player is defeated
			await textbox_controller.quick_beat("game over")
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
			#get_tree().quit()
			# TODO: Might be better to have this stuff in the setter for PlayerData.hp instead
	
	draw_dice()

## simple function that changes what is displayed on the sides tab
func show_sides(die : Die):
	var side_view
	for child in inventory.get_children():
		if child.tabobj_ref.get_tab_title() == side_name:	 #hardcoded cause bro this shit is ass
			side_view = child
	if side_view == null:
		return
	else:
		side_view.new_frames(die.sides)
		inventory.current_tab = side_view.get_index()
## Starts a turn.
##
## First, enemies draw dice from their bags, then players do, then reset everyone's defense, then
## activate status effects (e.g. poisoned actors take damage here)
func draw_dice():
	# Enemy draws their dice and displays their rolls first so the player has more info.
	for enemy in enemies:
		await enemy.draw_dice()
	
	# It's the player's turn so show the things they'll need
	# to interact with to take their turn.
	drawn_die_container.show()
	action_menu.show()
	
	# Player draws dice
	for d in await player.draw_dice():
		var die = DrawnDie.instantiate(drawn_die_path, drawn_die_container, d, self)
		player.dice_hand.append(die)
	player_status.dice_remaining = player.dice_bag.size()
	
	# Reset any defense given in the previous turn
	player.defense = 0
	for enemy in enemies:
		enemy.defense = 0
	
	# Invoke status effects on enemies and player
	# NOTE: order of effect invocation matters a lot.
		# buffs before debuffs -> poison and such get mitigated by autodefense, makes debuff immunity effects easy to implement
		# order of application
	for enemy in enemies.duplicate():	# Shallow copy, so we don't get rekked when an enemy is removed from enemies on death
		for effect in enemy.status_effects.duplicate():
			if enemy != null and enemy.health != 0:
				await effect.invoke()
		if enemy != null and enemy.health != 0:
			enemy.update_status_effects()
	
	cleanup_enemies()	# Enemies need to die when they are killed
	
	for effect in player.status_effects.duplicate():
		await effect.invoke()
	player.update_status_effects()
	
	if player.dice_hand.size() > 0:
		player.dice_hand[0].grab_focus()
	else:
		ready_button.grab_focus()
	
	# MAYBE TODO: change the name of this func to start_turn() or something, then await ready_pressed or whatever, then call enemy turn. might make things clearer.
		# could potentially take most of the logic out of _on_ready_pressed and put it in a player_turn() function, whcih gets called here after ready gets pressed.


## Remove dead enemies.
##
## This exists because I was having trouble ensuring dead enemies stayed dead and didn't crash the
## game due to being accessed after being freed. Gets called after applying status effects and before
## the enemy's turn starts.
func cleanup_enemies():
	for enemy in defeated_enemies:
		enemy.queue_free()
	defeated_enemies.clear()


func enemy_turn():
	await textbox_controller.quick_beat("enemy attack")
	for enemy in enemies:
		for die in enemy.dice_hand:
			if die.action == DrawnDieData.ATTACK and die.effect.damaging:
				await player.take_damage(die.side.value, enemy.actor_name)
			else:		# DEFENSE
				enemy.defense += die.side.value
			await die.effect.apply()
	
	draw_dice()    # Enemy turn is over so player draws dice


# Might not have a run button, it's just here... because... for now.
func _on_run_pressed():
	await textbox_controller.quick_beat("run")
	#get_tree().change_scene_to_file(map_path)
	queue_free()
	get_node("/root/Map").visible = true


func _on_ready_pressed():
	for die in player.dice_hand:
		# NOTE: May eventually want to allow the player to intentionally discard or not use dice.
		if (not die.target or not die.is_toggled):
			await textbox_controller.quick_beat("not ready")
			die.grab_focus()
			return
	
	# Hide things we don't want the player to be able to mess
	# with after they've ended their turn
	drawn_die_container.hide()
	action_menu.hide()
	
	await textbox_controller.quick_beat("ready")
	
	for enemy in enemies:
		enemy.roll_label.hide()
	
	for die in player.dice_hand:	# TODO: The order of actions should ideally be the order that the player used the die
		match die.selected_action:
			DrawnDieData.ATTACK:
				# Account for if a previous die killed the enemy.
				if not die.target in enemies:
					await textbox_controller.quick_beat("missed")
				elif die.data.effect.damaging:
						await die.target.take_damage(die.roll, player.actor_name)
			DrawnDieData.DEFEND:
				player.defense += die.roll
		await die.data.effect.apply()
		
	cleanup_enemies()
	player.hand_used()
	for die in player.dice_hand:
		die.queue_free()
	player.dice_hand.clear()
	enemy_turn()
