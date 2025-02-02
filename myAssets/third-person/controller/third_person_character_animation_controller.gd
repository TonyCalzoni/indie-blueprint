extends AnimationTree


#func state_changed(new_state:PlayerCharacterController.state):
	##destinationStates["parameters/Speed/scale"]= 1.0
	##destinationStates["parameters/Air/blend_amount"]= 0.0
	##destinationStates["parameters/Run/blend_amount"]= 0.0
	###destinationStates["parameters/SitIdle/blend_amount"]= 0.0
	##destinationStates["parameters/JumpStart/active"]= 0.0
	##destinationStates["parameters/SitStart/active"]= 0.0
	#if new_state == PlayerCharacterController.state.FALL:
		#set("parameters/Air/blend_amount", 1.0)
	#if new_state == PlayerCharacterController.state.JUMP:
		#set("parameters/Air/blend_amount", 1.0)
		#set("parameters/JumpStart/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#if new_state == PlayerCharacterController.state.RUN:
		#set("parameters/Run/blend_amount", 1.0)
	#if new_state == PlayerCharacterController.state.SIT:
		#set("parameters/SitTransition/transition_request", "state_1")
		#set("parameters/SitStart/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#if new_state == PlayerCharacterController.state.SITIDLE:
		#set("parameters/Speed/scale", 0.25)
		##destinationStates["parameters/SitIdle/blend_amount"]= 1.0
	#if new_state == PlayerCharacterController.state.IDLE and ((last_state == PlayerCharacterController.state.SIT) or (last_state == PlayerCharacterController.state.SITIDLE)):
		#set("parameters/Speed/scale", 1.0)
		#set("parameters/SitTransition/transition_request", "state_3")
	#if new_state == PlayerCharacterController.state.IDLE:
		## bug fix for removing _process()
		#set("parameters/Air/blend_amount", 0.0)
		#set("parameters/Run/blend_amount", 0.0)
	#last_state = new_state


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
