class_name TempSEIcon extends Button

@export var def_icon: AtlasTexture
@export var par_icon: AtlasTexture
@export var ign_icon: AtlasTexture
@export var poi_icon: AtlasTexture

#@onready var stack_text = %Stacks
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
		text = _fstring % [stacks]#[TempSEIcon._to_rom_num(stacks)]

var beneficial: bool
var color : String = "WHITE"
var effect: StatusEffect

static var _fstring := "%d" # stacks

## Loads, attaches to parent, and initializes required parameters all in one go.
static func instantiate(node_path: String, parent: Node, _effect: StatusEffect):
	var scene = load(node_path).instantiate()
	scene.effect = _effect
	parent.add_child(scene)
	scene.update()
	scene.beneficial = _effect.beneficial
	
	return scene


# Called when the node enters the scene tree for the first time.
func _ready():
	color = effect.color
	match effect._type:
		StatusEffect.EffectType.PARALYSIS:
			#set_texture_normal(load("res://assets/textures/resources/elements/lightning.tres"))
			icon = par_icon
		StatusEffect.EffectType.AUTODEFENSE:
			#set_texture_normal(load("res://assets/textures/resources/elements/steel.tres"))
			icon = def_icon
		StatusEffect.EffectType.IGNITED:
			#set_texture_normal(load("res://assets/textures/resources/elements/fire.tres"))
			icon = ign_icon
		StatusEffect.EffectType.POISONED:
			#set_texture_normal(load("res://assets/textures/resources/elements/poison.tres"))
			icon = poi_icon
	add_theme_color_override("font_color", Color(color))


func update():
	#strength = effect.strength
	stacks = effect.stacks


func _on_pressed():
	await effect.textbox.quick_beat(effect.description_beat)
	grab_focus()
