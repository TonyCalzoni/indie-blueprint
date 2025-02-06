class_name WallRunToWallJumpTransitionThirdPerson extends MachineTransition


func on_transition() -> void:
	if from_state is WallRunThirdPerson and to_state is WallJumpThirdPerson:
		if from_state.wall_run_cooldown > 0 and is_instance_valid(from_state.wall_run_cooldown_timer):
			from_state.wall_run_cooldown_timer.start(from_state.wall_run_cooldown)
	
