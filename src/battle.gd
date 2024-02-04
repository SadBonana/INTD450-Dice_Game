extends Control

@export var enemy: Resource = null

# Player Panel
@export var playerHealthBar: ProgressBar
@export var playerStatusContainer: HBoxContainer

# Textbox
@export var textbox: Panel
@export var textboxLabel: Label

signal textbox_closed

var player_health = 0
var enemy_health = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	set_health(playerHealthBar, State.player_health, State.player_health_max)
	$EnemyContainer/Enemy.texture = enemy.texture
	
	player_health = State.player_health
	enemy_health = enemy.health
	
	textbox.hide()
	$ActionsPanel.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await textbox_closed
	$ActionsPanel.show()
	
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $Textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")
	
func display_text(text):
	textbox.show()
	textboxLabel.text = text
	
func set_health(progress_bar, hp, hp_max):
	progress_bar.value = hp
	progress_bar.max_value = hp_max
	progress_bar.get_node("Label").text = "hp: %d/%d" % [hp, hp_max]
	
func enemy_turn():
	display_text("Oh noes! %s is coming for you!" % enemy.name)
	await textbox_closed
	
	player_health = max(0, player_health - enemy.damage)
	set_health(playerHealthBar, player_health, State.player_health_max)
	
	#$AnimationPlayer.play("enemy_damaged")   #TODO: Make a temp player hurt anim... need a godot logo for the player first...
	#await $AnimationPlayer.animation_finished
	
	display_text("%s dealt %d damage!" % [enemy.name, enemy.damage])
	await textbox_closed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_run_pressed():
	display_text("You coward! Execute game crash!")
	await textbox_closed
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_attack_pressed():
	display_text("Attacking! dun dun dun!")
	await textbox_closed
	
	enemy_health = max(0, enemy_health - State.player_damage)
	set_health($EnemyContainer/ProgressBar, enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	display_text("Dealt %d damage!" % State.player_damage)
	await textbox_closed
	
	if enemy_health == 0:
		display_text("%s was defeated! This is bullshit! I'm not playing anymore! *crashes game*" % enemy.name)
		await textbox_closed
		# TODO: temp enemy death anim. 
		
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
	
	enemy_turn()


func _on_roll_pressed():
	pass # Replace with function body.
