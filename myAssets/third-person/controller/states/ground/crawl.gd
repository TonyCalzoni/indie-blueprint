class_name CrawlThirdPerson extends GroundStateThirdPerson


func enter():
	actor.animation_player.play(crawl_animation)
	%ThirdPersonAnimationTree.set("parameters/Prone/blend_amount", 1.0)


func exit(_next_state: MachineState):
	actor.animation_player.play_backwards(crawl_animation)
	await actor.animation_player.animation_finished
	%ThirdPersonAnimationTree.set("parameters/Prone/blend_amount", 0.0)
	%ThirdPersonAnimationTree.set("parameters/ProneForward/blend_amount", 0.0)


func physics_update(delta):
	super.physics_update(delta)
	
	if actor.motion_input.input_direction.is_zero_approx():
		%ThirdPersonAnimationTree.set("parameters/ProneForward/blend_amount", 0.0)
	else:
		%ThirdPersonAnimationTree.set("parameters/ProneForward/blend_amount", 0.4)
	
	if not Input.is_action_pressed(crawl_input_action) and not actor.ceil_shape_cast.is_colliding():
		FSM.change_state_to(CrouchThirdPerson)
	
	accelerate(delta)
		
	actor.move_and_slide()


func _crouch_animation() -> void:
	var previous_state = FSM.last_state()
	
	if not previous_state is SlideThirdPerson and not previous_state is CrawlThirdPerson:
		actor.animation_player.play(crouch_animation)
		await actor.animation_player.animation_finished


func _reset_crouch_animation(next_state: MachineState) -> void:
	if actor.animation_player and not next_state is CrawlThirdPerson:
		actor.anmation_player.play_backwards(crouch_animation)
		await actor.animation_player.animation_finished
	
