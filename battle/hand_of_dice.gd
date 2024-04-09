extends HBoxContainer

var drawndice_with_targets : Array[DrawnDie]
signal amount_selected(num : int)

func add_to_dice_with_targets(drawndie):
	drawndice_with_targets.append(drawndie)
	var selected_amount = drawndice_with_targets.size()
	#print("Hey we selected a drawndie's target")
	send_signal(selected_amount)
				
	
	
func remove_from_dice_with_targets(drawndie):
	var previous_selected_amount = drawndice_with_targets.size()
	drawndice_with_targets.erase(drawndie)
	var selected_amount = drawndice_with_targets.size()
	send_signal(selected_amount)
	drawndie.data.battle.target_selected.emit(null)
	#print("Hey we unselected a drawndie's target")
	
func get_drawndice_with_targets():
	return drawndice_with_targets
	
func get_num_selected_targets():
	return drawndice_with_targets.size()
	
func is_max():
	return get_num_selected_targets() >= PlayerData.dice_choices
	
func reset():
	drawndice_with_targets.clear()
	send_signal(0)
	
func disable_die(drawndie):
	var selected_amount = drawndice_with_targets.size()
	if selected_amount >= PlayerData.dice_choices and \
			 drawndie not in drawndice_with_targets:
		drawndie.disabled = true
		
func enable_all_dice():
	for child in get_children():
		child.disabled = false
	
func send_signal(num : int):
	amount_selected.emit(num)
	
	
	
