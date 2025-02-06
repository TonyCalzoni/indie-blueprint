class_name RunToWalkTransitionThirdPerson extends MachineTransition


func should_transition() -> bool:
	return true
	
func on_transition() -> void:
	if from_state is RunThirdPerson and to_state is WalkThirdPerson and from_state.in_recovery:
		to_state.catching_breath_timer.start()	
