@icon("res://components/motion/3D/first-person/controller/mechanics/camera_controller_3d.svg")
class_name ThirdPersonCameraController extends Node3D


#region Third Person Camera Controller additions
enum camera_shift { NONE, RIGHT, LEFT }
enum perspectives { FIRST_PERSON, THIRD_PERSON }

@export_group("Third Person Settings")
@export var third_person_actor: Node3D
@export var head: SpringArm3D
# Back distance
@export_range(0.5, 2.0) var third_person_camera_distance: float = 1
# Offsets for things like aiming, crouching, and crawling
@export_range(0.0, 0.5) var camera_h_offset: float
@export_range(0.0, 1.0) var camera_v_offset: float

# For when switching to First Person Perspective
var init_head_bob_was_enabled: bool
var init_head_swing_was_enabled: bool

signal character_perspective_changed(new_perspective)
#endregion

#region Original Camera Controller 3D items
@export_group("First Person Settings")
@export var actor: ThirdPersonController
@export var camera: Camera3D
## 0 Means the rotation on the Y-axis is not limited
@export_range(0, 360, 1, "degrees") var camera_vertical_limit = 89
## 0 Means the rotation on the X-axis is not limited
@export_range(0, 360, 1, "degrees") var camera_horizontal_limit = 0
@export_group("Swing head")
@export var swing_head_enabled: bool = true:
	set(value):
		if value != swing_head_enabled:
			swing_head_enabled = value
			
@export_range(0, 360.0, 0.01) var swing_rotation_degrees = 1.5
@export var swing_lerp_factor = 5.0
@export var swing_lerp_recovery_factor = 7.5
@export_group("Bob head")
@export var bob_enabled: bool = true:
	set(value):
		if value != bob_enabled:
			bob_enabled = value
				
@export var bob_head: Node3D:
	set(value):
		if value != bob_head:
			bob_head = value
			
			if bob_head != null:
				original_head_bob_position = bob_head.position
			
@export var bob_speed: float = 10.0
@export var bob_intensity: float = 0.03
@export var bob_lerp_speed = 5.0

@onready var current_vertical_limit: int:
	set(value):
		current_vertical_limit = clamp(value, 0, 360)
		
@onready var current_horizontal_limit: int:
	set(value):
		current_horizontal_limit = clamp(value, 0, 360)

@onready var root_node: Window = get_tree().root

var last_mouse_input: Vector2
var mouse_sensitivity: float = 3.0
var locked: bool = false

var original_camera_rotation: Vector3
var original_head_bob_position: Vector3 = Vector3.ZERO

var bob_index: float = 0.0
var bob_vector: Vector3 = Vector3.ZERO
#endregion

#region Core
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and InputHelper.is_mouse_captured():
		var motion: InputEventMouseMotion = event.xformed_by(root_node.get_final_transform())
		last_mouse_input += motion.relative
		

func _ready() -> void:
	assert(actor is Node3D, "CameraController: the Node3D actor is not set, this camera controller needs a reference to apply the camera movement")
	assert(head is SpringArm3D, "ThirdPersonCameraController: the SpringArm3D (Head) object is not set")
	init_head_bob_was_enabled = swing_head_enabled
	init_head_swing_was_enabled = bob_enabled
	head.spring_length = third_person_camera_distance
	if actor.view_mode == perspectives.FIRST_PERSON:
		switch_perspective() # Handling for non-default view mode setting
	current_horizontal_limit = camera_horizontal_limit
	current_vertical_limit = camera_vertical_limit
	original_camera_rotation = camera.rotation
	
	if bob_head != null:
		original_head_bob_position = bob_head.position
	
	mouse_sensitivity = SettingsManager.get_accessibility_section(GameSettings.MouseSensivitySetting)
	
	SettingsManager.updated_setting_section.connect(on_mouse_sensitivity_changed)
	

func _physics_process(delta: float) -> void:
	if actor.view_mode == perspectives.FIRST_PERSON:
		swing_head(delta)
		headbob(delta)
		rotate_camera(last_mouse_input)
	elif actor.view_mode == perspectives.THIRD_PERSON:
		rotate_camera_3p(last_mouse_input)
	
	# Make camera follow player
	var goto = actor.position+Vector3(0,1.75,0)
	position = position + ((goto-position)*delta*5)
#endregion

#region Third Person functions
func rotate_camera_3p(motion: Vector2) -> void:
	if motion.is_zero_approx():
		return

	var mouse_sens: float = mouse_sensitivity / 1000 # radians/pixel, 3 becomes 0.003
		
	var twist_input: float = motion.x * mouse_sens ## Giro
	var pitch_input: float = motion.y * mouse_sens ## Cabeceo
	
	# Don't rotate the actor unlike with first person view
	#actor.rotate_y(-twist_input)
	
	rotate_y(-twist_input)
	rotate_x(-pitch_input)
	rotation.z = 0 # Axis lock to prevent unwanted roll on SpringArm3D
	
	#actor.rotation_degrees.y = limit_horizontal_rotation(actor.rotation_degrees.y)
	rotation_degrees.x = limit_vertical_rotation(rotation_degrees.x)

	#actor.orthonormalize()
	orthonormalize()
	
	last_mouse_input = Vector2.ZERO

func switch_perspective():
	if actor.view_mode == perspectives.FIRST_PERSON:
		head.spring_length = third_person_camera_distance
		third_person_actor.visible = true
		swing_head_enabled = false
		bob_enabled = false
		actor.view_mode = perspectives.THIRD_PERSON
		#print_debug("Third Person enabled")
	
	elif actor.view_mode == perspectives.THIRD_PERSON:
		head.spring_length = 0.0
		make_actor_face_camera_direction()
		third_person_actor.visible = false
		swing_head_enabled = init_head_swing_was_enabled
		bob_enabled = init_head_bob_was_enabled
		actor.view_mode = perspectives.FIRST_PERSON
		#print_debug("First Person enabled")
	
	character_perspective_changed.emit(actor.view_mode)
	
func make_actor_face_camera_direction():
		# Make actor face camera direction
		actor.global_rotation_degrees.y = global_rotation_degrees.y
#endregion

#region modified Camera Controller components
func rotate_camera(motion: Vector2) -> void:
	if motion.is_zero_approx():
		return

	var mouse_sens: float = mouse_sensitivity / 1000 # radians/pixel, 3 becomes 0.003
		
	var twist_input: float = motion.x * mouse_sens ## Giro
	var pitch_input: float = motion.y * mouse_sens ## Cabeceo
	
	
	actor.rotate_y(-twist_input)
	rotate_y(-twist_input) # We have to rotate both the camera and the actor now
	
	rotate_x(-pitch_input)
	rotation.z = 0 # Axis lock to prevent unwanted roll
	
	actor.rotation_degrees.y = limit_horizontal_rotation(actor.rotation_degrees.y)
	rotation_degrees.y = limit_horizontal_rotation(rotation_degrees.y) # To maintain functionality down the line
	rotation_degrees.x = limit_vertical_rotation(rotation_degrees.x)
	
	actor.orthonormalize()
	orthonormalize()
	
	last_mouse_input = Vector2.ZERO

#endregion

#region Original Camera Controller 3D functions
func limit_vertical_rotation(angle: float) -> float:
	if current_vertical_limit > 0:
		return clamp(angle, -current_vertical_limit, current_vertical_limit)
	
	return angle


func limit_horizontal_rotation(angle: float) -> float:
	if current_horizontal_limit > 0:
		return clamp(angle, -current_horizontal_limit, current_horizontal_limit)
	
	return angle


func lock() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	locked = true


func unlock() -> void:
	set_physics_process(true)
	set_process_unhandled_input(true)
	locked = false
	
	
func swing_head(delta: float) -> void:
	if swing_head_enabled and actor.is_grounded and not actor.finite_state_machine.locked:
		var direction = actor.motion_input.input_direction
		
		if direction in VectorHelper.horizontal_directions_v2:
			camera.rotation.z = lerp_angle(camera.rotation.z, -sign(direction.x) * deg_to_rad(swing_rotation_degrees), swing_lerp_factor * delta)
		else:
			camera.rotation.z = lerp_angle(camera.rotation.z, original_camera_rotation.z, swing_lerp_recovery_factor * delta)


func headbob(delta: float) -> void:
	if bob_enabled and actor.is_grounded and not actor.finite_state_machine.locked:
		bob_index += bob_speed * delta
		
		if actor.is_grounded and not actor.motion_input.input_direction.is_zero_approx():
			bob_vector = Vector3(sin(bob_index / 2.0), sin(bob_index), bob_vector.z)
			
			bob_head.position = Vector3(
				lerp(bob_head.position.x, bob_vector.x * bob_intensity, delta * bob_lerp_speed),
				lerp(bob_head.position.y, bob_vector.y * (bob_intensity * 2), delta * bob_lerp_speed),
				bob_head.position.z
			)
			
		else:
			bob_head.position = Vector3(
				lerp(bob_head.position.x, original_head_bob_position.x, delta * bob_lerp_speed),
				lerp(bob_head.position.y, original_head_bob_position.y, delta * bob_lerp_speed),
				bob_head.position.z
			)

#region Camera rotation
func change_horizontal_rotation_limit(new_rotation: int) -> void:
	current_horizontal_limit = new_rotation
	
func change_vertical_rotation_limit(new_rotation: int) -> void:
	current_vertical_limit = new_rotation
	
func return_to_original_horizontal_rotation_limit() -> void:
	current_horizontal_limit = camera_horizontal_limit
	
func return_to_original_vertical_rotation_limit() -> void:
	current_vertical_limit = camera_vertical_limit
#endregion

func on_mouse_sensitivity_changed(section: String, key: String, value: Variant) -> void:
	if section == GameSettings.AccessibilitySection and key == GameSettings.MouseSensivitySetting:
		mouse_sensitivity = value
#endregion
