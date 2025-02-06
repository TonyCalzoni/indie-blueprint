class_name WalkToRunTransitionThirdPerson extends MachineTransition


func should_transition() -> bool:
	if from_state is WalkThirdPerson and to_state is RunThirdPerson:
		return from_state.actor.run and from_state.catching_breath_timer.is_stopped()
	
	return false
	
