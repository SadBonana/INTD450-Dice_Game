class_name TextboxController extends Control

# TODO: Full on documentation. This thing will def need it to be useable by others.


@export var dialogue_res: DialogueRes

@onready var textbox := %Textbox
@onready var text := %Text
@onready var choices := %Choices
@onready var ticker := %Ticker

signal transitioned_from(from_beat: DialogueBeat, destination_beat: String, from_choice: int)

var dialogue_dict: Dictionary = {}

## Holds a reference to the dialogue beat being narrated.
##
## Usually, it is recommended not to set this manually. You shouldn't need to.
##
## CAUTION: When set, automatically sets _next_beat. If the current beat
## is marked as the end of the conversation, there is no next beat. If
## the current beat defines exactly one jump, then the next beat is the
## one with its unique_name given by the jump. If the number of jumps matches
## the number of choices, then _next_beat is set to "unknown" to signify
## that the next beat will be determined later (depending on the choice
## that gets clicked). Otherwise, the next beat is the next one in the
## array of beats in the resource file.
var _current_beat: DialogueBeat:
	set (beat):
		_current_beat = beat
		if beat.end_conversation:
			_next_beat = ""
		elif beat.jumps.size() == 1:
			_next_beat = beat.jumps[0]
		elif beat.jumps.size() != 0 and beat.jumps.size() == beat.choices.size():
			# Realistically, transition() should never be passed unknown.
			# the next beat should be known before transition is called,
			# even if _next_beat doesn't get updated as such.
			_next_beat = "unknown"
		else:
			var keys = dialogue_dict.keys()
			var pos = keys.find(beat.unique_name)
			if pos != -1 and pos != keys.size() - 1:
				_next_beat = keys[pos + 1]
			# Else you got issues m8

## When next() is called, _next_beat becomes the current_beat, which then gets
## narrated.
## This variable is safe to manually set as long as you do not set _current_beat
## afterwards, as doing so will override whatever you set _next_beat to.
var _next_beat: String

## Temp variable to allow the callback to be disconnected later.
var _on_transitioned_from: Callable


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the beats in the res file to a disctionary so they're easier
	# to access by name, also theoretically ensures names are unique.
	for beat in dialogue_res.beats:
		# CAUTION, FIXME: Probably does not enforce uniqueness
		# (will likely overwrite instead of throw an error). Test this later.
		dialogue_dict[beat.unique_name] = beat
		print(dialogue_dict[beat.unique_name].unique_name)
	
	textbox.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


## Ensures that the ticker is not shown when choices are, and vice versa.
func _set_choice_visibility(show_choices: bool):
	if show_choices:
		choices.show()
		ticker.hide()
	else:
		choices.hide()
		ticker.show()


# TODO: Consider making a func that will automatically decide the number of beats
# depending on whether the text fits in the textbox. All the beats created this way
# automatically advance.


# TODO: Maybe dubug() func for printing debug messages. Make the func ugly
# so people dont use it for normal text


# TODO: (must do): func quick_beat(dialogue_key, string_replacements, on_transitioned_from)


## 
## 
## 
func load_dialogue_chain(dialogue_key: String, on_transitioned_from: Callable = func (): return):
	_next_beat = dialogue_key
	_on_transitioned_from = on_transitioned_from
	transitioned_from.connect(on_transitioned_from)


## 
## 
## TODO: consider making this return the name of the beat it displayed.
func next(string_replacements = []):
	# Handle when there is no next dialogue beat.
	if not _next_beat:	#if _next_beat == "":
		return false
	
	# NOTE: Setting _current_beat also sets the next _next_beat
	_current_beat = dialogue_dict[_next_beat]
	textbox.show()
	
	# Configure textbox without choices
	if not _current_beat.choices.size() > 0:
		_set_choice_visibility(false)
		textbox.gui_input.connect(_on_textbox_gui_input)
		textbox.grab_focus()
	
	# Configure textbox with choices
	else:
		_set_choice_visibility(true)
		choices.clear()
		
		# Add choices to the ItemBox based on what is in the res file.
		for choice in _current_beat.choices:
			choices.add_item(choice)
		
		# TODO: Find a way to allow activating a list item by single-clicking without breaking controller support
		choices.item_activated.connect(_on_choice_chosen)
		choices.grab_focus()
	
	# Yeet the text the textbox
	if string_replacements.size() > 0:
		if string_replacements.size() == 1:
			string_replacements = string_replacements[0]	# I think godot gets mad if you pass an array with one element to a format string.
		text.text = _current_beat.text % string_replacements
	else:
		text.text = _current_beat.text
	
	await transitioned_from
	
	# If this is the last dialogue beat, cleanup the dialogue chain.
	if _current_beat.end_conversation:
		Helpers.disconnect_if_connected(transitioned_from, _on_transitioned_from)
	
	return true


## 
## 
## 
func transition(from_beat: DialogueBeat, destination_beat: String, from_choice:=-1):
	textbox.hide()
	assert(destination_beat != "unknown")	# FIXME: Someone might want to call their beat unknown. maybe add an _ or something
	#assert(not from_choice == -1 and )		# TODO: Document somewhere what -1 means
	
	# We have no destination beat if we came from the last beat.
	if not from_beat.end_conversation:
		assert(destination_beat in dialogue_dict)
	else:
		destination_beat = ""
	
	transitioned_from.emit(from_beat, destination_beat, from_choice)


# The following 2 callbacks are intentionally not connected to a signal by
# default
func _on_textbox_gui_input(event: InputEvent):
	if event.is_action_pressed("ui_accept") or event.is_action_released("click"):
		transition(_current_beat, _next_beat)

func _on_choice_chosen(index: int):
	if _next_beat == "unknown":
		_next_beat = _current_beat.jumps[index]
	transition(_current_beat, _next_beat, index)
