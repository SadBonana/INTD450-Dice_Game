class_name TextboxController extends Control

## Controls when and what a textbox will display.
##
## To use, make a .tres file using dialogue_res.gd, then use the inspector panel
## to add dialogue beats to the array. Make sure to give each dialogue beat a
## unique name. See dialogue_beat.gd for descriptions of what each property does.
## Here's a rundown: Jumps contains a list of beat's unique names to jump to,
## you can leave it blank if you just want to go to the next dialogue beat in
## the dialogue_res array, or if you want to skip a few beats or assign differnt
## jumps to different choices, you can to the jumps array. Choices is an array
## containing the text to display for each choice. Leave it blank if you don't
## want choices. If end conversation is checked, then you won't go to the next
## dialogue beat by accident when you call next(). Once the .tres file with all
## the dialogue is made, add a TextboxController node to the scene you want the
## textbox in and position it where you want the textbox to appear. After,
## click the TextboxController node you just added in the scene hierarchy, then
## click and drag the .tres file you made over to the Dialogue Res field in the
## inspector. Now, in your scene's main script, call
## TextboxController.load_dialogue_chain() and pass it the name of the first
## beat you want it to narrate, then call next() to narrate it.

## Emitted after a dialogue beat is dismissed.
##
## from_beat:
##		The dialogue beat just dismissed
## destination_beat:
##		The name of the beat to be narrated on the next call to next()
## from_choice:
##		The index of the choice taken on the beat that was just dismissed.
##		-1 if there were no choices in the last dialogue beat.
signal transitioned_from(from_beat: DialogueBeat, destination_beat: String, from_choice: int)

## Contains all the dialogue beats that will show up in a given textbox. Different
## textboxes will have different dialogue resources. 
@export var dialogue_res: DialogueRes


## Holds a reference to the dialogue beat being narrated.
##
## Usually, it is recommended not to set this manually. You shouldn't need to.
##
## CAUTION: When set, automatically sets _next_beat. If the current beat
## is marked as the end of the conversation, there is no next beat. If
## the current beat defines exactly one jump, then the next beat is the
## one with its unique_name given by the jump. If the number of jumps matches
## the number of choices, then _next_beat is set to "_unknown" to signify
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
			# Realistically, _transition() should never be passed _unknown.
			# the next beat should be known before _transition is called,
			# even if _next_beat doesn't get updated as such.
			_next_beat = "_unknown"
		else:
			var keys = _dialogue_dict.keys()
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

## Maps the unique_name property of each dialogue beat to itself.
var _dialogue_dict: Dictionary = {}

# References to children in the hierarchy
@onready var textbox := %Textbox
@onready var text := %Text
@onready var choices := %Choices
@onready var ticker := %Ticker

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add the beats in the res file to a disctionary so they're easier
	# to access by name, also theoretically ensures names are unique.
	for beat in dialogue_res.beats:
		# CAUTION, FIXME: Probably does not enforce uniqueness
		# (will likely overwrite instead of throw an error). Test this later.
		# On a related note, see if you can set the resource instance's
		# name with the neame variable and have it show up in the editor
		# so designers can tell their dialogue beats appart without
		# expanding them. 
		_dialogue_dict[beat.unique_name] = beat
		
		# TODO: after testing the enforcement of uniquesness,
		# erase this print statement.
		print(_dialogue_dict[beat.unique_name].unique_name)
	
	close()


# FIXME: textbox voming up on mouse down, making mouse up dismiss imediately
# should fix teh abov if fixed: input being listened for when textbox is hidden.
func _input(event):
	# Redirects mouse clicks elsewhere on the screen to the textbox.
	textbox.grab_click_focus()


# TODO: Consider making a func that will automatically decide the number of beats
# depending on whether the text fits in the textbox. All the beats created this way
# automatically advance.


# TODO: Maybe dubug() func for printing debug messages. Make the func ugly
# so people dont use it for normal text


## Set the beat to display on the next call to next()
## 
## This usually only needs to be called once for a given dialogue chain.
## A dialogue chain is several dialogue beats starting from the beat loaded by
## this function, and ending with the dialogue beat with end_conversation set
## to true. See he documentation of _current_beat to understand how the beats in
## a chain are connected.
##
## dialogue_key:
##		The unique_name of the dialogue beat to narrate
## on_transitioned_from:
##		Callback that will be connected to the transitioned_from signal.
##		The signal will carry info about what beat it was emitted from,
##		what the next beat will be, and what choice was selected. This
##		info can be matched in the callback to determine what to do
##		when a certain choice is chosen on a certain beat.
func load_dialogue_chain(dialogue_key: String, on_transitioned_from: Callable = func (): return):
	_next_beat = dialogue_key
	_on_transitioned_from = on_transitioned_from
	transitioned_from.connect(on_transitioned_from)


## Narrate the next dialogue beat.
## 
## Unhides the textbox and fills it with the text and choices in the DialogueBeat
## given by the _next_beat property. When narrating, any replacement fields will
## get replaced with whatever is in string_replacements.
##
## string_replacements:
##		E.g. "%s dealt %d damage!" % ["Joey", 5] -> "Joey dealt 5 damage!"
##		["Joey", 5] is the string replacements.
##
## Return the unique_name of the dialogue beat that got displayed.
func next(string_replacements = []):
	# Handle when there is no next dialogue beat.
	if not _next_beat:	#if _next_beat == "":
		return _next_beat
	
	# NOTE: Setting _current_beat also sets the next _next_beat
	_current_beat = _dialogue_dict[_next_beat]
	textbox.show()
	
	# Configure textbox without choices
	if not _current_beat.choices.size() > 0:
		_set_choice_visibility(false)
		Helpers.disconnect_if_connected(choices.item_activated, _on_choice_chosen)
		Helpers.disconnect_if_connected(choices.item_clicked, _on_choice_clicked)
		textbox.gui_input.connect(_on_textbox_gui_input)
	
	# Configure textbox with choices
	else:
		_set_choice_visibility(true)
		choices.clear()
		
		# Add choices to the ItemBox based on what is in the res file.
		for choice in _current_beat.choices:
			choices.add_item(choice)
		
		Helpers.disconnect_if_connected(textbox.gui_input, _on_textbox_gui_input)
		choices.item_activated.connect(_on_choice_chosen)
		choices.item_clicked.connect(_on_choice_clicked)
	
	
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
	
	return _current_beat.unique_name


## Loads dialogue chain and calls next once
##
## Intended to be used for one-off dialogue beats but you can continue calling next
## afterwards too
##
## dialogue_key:
##		The unique_name of the dialogue beat to narrate
## string_replacements:
##		E.g. "%s dealt %d damage!" % ["Joey", 5] -> "Joey dealt 5 damage!"
##		["Joey", 5] is the string replacements.
## on_transitioned_from:
##		Callback that will be connected to the transitioned_from signal.
##		The signal will carry info about what beat it was emitted from,
##		what the next beat will be, and what choice was selected. This
##		info can be matched in the callback to determine what to do
##		when a certain choice is chosen on a certain beat.
##
## Return the unique_name of the dialogue beat that got displayed.
func quick_beat(dialogue_key: String, string_replacements = [], on_transitioned_from := func (): return):
	load_dialogue_chain(dialogue_key, on_transitioned_from)
	return await next(string_replacements)


func close():
	textbox.hide()
	set_process_input(false)


## Ensures that the ticker is not shown when choices are, and vice versa.
func _set_choice_visibility(show_choices: bool):
	if show_choices:
		choices.show()
		ticker.hide()
		choices.grab_focus.call_deferred()

	else:
		set_process_input(true)
		choices.hide()
		ticker.show()
		textbox.grab_focus.call_deferred()



## Emits the transitioned_from signal. Is called when the player chooses a
## choice or dismisses a textbox.
## 
## from_beat:
##		The dialogue beat transitioned from.
## destination_beat:
##		The name of the beat to be narrated on the next call to next().
##		AKA the dialogue beat to transition to.
## from_choice:
##		The index of the choice taken on the beat that was transitioned from.
##		-1 if there were no choices in the last dialogue beat.
func _transition(from_beat: DialogueBeat, destination_beat: String, from_choice:=-1):
	close()
	assert(destination_beat != "_unknown")
	
	# We have no destination beat if we came from the last beat.
	if not from_beat.end_conversation:
		assert(destination_beat in _dialogue_dict)
	else:
		destination_beat = ""
	
	transitioned_from.emit(from_beat, destination_beat, from_choice)


# The following 3 callbacks are intentionally not connected to a signal by
# default.
## Called when the player interacts with the textbox when there are no choices.
func _on_textbox_gui_input(event: InputEvent):
	if event.is_action_pressed("ui_accept") or event.is_action_released("click"):
		_transition(_current_beat, _next_beat)

## Called when teh player double clicks or presses enter on a choice.
func _on_choice_chosen(index: int):
	if _next_beat == "_unknown":
		_next_beat = _current_beat.jumps[index]
	_transition(_current_beat, _next_beat, index)


func _on_choice_clicked(index: int, blah, blah1):
	_on_choice_chosen(index)
