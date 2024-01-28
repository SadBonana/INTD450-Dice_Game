extends RigidBody3D


var start_pos
var roll_strength = 30


signal roll_finished(value)


func ready():
	start_pos = global_position


func _input(event):
	if event.is_action_pressed("ui_accept"):
		_roll()


func _roll():
	#Reset state
	sleeping = false
	freeze = false
	transform.origin = start_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	#Random Rotation
	transform.basis = Basis(Vector3.RIGHT, randf_range(0,2*PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0,2*PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0,2*PI)) * transform.basis
	
	#Random throw impulse
	var throw_vector = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
	angular_velocity = throw_vector * roll_strength /2
	apply_central_impulse(throw_vector * roll_strength)
	
