extends Resource
class_name BaseEncounter

@export var enemies: Array[BaseEnemy]: get = get_enemies

func get_enemies():
	return enemies
