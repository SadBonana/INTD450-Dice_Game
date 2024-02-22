class_name BattleEnemy extends VBoxContainer

@onready var health_bar: ProgressBar = %ProgressBar
@onready var tex_rect: TextureRect = %Enemy
@onready var roll_label: Label = %Roll  # FIXME: Displaying the enemy's roll over their sprite is prolly not what we want the final game to look like. I thought the empty top panel was where we'd show that info, but I'm running out of energy now so...
@onready var animation_player = %AnimationPlayer

@export var res: Resource


# TODO: Make variable names consistent with PlayerData, e.g. hp vs health
var dice_bag = []
var used_dice = []
#var dice_hand  # For when enemies can eventually defend and use dice effects
var health: int:
	set (value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
var max_health: int:
	set (value):
		max_health = value
		health_bar.max_value = value
var damage: int:
	set (value):
		damage = value
		roll_label.text = "%d" % damage
var defense: int:
	set (value):
		defense = max(0, value)
var enemy_name

var _usual_alpha = modulate.a


# Called when the node enters the scene tree for the first time.
func _ready():
	restore_sprite_color()
	roll_label.hide()
	max_health = res.health
	health = res.health
	enemy_name = res.name
	
	# Initialize enemy dice bag
	var dice_caps = res.dice_caps.duplicate()
	dice_caps.shuffle()
	dice_bag = Die.to_dice(dice_caps)
	
	# set texture
	tex_rect.texture = res.texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Will likely need to be rewritten once effect die and enemies defending become a thing.
func draw_dice(num_to_draw, textbox: TextboxController):
	damage = 0
	for i in range(num_to_draw):
		# Whatever we decide to do when the enemy runs out of dice, it'll be here
		if not dice_bag.size() > 0:
			#display_text("Hurray! Enemies out of dice, now you can have your way with them!")
			#await textbox_closed
			textbox.load_dialogue_chain('enemy out of dice')
			textbox.next([enemy_name])
			#print("enemy is out of dice, but can't use the textbox display function the way this is written.")
			return
		var d = dice_bag.pop_back()
		used_dice.append(d)
		damage += d.roll()
	
	roll_label.show()


func toggle_target_mode(player_is_targeting: bool, target_selected: Signal):
	# Init logic for player to target enemies
	if player_is_targeting:
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


## All logic involved with taking damage
##
## Adjusts damage based on defense, adjusts defense, plays animation,
## reduces health.
##
## Return whether the enemy is killed after taking damage.
func take_damage(damage: int):
	var damage_after_defense = Helpers.clamp_damage(damage, defense)
	defense -= damage
	health -= damage_after_defense
	
	animation_player.play("Hurt")
	await animation_player.animation_finished
	
	return true if health == 0 else false


## Restore the texture rect's self_modulate property to res.sprite_color
##
## AnimationPlayer doesnt work well with dynamic or unknown keyframe values,
## hence why restore_sprite_color() is needed, in case someone wants an enemy
## with a self modulate alpha value set to something less than 1. E.g. maybe
## they made an opaque ghost sprite and wanted to use a ghost resource file to
## change the opacity in godot. Without restore_sprite_color(), the ghost will
## permanently lose its transparency after the hurt animation plays. The only
## other solution is to use Tweens, which cannot be seen in the editor like the
## AnimationPlayer can.
func restore_sprite_color():
	tex_rect.self_modulate = res.sprite_color


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
		if event.is_action_pressed("ui_accept"):
			target_selected.emit(self)



