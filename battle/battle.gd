# TODO: Consider making the battle scene paper 3D to make the multiple enemy perspective look better.
# Prolly needed for the 3d dice anyways.

extends Control
class_name Battle

signal textbox_closed
signal damage_enemy_resolved
signal target_selected(target)

# File paths for scene changes and sub-scene instantiations.
@export_file("*.tscn") var drawn_die_path
@export_file("*.tscn") var loot_screen_path
@export_file("*.tscn") var game_win_scene_path

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
@export var boss: BattleEnemy
@export var in_battle_scene = false

var enemies = []
var defeated_enemies = []

# Textbox
@onready var textbox_controller := %"Textbox Controller"
@export var enable_textboxes := false

# Player Panel
@onready var bottom_container := %"Player Status and Hand"
@onready var player_status := %"Player Status"
@onready var drawn_die_placeholder := %"Die Action Menu"
@onready var drawn_die_container := %"Hand of Dice"
@onready var action_menu := %"Player Action Menu"
@onready var inventory := %"Inventory"
@onready var side_info := %"Side Info"
@onready var player := %"Battle Player"
@onready var ready_button := %Ready
@onready var battle_container := %BattleContainer
@onready var inventory_container := %InventoryContainer

## Inventory
@onready var inv_dice_visual = preload("res://modules/inventory/diceinv/inv_die_frame.tscn")
@onready var inv_side_visual = preload("res://modules/inventory/diceinv/inv_dieside_frame.tscn")
@onready var info_box = preload("res://modules/infobox/info_box_frame.tscn")
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
	var enemy_resources
	
	if in_battle_scene == true:
		enemy_resources = boss_encounter.enemies
		boss.res = enemy_resources[0]
		boss.battle = self
		enemies.append(boss)
		enemy1.hide()
		enemy2.hide()
		enemy3.hide()
	else:
		enemy_resources = encounter_res.enemies
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
	
	get_node("/root/Map").canvas_layer.player_bag_container.visible = false
	
	player_status.dice_selected.visible = true
	
	drawn_die_placeholder.hide()
	
	## setup for dice inventory tab
	inventory.make_tab("In Bag", player.dice_bag,inv_dice_visual)
	## setup for used inventory tab
	inventory.make_tab("Used", player.used_dice,inv_dice_visual)
	## setup for dice hand inventory tab
	inventory.make_tab("Hand", player.dice,inv_dice_visual)
	## setup for die sides inventory tab
	inventory.make_tab(side_name, [], inv_side_visual)
	## Create info tab
	side_info.make_tab("Info", [], info_box)
	## connect dice bag button to inventory
	player_status.bag_button.pressed.connect(inventory_container.toggle)
	## connect frame clicks to display sides
	inventory.return_clicked.connect(show_sides)
	
	# uh oh, yuv been jumped m8!
	await textbox_controller.quick_beat("battle start")
	
	# Give battle actors access to the textbox and determine what happens when they die
	for enemy in enemies:
		enemy.textbox = textbox_controller
		# TODO: Add a battle_context reference to the BattleActor class so that the on_defeat function can be completely moved to BattleEnemy and BattlePlayer.
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
					if in_battle_scene == true:
						get_tree().change_scene_to_file(game_win_scene_path)
					else:
						get_tree().change_scene_to_file(loot_screen_path)
					queue_free()
	player.textbox = textbox_controller
	player.on_defeat = func ():
			# this code will run when the player is defeated
			await textbox_controller.quick_beat("game over")
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
			get_node("/root/Map").reset()
			get_node("/root/Map").canvas_layer.player_bag_container.visible = true
			get_node("/root/Map").visible = true
			queue_free()
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
		await get_tree().create_timer(0.35).timeout
	player_status.dice_remaining = player.dice_bag.size()

	for effect in player.status_effects.duplicate():
		if not effect.beneficial: 
			await effect.invoke()
			await get_tree().create_timer(0.5).timeout
			
	player.update_status_effects()
	# Reset any defense given in the previous turn
	player.defense = 0
	for enemy in enemies:
		enemy.defense = 0
	
	if player.dice_hand.size() > 0:
		# Set focus neighbors for the dice in the players hand. Needed since
		# making the dice overlap messed with godot's ability to do it automatically.
		var prev_d: DrawnDie
		for d in player.dice_hand:
			if not d.visible:
				continue
			if prev_d and prev_d is DrawnDie:
				prev_d.focus_neighbor_right = d.get_path()
				prev_d.focus_next = d.get_path()
				d.focus_previous = prev_d.get_path()
				d.focus_neighbor_left = prev_d.get_path()
			prev_d = d
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
	#draw_dice()
	if enable_textboxes:
		await textbox_controller.quick_beat("enemy attack")
	
	for enemy in enemies.duplicate():
		for effect in enemy.status_effects.duplicate():
			if enemy != null and enemy.health != 0:
				#await effect.invoke()
				#if effect._type != StatusEffect.PARALYSIS:
				await effect.invoke()
				await get_tree().create_timer(0.5).timeout
		if enemy != null and enemy.health != 0:
			enemy.update_status_effects()	
	
	for enemy in enemies:
		var attack_roll = 0
		var defense_roll = 0
		var def_die_effects = []
		var atk_die_effects = []
	
		#await get_tree().create_timer(0.5).timeout
		
		for die in enemy.dice_hand:
			if die.action == DrawnDieData.ATTACK and die.effect != null:
				#get_node("/root/SoundManager/attack").play()
				#SoundManager.attack_sfx.play()
				#await player.take_damage(die.side.value, enemy.actor_name)
				attack_roll += die.side.value
				atk_die_effects.append(die.effect)
				
			#else:		# DEFENSE
			if die.action == DrawnDieData.DEFEND:
				#get_node("/root/SoundManager/defend").play()
				#SoundManager.defend_sfx.play()
				#enemy.defense += die.side.value
				defense_roll += die.side.value
				def_die_effects.append(die.effect)
		
		if defense_roll > 0:
			SoundManager.defend_sfx.play()
			enemy.defense += defense_roll
		
		for effect in def_die_effects:
			effect.apply()
			await get_tree().create_timer(0.5).timeout
		
		if attack_roll > 0:
			SoundManager.attack_sfx.play()
			#player.damage_indication.visible = true
			await player.take_damage(attack_roll, enemy.actor_name)
			#player.damage_indication.visible = false
		
		for effect in atk_die_effects:
			effect.apply()
			await get_tree().create_timer(0.5).timeout
			
	#await get_tree().create_timer(0.5).timeout
	
	#for effect in player.status_effects.duplicate():
#		if not effect.beneficial:
#			await effect.invoke()
#			await get_tree().create_timer(0.5).timeout
	
	draw_dice()    # Enemy turn is over so player draws dice
	
# Might not have a run button, it's just here... because... for now.
func _on_run_pressed():
	#get_node("/root/SoundManager/select").play()
	SoundManager.select_2.play()
	await textbox_controller.quick_beat("run")
	
	queue_free()
	get_node("/root/Map").visible = true
	get_node("/root/Map").canvas_layer.player_bag_container.visible = true


func _on_ready_pressed():
	#get_node("/root/SoundManager/select").play()
	SoundManager.select_2.play()
	var one_target = false
	for die in player.dice_hand:
		if die.target:
			one_target = true
			break
	
	if not one_target:
	# NOTE: May eventually want to allow the player to intentionally discard or not use dice.
		await textbox_controller.quick_beat("not ready")
		player.dice_hand[0].grab_focus()
		return
	
	# Hide things we don't want the player to be able to mess
	# with after they've ended their turn
	drawn_die_container.hide()
	action_menu.hide()
	if enable_textboxes:
		await textbox_controller.quick_beat("ready")
	
	#for enemy in enemies:
		#enemy.roll_label.hide()
	#applying debuffs before player takes their turn
	for die in player.dice_hand:	# TODO: The order of actions should ideally be the order that the player used the die
		
		'''die.target.damage_for_preview = die.roll'''
		
		if not die.target:
			continue
		'''
		match die.selected_action:
			DrawnDieData.ATTACK:
				# Account for if a previous die killed the enemy.
				if not die.target in enemies:
					await textbox_controller.quick_beat("missed")
				elif die.data.effect.damaging:
						
						# The 1st and 3rd line are used for damage animation
						die.target.damage_indication.visible = true
						await die.target.take_damage(die.roll, player.actor_name)
						#die.target.damage_indication.visible = false''
						
					#get_node("/root/SoundManager/attack").play()
					SoundManager.attack_sfx.play()
					await die.target.take_damage(die.roll, player.actor_name)
			DrawnDieData.DEFEND:
				#get_node("/root/SoundManager/defend").play()
				SoundManager.defend_2.play() #TODO: Make sure this plays at the proper time
				player.defense += die.roll
		
		await die.data.effect.apply()
		# Used for damage animation
		die.target.damage_indication.visible = false
		
		'''
		if die.selected_action == DrawnDieData.DEFEND:
			SoundManager.defend_2.play() #TODO: Make sure this plays at the proper time
			player.defense += die.roll
			await die.data.effect.apply()
	
			await get_tree().create_timer(0.5).timeout #delaying so the player can see the effects apply

	await get_tree().create_timer(0.2).timeout
	
	#applying buffs before attacking
	for effect in player.status_effects.duplicate():
		if effect.beneficial: 
			await effect.invoke()
			await get_tree().create_timer(0.5).timeout
	
	await get_tree().create_timer(0.2).timeout #delaying so the player can see the effects apply
	
	for die in player.dice_hand:	# TODO: The order of actions should ideally be the order that the player used the die
		if not die.target:
			continue
			
		if die.selected_action == DrawnDieData.ATTACK:
			
			# Account for if a previous die killed the enemy.
			if not die.target in enemies:
				await textbox_controller.quick_beat("missed")
			#elif die.data.effect.damaging:
			else:
				#get_node("/root/SoundManager/attack").play()
				#SoundManager.attack_sfx.play()
				#await die.target.take_damage(die.roll, player.actor_name)
				if die.data.effect.damaging:
					SoundManager.attack_sfx.play()
					#die.target.damage_indication.visible = true
					await die.target.take_damage(die.roll, player.actor_name)
					#die.target.damage_indication.visible = false
					await get_tree().create_timer(0.2).timeout
				await die.data.effect.apply()
				
			#applying buffs after attacking
			
	await get_tree().create_timer(0.5).timeout #delaying so the player can see the effects apply
	
	cleanup_enemies()
	player.hand_used()
	for die in player.dice_hand:
		die.queue_free()
	player.dice_hand.clear()
	drawn_die_container.reset()
	enemy_turn()


func _on_die_action_menu_is_hovered(dieside):
	side_info.get_current_tab_control().new_frames(dieside)
