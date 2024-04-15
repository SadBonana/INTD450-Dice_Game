class_name BattleActor extends VBoxContainer

#const damage_indication = preload("res://battle/damage_indicator/damage_indicator.tscn")
@onready var damage_indication := $damage_indicator
@onready var damage_animation := $damage_indicator/damage_animation

@export_file("*.tscn") var status_effect_scene_path
@export var enable_textboxes := false
var textbox: TextboxController

var status_effects: Array[StatusEffect] = []
var dice_bag = []
var used_dice = []
var dice_hand = []

var health: int: set = _set_health, get = _get_health
func _set_health(value):
	pass
func _get_health():
	pass

var defense: int:
	set (value):
		defense = max(0, value)
		shield_manager(defense)
var dice_draws: int:	## Number of dice to draw from bag every turn
	set (value):
		dice_draws = max(0, value)
var dice_choices: int:	## Number of dice to pick from hand every turn
	set (value):
		dice_choices = max(0, value)
var actor_name: String		# NOTE: we could consider uncommenting this and allowing the player to have a custom name



var on_defeat: Callable

var _usual_alpha = modulate.a

@onready var status_container := %"Status Effects"
@onready var tex_rect: TextureRect = %"Actor Sprite"
@onready var animation_player := %AnimationPlayer
@onready var status_backdrop := %PanelContainer
@onready var shield := %Shield

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func add_status_effect(effect: StatusEffect):
	status_backdrop.show()
	status_effects.append(effect)
	TempSEIcon.instantiate(status_effect_scene_path, status_container, effect)
	update_status_effects()	# Mainly for sorting.


## Removes the effect from the array, also removes the icon from the scene.
func remove_status_effect(effect: StatusEffect):
	status_effects.erase(effect)
	for effect_icon in status_container.get_children():
		if effect_icon.effect == effect:
			effect_icon.queue_free()
	if status_effects.size() == 0:
		status_backdrop.hide()


# called when status effects have changed and we want to display the changed values to the player
# If the remaining turns, strength/stacks changes... maybe if the sorting should change too...
func update_status_effects():
	# Sort the icons: buffs first, then debuffs, effects with the least remaining
	# turns first, then tie break by strength
	status_effects.sort_custom(func (effect1, effect2):
		if effect1.beneficial and not effect2.beneficial:
			return true
		if (not effect1.beneficial) and effect2.beneficial:
			return false
		if effect1.stacks < effect2.stacks:
			return true
		if effect1.stacks > effect2.stacks:
			return false
		if effect1.stacks > effect2.stacks:
			return true
		return false
	)
	for effect_icon in status_container.get_children():
		var index = status_effects.find(effect_icon.effect)
		status_container.move_child(effect_icon, index)
		effect_icon.update()


## All logic involved with taking damage
##
## Adjusts damage based on defense, adjusts defense, plays animation,
## reduces health.
##
## Return the damage taken after accounting for defense
func take_damage(damage: int, beligerent_name: String) -> int:
	
	damage_indication.visible = true
	
	var damage_after_defense = Helpers.clamp_damage(damage, defense)
	defense -= damage
	shield_manager(defense)
	var prev_health = health
	
	spawn_damage_indicator(damage_after_defense)
	health -= damage_after_defense
	
	animation_player.play("Hurt")
	await animation_player.animation_finished
	
	damage_indication.visible = false
	
	if enable_textboxes:
		await textbox.quick_beat("deal damage", [beligerent_name, damage_after_defense])
	
	if health == 0 and prev_health != 0:
		await on_defeat.call()
	
	return damage_after_defense


# Can be used later for fancier enemy decision making
## Mostly just for enemies
func commit_dice():
	pass


func draw_dice():
	pass


## Restore the texture rect's self_modulate property to res.sprite_color
##
## AnimationPlayer doesnt work well with dynamic or unknown keyframe values,
## hence why restore_sprite_color() is needed, in case someone wants an actor
## with a self modulate alpha value set to something less than 1. E.g. maybe
## they made an opaque ghost sprite and wanted to use a ghost resource file to
## change the opacity in godot. Without restore_sprite_color(), the ghost will
## permanently lose its transparency after the hurt animation plays. The only
## other solution is to use Tweens, which cannot be seen in the editor like the
## AnimationPlayer can.
func restore_sprite_color():
	pass


# NOTE: with the way this works, we could easily uncomment this and have the player capable of targeting
# their self, though a few places elsewhere would need to be modified, it wouldn't be much.
func toggle_target_mode(player_is_targeting: bool, target_selected: Signal):
	
	# Init logic for player to target enemies
	if player_is_targeting:
		#target_selected.target.progress_bar.value = die.target.health_bar.value - die.roll
		
		modulate.a = _usual_alpha / 2	# Set unfocused alpha
		set_focus_mode(FOCUS_ALL)	# Enable focus
		
		# Set the _on_gui_input func so we can connect the _on_focus...
		_on_gui_input_factory(target_selected)
		
		# Connect callbacks
		focus_entered.connect(_on_focus_entered)
		focus_exited.connect(_on_focus_exited)
	# Cleanup now that targeting is finished
	else:
		set_focus_mode(FOCUS_NONE)	# Disable focusing
		
		# Disconnect callbacks
		Helpers.disconnect_if_connected(focus_entered, _on_focus_entered)
		Helpers.disconnect_if_connected(focus_exited, _on_focus_exited)
		
		modulate.a = _usual_alpha	# Restore alpha


# More targetting stuff, if we want to be able to target the player, will move the logic from
# BattleEnemy to here and then tweak some things.
var _on_gui_input: Callable

# NOTE: The 2 callback funcs below are intentionally not connected by default
func _on_focus_entered():
	gui_input.connect(_on_gui_input)
	modulate.a = _usual_alpha

func _on_focus_exited():
	Helpers.disconnect_if_connected(gui_input, _on_gui_input)
	modulate.a = _usual_alpha / 2

## Generates a gui_input callback that will emit the given
## target_selected signal when the gui_input signal is received with a
## ui_accept event.
func _on_gui_input_factory(target_selected: Signal):
	_on_gui_input = func (event: InputEvent):
		if event.is_action_pressed("ui_accept") or event.is_action_released("click"):
			target_selected.emit(self)
			
func set_shield_string(value : int):
	shield.text = "Shield: " + str(value)
func show_shield_string(show : bool):
	shield.visible = show

func should_dim(dim : bool):
	if dim:
		modulate.a = _usual_alpha / 2
	else:
		modulate.a = _usual_alpha
	
func shield_manager(value: int):
	set_shield_string(value)
	if (value <= 0):
		show_shield_string(false)
	else:
		show_shield_string(true)


func spawn_damage_indicator(damage: int):
	damage_indication.label.text = str(damage)
	
	damage_animation.play("show_damage")
	await animation_player.animation_finished
	#await damage_animation.animation_finished
	
	damage_animation.play("RESET")
	await animation_player.animation_finished
	#await damage_animation.animation_finished
