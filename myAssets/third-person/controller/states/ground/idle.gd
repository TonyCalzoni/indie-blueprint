class_name Idle3P extends GroundState3P


func physics_update(delta):
	super.physics_update(delta)
	
	decelerate(delta)
	
	if not actor.motion_input.input_direction.is_zero_approx():
		FSM.change_state_to(Walk)
	
	detect_jump()
	detect_crouch()
	
	actor.move_and_slide()
