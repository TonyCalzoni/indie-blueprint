class_name CrawlThirdPerson extends GroundStateThirdPerson


func enter():
	asm.travel(&"Prone Idle")
	actor.animation_player.play(crawl_animation)



func exit(_next_state: MachineState):
	actor.animation_player.play_backwards(crawl_animation)
	await actor.animation_player.animation_finished


func physics_update(delta):
	super.physics_update(delta)
	
	if actor.motion_input.input_direction.is_zero_approx():
		asm.travel(&"Prone Idle")
		
	else:
		asm.travel(&"Prone Forward")
		
	
	if not Input.is_action_pressed(crawl_input_action) and not actor.ceil_shape_cast.is_colliding():
		FSM.change_state_to(CrouchThirdPerson)
	
	accelerate(delta)
		
	actor.move_and_slide()
