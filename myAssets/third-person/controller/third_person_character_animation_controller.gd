extends AnimationTree


func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	match state.name:
		"Fall": # FALL
			set("parameters/Air/blend_amount", 1.0)
		"Jump": # JUMP
			set("parameters/Air/blend_amount", 1.0)
			set("parameters/JumpStart/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		"Run", "Walk": # Run
			set("parameters/Run/blend_amount", 1.0)
		"Idle": # Idle
			set("parameters/Air/blend_amount", 0.0)
			set("parameters/Run/blend_amount", 0.0)
