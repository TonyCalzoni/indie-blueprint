extends AnimationTree


func _on_finite_state_machine_state_changed(_from_state: MachineState, state: MachineState) -> void:
	# TODO move all this to FSM scripts
	# Crouch movement is off, character snaps upward a bit
	# Prone movement is off, character swims through floor
	# Reset Animation Tree Blends
	set("parameters/Air/blend_amount", 0.0)
	set("parameters/Run/blend_amount", 0.0)
	set("parameters/Crouch/blend_amount", 0.0)
	set("parameters/CrouchWalk/blend_amount", 0.0)
	set("parameters/Prone/blend_amount", 0.0)
	set("parameters/ProneForward/blend_amount", 0.0)
	#set("parameters/Walk/blend_amount", 0.0)
	match state.name:
		"FallThirdPerson": # FALL
			set("parameters/Air/blend_amount", 1.0)
		"JumpThirdPerson": # JUMP
			set("parameters/Air/blend_amount", 1.0)
			set("parameters/JumpStart/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		"RunThirdPerson": # Run
			set("parameters/Run/blend_amount", 1.0)
		"WalkThirdPerson":
			#set("parameters/Walk/blend_amount", 0.0)
			pass
		"IdleThirdPerson": # Idle
			# All should be reset by reaching this
			pass
		"CrouchThirdPerson":
			set("parameters/Crouch/blend_amount", 1.0)
		"CrawlThirdPerson":
			set("parameters/Prone/blend_amount", 1.0)
			pass
		"SwimThirdPerson":
			
			pass
		"LadderClimbThirdPerson":
			
			pass
