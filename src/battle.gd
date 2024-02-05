extends Control

@export var enemy: Resource = null

# Player Panel
@export var playerHealthBar: ProgressBar
@export var playerStatusContainer: HBoxContainer
@export var dieActionMenu: VBoxContainer
@export var statusAndHandMenu: HBoxContainer
@export var diceRemaining: Label
@export var diceMax: Label

# Enemy
@export var enemyContainer1: VBoxContainer
@export var enemyContainer2: VBoxContainer
@export var enemyContainer3: VBoxContainer

# Textbox
@export var textbox: Panel
@export var textboxLabel: Label

@export var numEnemies = 3 


var dieActionMenuPath = load("res://die_action_menu.tscn")


signal textbox_closed
signal damage_enemy_resolved
signal targeting_update

var player_health = 0
var enemy_health = 0

var enemies = []

var player_dice_bag = []
var player_used_dice = []
var player_dice_hand = []

var targetingEnemies = false
enum tc {NEXT, PREV, CONFIRM}
var targetingCommand

class Enemy:
	var res: Resource
	var cont: VBoxContainer
	var healthBar: ProgressBar
	var texRect: TextureRect
	var health
	var maxHealth
	var damage
	var name
	
	func _init(resource, container):
		res = resource
		cont = container
		healthBar = cont.find_child("ProgressBar")
		texRect = cont.find_child("Enemy")
		health = res.health
		maxHealth = res.health
		damage = res.damage
		name = res.name
		
		# set health bar
		healthBar.value = health
		healthBar.max_value = maxHealth
		healthBar.get_node("Label").text = "hp: %d/%d" % [health, maxHealth]
		
		# set texture
		texRect.texture = res.texture
		

enum DieActions {ATTACK, DEFEND, REROLL}

class DrawnDie:
	static var targetingFunc: Callable
	
	var maxRoll: int
	var roll: int
	var actionMenu: ItemList
	var dieActionMenu: VBoxContainer
	var selectedAction: DieActions
	# TODO: Keep track of targetted enemy for attack action
	var target: Enemy
	
	func _init(maxR, actual, menu):
		maxRoll = maxR
		roll = actual
		dieActionMenu = menu
		actionMenu = dieActionMenu.find_child("Die Actions")
		
		actionMenu.item_selected.connect(func (index):
			selectedAction = index
			if index == DieActions.ATTACK:
				target = await targetingFunc.call()
			# TODO: Need different logic for reroll, as it stands none of these actions do anything
			# until the player ends their turn, so the rerolled die would only be available next
			# turn... which could be interesting but wasn't what I envisioned previously.
		)


# Called when the node enters the scene tree for the first time.
func _ready():
	if numEnemies >= 1:
		enemies.append(Enemy.new(enemy, enemyContainer3))
	if numEnemies >= 2:
		enemies.append(Enemy.new(enemy, enemyContainer2))
	if numEnemies >= 3:
		enemies.append(Enemy.new(enemy, enemyContainer1))
	match numEnemies:
		1:
			enemyContainer1.hide()
			enemyContainer2.hide()
		2:
			enemyContainer1.hide()
	
	
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health(playerHealthBar, State.player_health, State.player_health_max)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	player_health = State.player_health
	enemy_health = enemy.health
	
	player_dice_bag = State.player_dice_bag.duplicate() # shallow copy
	player_dice_bag.shuffle()
	
	textbox.hide()
	$ActionsPanel.hide()
	dieActionMenu.hide()
	
	diceRemaining.text = "%d" % player_dice_bag.size()
	diceMax.text = "%d" % State.player_dice_bag.size()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await textbox_closed
	$ActionsPanel.show()
	
	DrawnDie.targetingFunc = func ():
		if enemies.size() == 1:
			return enemies[0]
		targetingEnemies = true
		display_text("Select the enemy to attack with < and >. Confirm with enter or click.")
		var index = await enemySelectionHelper(0)
		targetingEnemies = false
		return enemies[index]
		
	draw_dice()
	
func enemySelectionHelper(selected_i):
# FIXME: USE GODOT'S BUILT IN CONTROL NODE FOCUS SYSTEM, ON_FOCUS(), ETC INSTEAD. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	for i in range(enemies.size()):
		if i == selected_i:
			enemies[i].cont.modulate.a = 1.0
			continue
		enemies[i].cont.modulate.a = 0.5	# NOTE: Might be a bad way to do this... what if the alpha on the enemy container was set to something other than 1 somewhere else...
	await targeting_update
	match targetingCommand:
		tc.PREV:
			return await enemySelectionHelper((selected_i - 1) % enemies.size())
		tc.NEXT:
			return await enemySelectionHelper((selected_i + 1) % enemies.size())
		tc.CONFIRM:
			for i in range(enemies.size()):
				enemies[i].cont.modulate.a = 1.0
			return selected_i
	
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible and not targetingEnemies:
		textbox.hide()
		emit_signal("textbox_closed")
	if targetingEnemies:
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_focus_prev"):
			targetingCommand = tc.PREV
			emit_signal("targeting_update")
		elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_focus_next"):
			targetingCommand = tc.NEXT
			emit_signal("targeting_update")
		elif (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			targetingCommand = tc.CONFIRM
			emit_signal("targeting_update")
	
func draw_dice():
	for i in range(3): # Hardcoded temp hand size of 3
		if not player_dice_bag.size() > 0:
			display_text("Uh oh, all out of dice. Guess you're fucked.")
			await textbox_closed
			return
		var d = player_dice_bag.pop_back() # Draw die from bag
		var roll = roll_die(d)
		player_used_dice.append(d) # Discard used die
		var die = dieActionMenuPath.instantiate()
		die.find_child("Roll").text = "%d" % roll    # TODO: This doesn't tell you the kind of dice it is, juct the roll. This will need to be implemented in the die_action_menu scene
		
		var drawnDie = DrawnDie.new(d, roll, die)
		player_dice_hand.append(drawnDie)
		
		statusAndHandMenu.add_child(die)
		
	diceRemaining.text = "%d" % player_dice_bag.size()
		
		
# Prolly shouldn't be here. Also this is prolly a bad way to do this.
# If we use rng for rolls, we'll want to use a normal dist with mean set to what
# you would expect it to be for the given die.
# This method only exists for prototyping purposes. FIXME
func roll_die(max_roll):
	return (randi() % max_roll) + 1
	
func display_text(text):
	textbox.show()
	textboxLabel.text = text
	
func set_health(progress_bar, hp, hp_max):
	progress_bar.value = hp
	progress_bar.max_value = hp_max
	progress_bar.get_node("Label").text = "hp: %d/%d" % [hp, hp_max]
	
func damageHelper(x, y):
	return max(0, x - y)
	
func enemy_turn(playerDefense=0):
	for enemy in enemies:
		display_text("Oh noes! %s is coming for you!" % enemy.name)
		await textbox_closed
	
		var damage = damageHelper(enemy.damage, playerDefense)
		player_health = damageHelper(player_health, damage)
		set_health(playerHealthBar, player_health, State.player_health_max)
	
		#$AnimationPlayer.play("enemy_damaged")   #TODO: Make a temp player hurt anim... need a godot logo for the player first...
		#await $AnimationPlayer.animation_finished
	
		display_text("%s dealt %d damage!" % [enemy.name, damage])
		await textbox_closed
	
	# Enemy turn is over so player draws dice
	draw_dice()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_run_pressed():
	display_text("You coward! Execute game crash!")
	await textbox_closed
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

# TODO: make this generic to any actor
func damageEnemy(damage, enemy: Enemy):
	display_text("Attacking! dun dun dun!")
	await textbox_closed
	
	enemy.health = damageHelper(enemy.health, damage)
	set_health(enemy.healthBar, enemy.health, enemy.maxHealth)
	
	$AnimationPlayer.play("enemy_damaged") # FIXME: Probably doesnt target the right enemy. Likely best way is to make enemy container a scene with its own anim player
	await $AnimationPlayer.animation_finished
	
	display_text("Dealt %d damage!" % damage)
	await textbox_closed
	
	if enemy.health == 0:
		display_text("%s was defeated! This is bullshit! I'm not playing anymore! *crashes game*" % enemy.name)
		await textbox_closed
		# TODO: temp enemy death anim. 
		
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
		
	emit_signal("damage_enemy_resolved")


func _on_ready_pressed():
	display_text("Attacking! dun dun dun!")
	await textbox_closed
	
	var player_defense = 0
	
	for die in player_dice_hand:
		match die.selectedAction:
			DieActions.ATTACK:
				damageEnemy(die.roll, die.target)
				await damage_enemy_resolved # FIXME: There must be a better way to synchronize the textbox than putting a million await textbox_closed everywhere.
			DieActions.DEFEND:
				player_defense += die.roll
			DieActions.REROLL:
				#TODO: Implement, but prolly not here. See the TODO in the connect func call in the DrawnDie class
				pass
		die.dieActionMenu.queue_free()
	player_dice_hand.clear()
	enemy_turn(player_defense)
