@tool
class_name DialogueBeat extends Resource

## NOTE: uniqueness not enforced at compile time, but will cause a crash
## when you try to feed it to the textbox node
@export var unique_name: String:		# TODO: maybe use StringName instead
		set (nombre):
			resource_name = nombre
			unique_name = nombre

## Rich text, supports BBCodes
@export_multiline var text: String

## Array of dialogue beats to jump to. If the array is empty, the next
## dialogue beat will be the next one in the dialogue resource file. If
## there is only one jump in the array, then the next dialogue beat will be
## the one whose name matches the jump. If the number of jumps equals the
## number of choices, each jump will correspond to a choice at the same index
## in the choices array.
@export var jumps: Array[String]

## The order of these choices corresponds to their order in the dialogue box.
## first item will have the text of the first element in this array.
@export var choices: Array[String]

## Indicates that this is the last entry in a chain of textbox dialogues.
## If set, the textbox will close and the next entry below will not be
## displayed.
@export var end_conversation := false
