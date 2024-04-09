extends VBoxContainer

@onready var dieside_info = %"DiesideInfo"
@onready var element_info = %"ElementInfo"
## We need this because the display box requires it.
signal frame_clicked()

func update(dieside : DieSide):
	dieside_info.text = "[center]" + dieside.info() + "[/center]"
	element_info.text = "[center]" + dieside.element.info() + "[/center]"
	
