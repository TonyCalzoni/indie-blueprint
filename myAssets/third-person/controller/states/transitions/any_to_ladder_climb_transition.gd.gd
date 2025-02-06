class_name AnyToLadderClimbTransitionThirdPerson extends MachineTransition


func should_transition() -> bool:
	if to_state is LadderClimbThirdPerson:
		return to_state.cooldown_timer.is_stopped()
	
	return false
