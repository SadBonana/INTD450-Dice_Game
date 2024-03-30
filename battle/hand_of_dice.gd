extends HBoxContainer

var drawndice_with_targets : Array[DrawnDie]

func add_to_dice_with_targets(drawndie):
	drawndice_with_targets.append(drawndie)
	#print("Hey we selected a drawndie's target")
	
func remove_from_dice_with_targets(drawndie):
	drawndice_with_targets.erase(drawndie)
	#print("Hey we unselected a drawndie's target")
	
func get_drawndice_with_targets():
	return drawndice_with_targets
	
	
	
