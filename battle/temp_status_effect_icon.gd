class_name TempSEIcon extends TextureButton


@onready var stack_text = %Stacks
'''
var strength: int = 1:
	set (value):
		strength = value
		text = _fstring % [TempSEIcon._to_rom_num(strength), remaining_turns]
'''
var stacks: int = 0:
	set (value):
		stacks = value
		#text = _fstring % [TempSEIcon._to_rom_num(strength), remaining_turns]
		stack_text.text = _fstring % [color,stacks]#[TempSEIcon._to_rom_num(stacks)]

var beneficial: bool
var color : String = "WHITE"
var effect: StatusEffect

#static var _fstring := "%s: %d"		# Strength (roman num): turns left
static var _fstring := "[left][color=%s]%s[/color][/left]" # stacks

## Loads, attaches to parent, and initializes required parameters all in one go.
static func instantiate(node_path: String, parent: Node, _effect: StatusEffect):
	var scene = load(node_path).instantiate()
	scene.effect = _effect
	parent.add_child(scene)
	scene.update()
	scene.beneficial = _effect.beneficial
	
	return scene

## Converting to roman numerals the dumbest way possible
static func _to_rom_num(number: int):
	match number:
		1: return "I"
		2: return "II"
		3: return "III"
		4: return "IV"
		5: return "V"
		6: return "VI"
		7: return "VII"
		8: return "VIII"
		9: return "IX"
		10: return "X"
		11: return "XI"
		12: return "XII"
		13: return "XIII"
		14: return "XIV"
		15: return "XV"
		16: return "XVI"
		17: return "XVII"
		18: return "XVIII"
		19: return "XIX"
		_: return "%d" % number


# Called when the node enters the scene tree for the first time.
func _ready():
	#text = _fstring % [TempSEIcon._to_rom_num(strength), stacks]
	stack_text.text = _fstring % [TempSEIcon._to_rom_num(stacks)]
	color = effect.color
	match effect._type:
		StatusEffect.EffectType.PARALYSIS:
			set_texture_normal(load("res://assets/textures/resources/elements/lightning.tres"))
		StatusEffect.EffectType.AUTODEFENSE:
			set_texture_normal(load("res://assets/textures/resources/elements/steel.tres"))
		StatusEffect.EffectType.IGNITED:
			set_texture_normal(load("res://assets/textures/resources/elements/fire.tres"))
		StatusEffect.EffectType.POISONED:
			set_texture_normal(load("res://assets/textures/resources/elements/poison.tres"))


func update():
	#strength = effect.strength
	stacks = effect.stacks


func _on_pressed():
	await effect.textbox.quick_beat(effect.description_beat)
	grab_focus()
