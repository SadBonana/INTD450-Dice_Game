class_name BaseEnemy extends Resource

@export var name: String = "Enemy"	# NOTE: Could be confused with the godot built in name property, consider renaming.
@export var texture: Texture = null
@export var health: int = 30
@export var dice_draws: int = 2		# Number of dice to draw from bag in a turn

## Modulate the sprites color. White means the color will not be changed (it doesnt actually make it white-er)
@export var sprite_color: Color = Color.WHITE

@export var dice: Array[Die]
