class_name CrouchThirdPerson extends GroundStateThirdPerson


func enter():
	_crouch_animation()


func exit(next_state: MachineState):
	_reset_crouch_animation(next_state)


func physics_update(delta):
	super.physics_update(delta)
	var motion_is_approx_zero: bool = actor.motion_input.input_direction.is_zero_approx()
	
	if not Input.is_action_pressed(crouch_input_action) and not actor.ceil_shape_cast.is_colliding():
		if motion_is_approx_zero:
			FSM.change_state_to(IdleThirdPerson)
		else:
			FSM.change_state_to(WalkThirdPerson)
	
	if motion_is_approx_zero:
		%ThirdPersonAnimationTree.set("parameters/CrouchWalk/blend_amount", 0.0)
	else:
		%ThirdPersonAnimationTree.set("parameters/CrouchWalk/blend_amount", 0.5)
	
	accelerate(delta)
	
	if not actor.ceil_shape_cast.is_colliding():
		detect_jump()
	
	detect_jump()
	detect_crawl()
	
	actor.move_and_slide()


#region Animations
func _crouch_animation() -> void:
	var previous_state = FSM.last_state()
	
	if not previous_state is SlideThirdPerson and not previous_state is CrawlThirdPerson:
		actor.animation_player.play(crouch_animation)
		await actor.animation_player.animation_finished
		


func _reset_crouch_animation(next_state: MachineState) -> void:
	if actor.animation_player and not next_state is CrawlThirdPerson:
		actor.animation_player.play_backwards(crouch_animation)
		await actor.animation_player.animation_finished
#endregion
