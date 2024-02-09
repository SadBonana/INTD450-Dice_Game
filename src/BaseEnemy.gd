extends Resource

@export var name: String = "Enemy"
@export var texture: Texture = null
@export var health: int = 30

@export var dice_caps: Array = [3,3,3,3,3,4,4,6,3,3]
#@export var dice: Array = Die.to_dice([3,3,3,3,3,4,4,6,3,3]) # Seems like this won't work...
