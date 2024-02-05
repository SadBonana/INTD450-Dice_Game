extends Control

@export var enemy: Resource = null

# Player Panel
@export var playerHealthBar: ProgressBar
@export var playerStatusContainer: HBoxContainer
@export var dieActionMenu: VBoxContainer
@export var statusAndHandMenu: HBoxContainer

# Textbox
@export var textbox: Panel
@export var textboxLabel: Label


var dieActionMenuPath = load("res://die_action_menu.tscn")


signal textbox_closed
signal damage_enemy_resolved

var player_health = 0
var enemy_health = 0

var player_dice_bag = []
var player_used_dice = []
var player_dice_hand = []

enum DieActions {ATTACK, DEFEND, REROLL}

class DrawnDie:
	var maxRoll: int
	var roll: int
	var actionMenu: ItemList
	var dieActionMenu: VBoxContainer
	var selectedAction: DieActions 
	# TODO: Keep track of targetted enemy for attack action
	
	func _init(maxR, actual, menu):
		maxRoll = maxR
		roll = actual
		dieActionMenu = menu
		actionMenu = dieActionMenu.find_child("Die Actions")
		
		actionMenu.item_selected.connect(func (index):
			selectedAction = index
			# TODO: Need different logic for reroll, as it stands none of these actions do anything
			# until the player ends their turn, so the rerolled die would only be available next
			# turn... which could be interesting but wasn't what I envisioned previously.
		)


# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await textbox_closed
	$ActionsPanel.show()
	
	draw_dice()
	
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")
	
func draw_dice():
	# TODO: Null check for when the bag runs out of dice.
	for i in range(3): # Hardcoded temp hand size of 3
		var d = player_dice_bag.pop_back() # Draw die from bag
		var roll = roll_die(d)
		player_used_dice.append(d) # Discard used die
		var die = dieActionMenuPath.instantiate()
		die.find_child("Roll").text = "%d" % roll    # TODO: This doesn't tell you the kind of dice it is, juct the roll. This will need to be implemented in the die_action_menu scene
		
		var drawnDie = DrawnDie.new(d, roll, die)
		player_dice_hand.append(drawnDie)
		
		statusAndHandMenu.add_child(die)
		
		
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
func damageEnemy(damage):
	display_text("Attacking! dun dun dun!")
	await textbox_closed
	
	enemy_health = max(0, enemy_health - damage)
	set_health($EnemyContainer/ProgressBar, enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	display_text("Dealt %d damage!" % damage)
	await textbox_closed
	
	if enemy_health == 0:
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
				damageEnemy(die.roll)
				await damage_enemy_resolved # FIXME: There must be a better way to synchronize the textbox than putting a million await textbox_closed everywhere.
			DieActions.DEFEND:
				player_defense += die.roll
			DieActions.REROLL:
				#TODO: Implement, but prolly not here. See the TODO in the connect func call in the DrawnDie class
				pass
		die.dieActionMenu.queue_free()
	player_dice_hand.clear()
	enemy_turn(player_defense)
