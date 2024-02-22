class_name DialogueRes extends Resource

@export var beats: Array[DialogueBeat]

## no idea if this will do what i want it to.
#func _init():
	#for entry in entries:
		#var count = entries.reduce(func (accum, ent):
				#return accum + 1 if ent.unique_name == entry.unique_name else 0, 0)
		#assert(count == 1)
