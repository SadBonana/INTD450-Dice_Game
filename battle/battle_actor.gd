class_name BattleActor extends VBoxContainer

@export_file("*.tscn") var status_effect_scene_path
#@export var textbox: TextboxController
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
var dice_draws: int:	## Number of dice to draw from bag every turn
	set (value):
		dice_draws = max(0, value)
var actor_name: String		# NOTE: we could consider uncommenting this and allowing the player to have a custom name



var on_defeat: Callable

var _usual_alpha = modulate.a

@onready var status_container := %"Status Effects"
@onready var tex_rect: TextureRect = %"Actor Sprite"
@onready var animation_player := %AnimationPlayer
@onready var status_backdrop := %PanelContainer

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
		if effect1.remaining_turns < effect2.remaining_turns:
			return true
		if effect1.remaining_turns > effect2.remaining_turns:
			return false
		if effect1.strength > effect2.strength:
			return true
		return false
	)
	for effect_icon in status_container.get_children():
		var index = status_effects.find(effect_icon.effect)
		status_container.move_child(effect_icon, index)
		effect_icon.update()
	
	
	## DEBUG:	TODO: remove:
	#print("effect order:")
	#for effect in status_effects:
		#print("type:", effect._type, "turns:", effect.remaining_turns, "strength:", effect.strength)


## All logic involved with taking damage
##
## Adjusts damage based on defense, adjusts defense, plays animation,
## reduces health.
##
## Return the damage taken after accounting for defense
func take_damage(damage: int, beligerent_name: String) -> int:
	var damage_after_defense = Helpers.clamp_damage(damage, defense)
	defense -= damage
	## doing it like this should prevent attempts to call on_defeated multiple times:
	#var defeated = (health - damage_after_defense <= 0 and health != 0)
	var prev_health = health
	health -= damage_after_defense
	
	animation_player.play("Hurt")
	await animation_player.animation_finished
	
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
#func toggle_target_mode(player_is_targeting: bool, target_selected: Signal):
	## Init logic for player to target enemies
	#if player_is_targeting:
		#modulate.a = _usual_alpha / 2	# Set unfocused alpha
		#set_focus_mode(FOCUS_ALL)	# Enable focus
		#
		## Set the _on_gui_input func so we can connect the _on_focus...
		#_on_gui_input_factory(target_selected)
		#
		## Connect callbacks
		#focus_entered.connect(_on_focus_entered)
		#focus_exited.connect(_on_focus_exited)
		#
	## Cleanup now that targeting is finished
	#else:
		#set_focus_mode(FOCUS_NONE)	# Disable focusing
		#
		## Disconnect callbacks
		#Helpers.disconnect_if_connected(focus_entered, _on_focus_entered)
		#Helpers.disconnect_if_connected(focus_exited, _on_focus_exited)
		#
		#modulate.a = _usual_alpha	# Restore alpha


# More targetting stuff, if we want to be able to target the player, will move the logic from
# BattleEnemy to here and then tweak some things.
#var _on_gui_input: Callable
#
## NOTE: The 2 callback funcs below are intentionally not connected by default
#func _on_focus_entered():
	#gui_input.connect(_on_gui_input)
	#modulate.a = _usual_alpha
#
#func _on_focus_exited():
	#Helpers.disconnect_if_connected(gui_input, _on_gui_input)
	#modulate.a = _usual_alpha / 2
#
### Generates a gui_input callback that will emit the given
### target_selected signal when the gui_input signal is received with a
### ui_accept event.
#func _on_gui_input_factory(target_selected: Signal):
	#_on_gui_input = func (event: InputEvent):
		#if event.is_action_pressed("ui_accept") or event.is_action_released("click"):
			#target_selected.emit(self)


