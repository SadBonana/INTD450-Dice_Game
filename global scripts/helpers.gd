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
