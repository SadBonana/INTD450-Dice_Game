extends Control

@export var enemyRes: Resource = null

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
signal target_selected(target)

var player_health = 0
var enemy_health = 0

var enemies = []

var player_dice_bag = []
var player_used_dice = []
var player_dice_hand = []

var targetingEnemies = false

# NOTE: I suspect that the better way to do this is to make the enemies their own scene, and this
# class basically as the script attached to the scene. Same with drawn dice, though it already has
# a scene, just no script.
class Enemy:
	var res: Resource
	var cont: VBoxContainer
	var healthBar: ProgressBar
	var texRect: TextureRect
	var rollLabel: Label    # FIXME: Displaying the enemy's roll over their sprite is prolly not what we want the final game to look like. I thought the empty top panel was where we'd show that info, but I'm running out of energy now so...
	var health
	var maxHealth
	var damage
	var name
	
	# FIXME: Ideally the enemies also have dice bags and hands and the player can see all their
	# dice... maybe... that's how we platested it on paper anyways. Dunno how to handle running out
	# of dice yet but anyways. For now just setting to a single d6 cuz I'm running out of steam.
	# Also the dice need to be added to the resource script, similar to how it is with the hp.
	var maxRoll = 6    # Hardcoded and done the dumbest way possible.
	
	var _on_focus_entered: Callable
	var _on_focus_exited: Callable
	var _on_gui_input: Callable
	
	func _init(resource, container):
		res = resource
		cont = container
		healthBar = cont.find_child("ProgressBar")
		texRect = cont.find_child("Enemy")
		rollLabel = texRect.find_child("Roll")
		rollLabel.hide()
		health = res.health
		maxHealth = res.health
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
	
	#var maxRoll: int
	var roll: int
	var actionMenu: ItemList
	var dieActionMenu: VBoxContainer
	var selectedAction: DieActions
	var target: Enemy
	var itemSelected = false
	
	func _init(actual, menu):
		#maxRoll = maxR
		roll = actual
		dieActionMenu = menu
		actionMenu = dieActionMenu.find_child("Die Actions")
		
		actionMenu.item_selected.connect(func (index):
			itemSelected = true
			selectedAction = index
			if index == DieActions.ATTACK:
				target = await targetingFunc.call()
			# TODO: Need different logic for reroll, as it stands none of these actions do anything
			# until the player ends their turn, so the rerolled die would only be available next
			# turn... which could be interesting but wasn't what I envisioned previously.
		)
	
	func set_all_actions_selectable(selectable: bool):
		for i in range(actionMenu.get_item_count()):
			actionMenu.set_item_selectable(i, selectable)


# Called when the node enters the scene tree for the first time.
func _ready():
	if numEnemies >= 1:
		enemies.append(Enemy.new(enemyRes, enemyContainer3))
	if numEnemies >= 2:
		enemies.append(Enemy.new(enemyRes, enemyContainer2))
	if numEnemies >= 3:
		enemies.append(Enemy.new(enemyRes, enemyContainer1))
	match numEnemies:
		1:
			enemyContainer1.hide()
			enemyContainer2.hide()
		2:
			enemyContainer1.hide()
	
	set_health(playerHealthBar, State.player_health, State.player_health_max)
	player_health = State.player_health
	
	player_dice_bag = State.player_dice_bag.duplicate() # shallow copy
	player_dice_bag.shuffle()
	
	textbox.hide()
	dieActionMenu.hide()
	
	diceRemaining.text = "%d" % player_dice_bag.size()
	diceMax.text = "%d" % State.player_dice_bag.size()
	
	display_text("Uh oh! yuv been jumped m8!")
	await textbox_closed
	
	# This function will be called when the player selects an action that requires selecting an enemy
	DrawnDie.targetingFunc = func ():
			if enemies.size() == 1:   # No need to select a target if there's only 1
				return enemies[0]
				
			targetingEnemies = true
			display_text("Select the enemy to attack. Press enter to confirm the selection.")
			
			# Prevent player from getting distracted and crashing teh game
			for die in player_dice_hand:
				die.set_all_actions_selectable(false)
			
			for enemy in enemies:
				enemy.cont.modulate.a = 0.5    # NOTE: Might be a bad way to do this... what if the alpha on the enemy container was set to something other than 1 somewhere else...
				enemy.cont.set_focus_mode(FOCUS_ALL)
				
				# Create and set event handlers
				enemy._on_gui_input = func(event: InputEvent):
						if event.is_action_pressed("ui_accept"):
							targetingEnemies = false
							textbox.hide()
							target_selected.emit(enemy)
				enemy._on_focus_entered = func ():
						enemy.cont.gui_input.connect(enemy._on_gui_input)
						enemy.cont.modulate.a = 1.0
				enemy._on_focus_exited = func ():
						disconnect_if_connected(enemy.cont.gui_input, enemy._on_gui_input)
						enemy.cont.modulate.a = 0.5
				enemy.cont.focus_entered.connect(enemy._on_focus_entered)
				enemy.cont.focus_exited.connect(enemy._on_focus_exited)
				
			enemies[0].cont.grab_focus()
			var target = await target_selected
			
			# Clean up once targeting is finished
			for enemy in enemies:
				enemy.cont.set_focus_mode(FOCUS_NONE)
				disconnect_if_connected(enemy.cont.focus_entered, enemy._on_focus_entered)
				disconnect_if_connected(enemy.cont.focus_exited, enemy._on_focus_exited)
				enemy.cont.modulate.a = 1.0   # Set opacity back to 100%
			for die in player_dice_hand:
				die.set_all_actions_selectable(true)
			
			return target
		
	draw_dice()

# Disconnect a function from a signal, does not throw an error if func is not connected.
func disconnect_if_connected(sig: Signal, cal: Callable):
	if not sig.is_connected(cal):
		return false
	sig.disconnect(cal)
	return true


func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")


func draw_dice():
	# Enemy draws their dice and displays their rolls first so the player has more info.
	for enemy in enemies:
		enemy.damage = roll_die(enemy.maxRoll)
		enemy.rollLabel.show()
		enemy.rollLabel.text = "%d" % enemy.damage
	
	for i in range(3): # Hardcoded temp hand size of 3
		if not player_dice_bag.size() > 0:
			display_text("Uh oh, all out of dice. Guess you're fucked.")
			await textbox_closed
			return
		
		var d = player_dice_bag.pop_back() # Draw die from bag
		print(d.name)
		var roll = roll_player_die(d)
		print(roll)
		print(" ")
		player_used_dice.append(d) # Discard used die
		
		var die = dieActionMenuPath.instantiate()
		die.find_child("Roll").text = "%d" % roll    # TODO: This doesn't tell you the kind of dice it is, juct the roll. This will need to be implemented in the die_action_menu scene
		
		#var drawnDie = DrawnDie.new(d, roll, die)
		var drawnDie = DrawnDie.new(roll, die)
		
		player_dice_hand.append(drawnDie)
		
		statusAndHandMenu.add_child(die)
		
	diceRemaining.text = "%d" % player_dice_bag.size()
		
		
# Prolly shouldn't be here. Also this is prolly a bad way to do this.
# If we use rng for rolls, we'll want to use a normal dist with mean set to what
# you would expect it to be for the given die.
# This method only exists for prototyping purposes. FIXME
func roll_die(max_roll):
	return (randi() % max_roll) + 1

func roll_player_die(die_object):
	var roll_options = die_object.sides
	var dice_roll = roll_options[randi() % roll_options.size()]
	return dice_roll
	
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
		playerDefense = damageHelper(playerDefense, enemy.damage)
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
		display_text("%s was defeated!" % enemy.name)
		await textbox_closed
		# TODO: temp enemy death anim.
		enemy.cont.queue_free()
		enemies.erase(enemy)
		if enemies.size() == 0:
			#display_text("You won you cheater! This is bullshit! I'm not playing anymore! *crashes game*")
			#await textbox_closed
			#await get_tree().create_timer(0.5).timeout
			#get_tree().quit()
			
			State.player_health = player_health
			display_text("You won! Now go to the campfire room")
			get_tree().change_scene_to_file("res://UI/campfire.tscn")
		
	emit_signal("damage_enemy_resolved")


func _on_ready_pressed():
	for die in player_dice_hand:
		if not die.itemSelected:
			display_text("Hold your horses! You need to select what to do with each of your die first!")
			await textbox_closed
			return
	
	display_text("To battle! dun dun dun!")
	await textbox_closed
	
	for enemy in enemies:
		enemy.rollLabel.hide()
	
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
