extends InvDieFrame
class_name DrawnDie

@onready var element_icon = %ElementIcon

## paths to the styleboxes we need
var focused_press_path : StyleBox = preload("res://battle/drawn_die/styles/button_battle_focused_pressed.tres")
var pressed_path : StyleBox = preload("res://battle/drawn_die/styles/button_battle_pressed.tres")
## name of the styleboxes we wish to change
var pressed_style = "pressed"
var normal_style = "normal"
var is_paused : bool = false


signal target_selected(drawndie)
signal target_unselected(drawndie)

var data: DrawnDieData:
		set (ddd):
			data = ddd
			side = ddd.side
			die_ref = ddd.die
			die_visual.texture = ddd.die.texture
			element_icon.texture = side.element.icon
			
var side : DieSide:
		set (side):
			data.side = side
			die_type.text = "%d" % (max(side.value + mod,0))
			# Set the color based on the effect of the side.
			var new_stylebox_normal = get_theme_stylebox(normal_style).duplicate()
			new_stylebox_normal.bg_color = side.element.color
			add_theme_stylebox_override(normal_style, new_stylebox_normal)
		get:
			return data.side
var roll: int:
		set (value):
			assert(false, "attempt to directly set roll of a DrawnDie object. Set the dieside instead")
		get:
			return max(side.value + mod, 0)
var effect: StatusEffect.EffectType:
		set (value):
			assert(false, "attempt to directly set roll of a DrawnDie object. Set the dieside instead")
		get:
			return side.element.effect
var selected_action: DrawnDieData.DieActions:
		set (which):
			data.action = which
		get:
			return data.action
var target: BattleActor:
		set (who):
			data.target = who
		get:
			return data.target
var die: Die:
		set (whatnow):
			assert(false, "attempt to directly set die of a DrawnDie object. Set the data instead")
		get:
			return die_ref
var is_toggled: bool
var mod : int = 0:
	set (value):
		die_type.text = "%d" % (max(side.value + mod,0))


## Loads, attaches to parent, and initializes required parameters all in one go.
static func instantiate(node_path: String, parent: Node, _die: Die, battle_context: Battle):
	var scene = load(node_path).instantiate()
	parent.add_child(scene)
	scene.data = DrawnDieData.new(_die, battle_context.player, battle_context)
	

	return scene
	
func _notification(what):
	match what:
		NOTIFICATION_PAUSED:
			reset_z_ordering()
			is_paused = true
		NOTIFICATION_UNPAUSED:
			is_paused = false
			

func _ready():
	var parent = get_parent()
	if parent.has_method("add_to_dice_with_targets"):
		target_selected.connect(parent.add_to_dice_with_targets)
	if parent.has_method("remove_from_dice_with_targets"):
		target_unselected.connect(parent.remove_from_dice_with_targets)
	mouse_entered.connect(_change_info_box)
	focus_entered.connect(_change_info_box)


## called when the player selects a die in their hand. allows player to target actors.
func _on_toggled(toggled_on):
	is_toggled = toggled_on
	target = null
	var targets = []
	var all_entities = []
	all_entities = data.battle.enemies.duplicate()
	targets = data.battle.enemies.duplicate()
	if self.side.element is Steel:
		for enemy in targets:
			enemy.should_dim(true)
		targets.clear()
	targets.append(data.battle.player)
	all_entities.append(data.battle.player)
	if toggled_on:
		#get_node("/root/SoundManager/select").play()
		SoundManager.select_sfx.play()
		make_focused_pressed()
		disable_untargetables(true, self)

		#await data.battle.textbox_controller.quick_beat("targeting instructions")

		# Set targeting callback and give the player visual queues for targeting
		for option in targets:
			option.toggle_target_mode(true, data.battle.target_selected)
		
		# Default to targetting the player if it's autodefense, because autodefense is a buff.
		if effect == StatusEffect.AUTODEFENSE:
			targets[-1].grab_focus()
		else:
			targets[0].grab_focus()
		
		target = await data.battle.target_selected
		for enemy in data.battle.enemies:
			enemy.should_dim(false)
		selected_action = data.ATTACK if target is BattleEnemy else data.DEFEND
		
		make_pressed()
		## emits a signal that we want the container to catch
		if(target):
			target_selected.emit(self)
		# Clean up once targeting is finished
		for option in targets:
			option.toggle_target_mode(false, data.battle.target_selected)
		
		disable_untargetables(false)
		
		# After targeting is finished, focus on the next thing the player is likely to want to be in focus.
		var found_next_focus_item = false
		if not get_parent().is_max():
			for i in range(data.battle.player.dice_hand.size()):
				if not data.battle.player.dice_hand[i].is_toggled:
					found_next_focus_item = true
					data.battle.player.dice_hand[i].grab_focus()
					break
		if not found_next_focus_item:
			data.battle.ready_button.grab_focus()
	else:
		#get_node("/root/SoundManager/alt_select").play()
		SoundManager.alt_select_sfx.play()
		disable_untargetables(false)
		for option in all_entities:
			option.toggle_target_mode(false, data.battle.target_selected)
		target = null
		target_unselected.emit(self)
		get_parent().enable_all_dice()


## A function that changes the style box of the drawn_die
## in order to make it clear what die is currently selected
## effectively mimics what focus does visually
func make_focused_pressed():
	button.remove_theme_stylebox_override(pressed_style)
	button.add_theme_stylebox_override(pressed_style, focused_press_path)
	var new_stylebox_pressed = get_theme_stylebox(pressed_style)
	new_stylebox_pressed.bg_color = side.element.color

## A function that changes the style box of the drawn_die
## once it is no longer the selected die
func make_pressed():
	button.remove_theme_stylebox_override(pressed_style)
	button.add_theme_stylebox_override(pressed_style, pressed_path)

## makes it so that you can back out of enemy selection using esc
func _input(event):
	if event.is_action_pressed("close"):
		if(is_toggled and target == null):
			button_pressed = false
			grab_focus()
			data.battle.target_selected.emit(null)
			
func _change_info_box():
	if not is_paused:
		data.battle.side_info.get_current_tab_control().new_frames([side])
			

## A function to disable menus during target selection
func disable_untargetables(disable : bool, button_clicked : Button=null):
	for child in data.battle.action_menu.get_children():
		child.disabled = disable
		if disable:
			child.focus_mode = FOCUS_NONE
		else:
			child.focus_mode = FOCUS_ALL
	data.battle.player_status.bag_button.disabled = disable
	if disable:
		data.battle.player_status.bag_button.focus_mode = FOCUS_NONE
	else:
		data.battle.player_status.bag_button.focus_mode = FOCUS_ALL
	for button in data.battle.drawn_die_container.get_children():
		
		if button != button_clicked:
			button.disabled = disable
		if disable:
			button.focus_mode = FOCUS_NONE
		else:
			get_parent().disable_die(button)
			button.focus_mode = FOCUS_ALL


## Set this drawn die to display on top of the others. Dice further from this die
## in the dice hand will be beneath closer ones.
func bring_to_front():
	var hand = data.battle.player.dice_hand
	var indx_in_hand = hand.find(self)
	for index in range(hand.size()):
		hand[index].z_index = hand.size() - abs(indx_in_hand - index)


## After calling this, drawn dice will overlap however godot feels like making them overlap.
## AKA, reset the drawn die overlap behavior to default.
func reset_z_ordering():
	if data != null: #check that its not null
		for d in data.battle.player.dice_hand:
			d.z_index = 0


func _on_focus_entered():
	if not is_paused:
		bring_to_front()

func _on_focus_exited():
	if not is_paused:
		reset_z_ordering()

func _on_mouse_entered():
	if not is_paused:
		bring_to_front()

func _on_mouse_exited():
	if not is_paused:
		reset_z_ordering()
