class_name Helpers


## Return minuend - subtrahend if subtrahend < minuend, else 0.
## Ensures health doesn't drop below 0 and such.
static func clamp_damage(minuend, subtrahend):
	return max(0, minuend - subtrahend)


## Disconnect a function from a signal.
## Does not throw an error if the func is not connected.
static func disconnect_if_connected(sig: Signal, cal: Callable):
	if not sig.is_connected(cal):
		return false
	sig.disconnect(cal)
	return true


## HACK: Due to map being an autoload. Basically unnavoidable unless map stops
## being an autoload. May have unexpected behavior.
static func to_map(current_scene: Node):
	#print("actual current: ", current_scene.get_tree().current_scene.name, " expected current: ", current_scene.name)
	#if current_scene.get_tree().current_scene == current_scene:
		#current_scene.get_tree().unload_current_scene()
	#else:
		#current_scene.queue_free()
	var bg = current_scene.get_node("/root/Map/Background")
	current_scene.queue_free() # Free the current scene to reveal the map beneath it.
	for node in bg.get_children():
		if node.focus_mode == Control.FocusMode.FOCUS_ALL:
			node.grab_focus()
			break
