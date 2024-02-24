extends BaseEncounter
class_name EncounterTable

@export var novice_encounters: Array[BaseEncounter]
@export var standard_encounters: Array[BaseEncounter]
@export var expert_encounters: Array[BaseEncounter]


func get_enemies():
	match PlayerData.difficulty:
		PlayerData.Difficulty.NOVICE:
			return novice_encounters.pick_random().enemies
		PlayerData.Difficulty.STANDARD:
			return standard_encounters.pick_random().enemies
		PlayerData.Difficulty.EXPERT:
			return expert_encounters.pick_random().enemies
