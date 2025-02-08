extends CharacterBody3D
class_name UFOControllerNew;


const rotation_speed = PI;

enum state{HOVER,LANDED}


@export var interactable: Interactable3D
@export_range(0.0, 200.0) var base_health: float = 100
@export_group("Motion")
@export_range(0.0, 200.0) var max_speed: float = 80.0;
@export_range(0.0, 100.0) var max_vert_speed: float = 20.0;
@export_range(0.0, 200.0) var acceleration: float = 40.0;
@export_range(0.0, 100.0) var vert_acceleration: float = 10.0;
@export_range(500, 2000) var gravity: float = 500
@export_group("Functionality")
@export var parkingBrake = false
@export_group("View")
@export_range(10.0, 20.0) var max_zoom: float = 20.0;
@export_range(4.0, 10.0) var min_zoom: float = 5.0;


@onready var ship_root: Node3D = self
@onready var cam_arm = $CameraRoot/SpringArm3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var ufo_cam = $CameraRoot/SpringArm3D/Camera3D

var enable_rotation = true;
var enable_movement = true;
var speed = 0;
var vert_speed = 0;
var drift_direction = Vector3.FORWARD;
var held_node;
var fallspeed = 0;
var is_occupied = false
var occupant_is_player = false
var occupant = null


var previous_state:state = state.LANDED
var current_state:state = state.HOVER:
	set(new_state):
		if new_state != current_state:
			previous_state = current_state
			current_state = new_state
			
			if new_state == state.LANDED:
				anim_player.pause()
				enable_movement = false
				enable_rotation = false
				speed = 0 #we do this so it doesn't preserve old stored momentum
				vert_speed = 0
				fallspeed = 0
			elif new_state == state.HOVER:
				anim_player.play(&"Hovering")
				enable_movement = true
				enable_rotation = true
			
			emit_signal("change_state",new_state)


var motion_input: TransformedInput = TransformedInput.new(self)

@warning_ignore("unused_signal")
signal change_state(state)


func _ready() -> void:
	interactable.interacted.connect(enter_vehicle)
	interactable.canceled_interaction.connect(exit_vehicle)


func _physics_process(delta):
	motion_input.update()
	if is_occupied and occupant_is_player:
		if cam_arm != null:
			_do_zoom();
		if enable_rotation:
			_do_rotation(delta)
		if enable_movement:
			_do_movement(delta)
	
	_do_vertical_movement(delta)

#region Motion
func _do_rotation(delta):
	var _basis = transform.basis;
	var steering_input: float = -motion_input.input_direction_horizontal_axis
	_basis = _basis.rotated(basis.y, steering_input * rotation_speed * delta)
	_basis = _basis.orthonormalized();
	transform.basis = _basis;
	
func _do_movement(delta):
	var motion_input_direction = -motion_input.input_direction_vertical_axis
	var forward = ship_root.global_transform.basis.z.normalized();
	if motion_input.input_direction.is_zero_approx():
		# This will cause it to not decelerate while turning
		speed -= speed * delta;
	else:
		speed = clampf(speed - (acceleration * motion_input_direction) * delta, -max_speed, max_speed)
	velocity = forward * speed;
	move_and_slide();

func _do_vertical_movement(delta):
	if is_on_floor():
			current_state = state.LANDED
	
	if is_occupied and occupant_is_player:
		var up = ship_root.global_transform.basis.y.normalized();
		if Input.is_action_pressed(&"ascend"):
			if current_state == state.LANDED:
				current_state = state.HOVER
			vert_speed = min(vert_speed + (vert_acceleration * Input.get_action_strength(&"ascend")) * delta, max_vert_speed);
		elif Input.is_action_pressed(&"descend"):
			vert_speed = max(vert_speed - (vert_acceleration * Input.get_action_strength(&"descend")) * delta, -max_vert_speed);
		else:
			vert_speed -= vert_speed * delta;
		velocity = up * vert_speed;
	elif ! parkingBrake and ! is_occupied:
		var down = -ship_root.global_transform.basis.y.normalized();
		fallspeed += gravity*delta
		velocity = down * fallspeed
	
	move_and_slide();
#endregion

func _do_zoom():
	if Input.is_action_just_pressed(&"zoom_in") and cam_arm.spring_length > min_zoom:
		cam_arm.spring_length = cam_arm.spring_length - Input.get_action_strength(&"zoom_in");
	elif Input.is_action_just_pressed(&"zoom_out") and cam_arm.spring_length < max_zoom:
		cam_arm.spring_length = cam_arm.spring_length + Input.get_action_strength(&"zoom_out");


#region Interaction
func enter_vehicle(interactor):
	var is_player = interactor.actor.get_collision_layer_value(2)
	if !is_occupied:
		# Player get in
		interactor.actor.lock_movement()
		# Do effect
		# TODO
		# Hide player during effect
		interactor.actor.global_position = Vector3(0,-3,0)
		interactor.actor.visible = false
		#interactor.actor.process_mode = PROCESS_MODE_DISABLED
		# Change camera
		if is_player:
			GameGlobals.change_camera(interactor.actor.camera, ufo_cam)
			occupant_is_player = true
		# Reparent player root node to UFO
		occupant = GameGlobals.reparent_node(interactor.actor, self)
		# Do these last
		is_occupied = true


func exit_vehicle(interactor):
	# Reparent player root node back to scene tree root
	if occupant_is_player:
		GameGlobals.reparent_node(occupant, get_tree().current_scene)
		occupant_is_player = false
		# Do effect
		# TODO
		# Move player during effect
		interactor.actor.global_position = global_position + Vector3(0,2,0)
		# Show player
		interactor.actor.visible = true
		# Change camera
		GameGlobals.change_camera(ufo_cam, interactor.actor.camera)
		# Player unlock
		interactor.actor.unlock_movement()
		# Reset
		occupant = null
		is_occupied = false
	else:
		# Do effect
		
		# Move NPC during effect
		interactor.actor.global_position = global_position + Vector3(0,2,0)
		# Show NPC
		interactor.actor.visible = true
		# NPC unlock
		interactor.actor.unlock_movement()
		# Reset
		occupant = null
		is_occupied = false
#endregion
