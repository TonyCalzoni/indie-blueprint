class_name SpecialStateThirdPerson extends MachineState

@export var actor: Node3D
@export var animation_state_machine: AnimationTree
var asm
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var speed: float = 3.0
@export var side_speed: float = 2.5
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export_group("Input actions")
@export var run_input_action: StringName = InputControls.RunAction
@export var jump_input_action: StringName = InputControls.JumpAction


func _ready() -> void:
	if animation_state_machine:
		asm = animation_state_machine.get("parameters/playback")


func _unhandled_input(_event: InputEvent) -> void:
	if actor.ladder_climb and not FSM.current_state_is_by_class(LadderClimbThirdPerson) \
		and actor.ladder_cast_detector.is_colliding():
		var ladder: Ladder3D = actor.ladder_cast_detector.get_collider(0).get_parent()
		
		if ladder.press_to_climb and Input.is_action_just_pressed(ladder.input_action_to_climb_ladder):
			FSM.change_state_to(LadderClimbThirdPerson)
			

func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to(JumpThirdPerson)


func detect_swim() -> void:
	if FSM.states.has("Swim") and actor.swim:
		var swim_state: SwimThirdPerson = FSM.states["SwimThirdPerson"] as SwimThirdPerson
		
		if swim_state.eyes.global_position.y <= swim_state.water_height:
			FSM.change_state_to(SwimThirdPerson)


func detect_ladder() -> void:
	if actor.ladder_climb and actor.ladder_cast_detector.is_colliding():
		var ladder: Ladder3D = actor.ladder_cast_detector.get_collider(0).get_parent()
		
		if not ladder.press_to_climb:
			FSM.change_state_to(LadderClimbThirdPerson)


func detect_ladder_input() -> void:
	if actor.ladder_climb and not FSM.current_state_is_by_class(LadderClimbThirdPerson) \
		and actor.ladder_cast_detector.is_colliding():
		var ladder: Ladder3D = actor.ladder_cast_detector.get_collider(0).get_parent()
		
		if ladder.press_to_climb and Input.is_action_just_pressed(ladder.input_action_to_climb_ladder):
			FSM.change_state_to(LadderClimbThirdPerson)


func get_speed() -> float:
	return side_speed if actor.motion_input.input_direction in VectorHelper.horizontal_directions_v2 else speed
