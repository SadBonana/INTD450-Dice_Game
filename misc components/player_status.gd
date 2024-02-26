extends VBoxContainer

# NOTE: exporting these nodes this ways has weird behavior if you try to instantiate multiple Player Statuses in a single scene
# Only the first scene instance will have valid references to whateber you set these exports to in this scene, the others will be as if they were not set
# The way around this is by either setting this scene's children as editable and dragging them to the export panel evey time,
# or by setting these in the _ready function instead. See battle_enemy.gd for an example of this.
@export var health_bar: ProgressBar
@export var deck_status: Label

static var deck_f_string = "Dice: %d/%d"

# I wonder if it would be better to have a class for the in-battle dice bag so we can just do .size() for dice remaining as well and then use callbacks for when dice are added or removed...
var dice_remaining: int:
	set (value):
		dice_remaining = value
		deck_status.text = deck_f_string % [dice_remaining, PlayerData.dice_bag.size()]

# Called when the node enters the scene tree for the first time.
func _ready():
	dice_remaining = PlayerData.dice_bag.size()
	health_bar.value = PlayerData.hp
	health_bar.max_value = PlayerData.hp_max
	PlayerData.hp_changed.connect(_on_hp_changed)
	PlayerData.hp_max_changed.connect(_on_hp_max_changed)


func _on_hp_changed(value):
	health_bar.value = value


func _on_hp_max_changed(value):
	health_bar.max_value = value
