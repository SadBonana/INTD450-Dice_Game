class_name TempSEIcon extends Button

# prolly temp: TODO: make classes/seperate scenes for each icon or something idk.
@export var par: AtlasTexture
@export var ign: AtlasTexture
@export var def: AtlasTexture
@export var poi: AtlasTexture



var strength: int = 1:
	set (value):
		strength = value
		#text = _fstring % [TempSEIcon._to_rom_num(strength), remaining_turns]
		text = _fstring % [remaining_turns]
var remaining_turns: int = 0:
	set (value):
		remaining_turns = value
		#text = _fstring % [TempSEIcon._to_rom_num(strength), remaining_turns]
		text = _fstring % [remaining_turns]
var beneficial: bool
var color: Color
var effect: StatusEffect

#static var _fstring := "%s: %d"		# Strength (roman num): turns left
static var _fstring := "%d"

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
	text = _fstring % [TempSEIcon._to_rom_num(strength), remaining_turns]
	match effect._type:
		StatusEffect.EffectType.PARALYSIS:
			#self_modulate = Color.YELLOW
			#icon.region = Rect2(0, 0, 16, 16)	# 8c3cee
			icon = par
			add_theme_color_override("font_color", Color("#8c3cee"))
		StatusEffect.EffectType.AUTODEFENSE:
			#self_modulate = Color.GRAY
			#icon.region = Rect2(0, 96, 16, 16) # 9db3bf
			icon = def
			add_theme_color_override("font_color", Color("#9db3bf"))
		StatusEffect.EffectType.IGNITED:
			#self_modulate = Color.DARK_RED
			#icon.region = Rect2(0, 32, 16, 16) # a90909
			icon = ign
			add_theme_color_override("font_color", Color("#a90909"))
		StatusEffect.EffectType.POISONED:
			#self_modulate = Color.WEB_PURPLE
			#icon.region = Rect2(0, 64, 16, 16) # 239063
			icon = poi
			add_theme_color_override("font_color", Color("#239063"))


func update():
	strength = effect.strength
	remaining_turns = effect.remaining_turns


func _on_pressed():
	await effect.textbox.quick_beat(effect.description_beat)
	grab_focus()
