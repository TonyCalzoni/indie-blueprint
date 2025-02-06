class_name IdleThirdPerson extends GroundStateThirdPerson


func physics_update(delta):
	super.physics_update(delta)
	
	decelerate(delta)
	
	if not actor.motion_input.input_direction.is_zero_approx():
		FSM.change_state_to(WalkThirdPerson)
	
	detect_jump()
	detect_crouch()
	
	actor.move_and_slide()
