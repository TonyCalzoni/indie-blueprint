@icon("res://components/motion/3D/first-person/controller/first_person_controller.svg")
extends Node3D
class_name  ThirdPersonActorBase

enum camera_shift { NONE, RIGHT, LEFT }
enum perspectives { FIRST_PERSON, THIRD_PERSON }

@export_group("Third Person Settings")
@export var view_mode: perspectives = perspectives.THIRD_PERSON
@export_range(0.5, 2.0) var third_person_camera_distance: float = 1 # Back distance
# Offsets for things like corner aiming, crouching, and crawling
@export_range(0.0, 0.5) var camera_h_offset: float # Maybe not needed
@export_range(0.0, 1.0) var camera_v_offset: float # Maybe not needed
@export var camera_controller: ThirdPersonCameraController
@onready var third_person_actor: Node3D = $ThirdPersonController/ThirdPersonCharacter

signal character_perspective_changed(new_perspective)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.
#
#


func switch_perspective(): # TODO make FSM state for this
	if view_mode == perspectives.FIRST_PERSON:
		camera_controller.bob_head.spring_length = third_person_camera_distance
		third_person_actor.visible = true
		camera_controller.swing_head_enabled = false
		camera_controller.bob_enabled = false
		view_mode = perspectives.THIRD_PERSON
		#print_debug("Third Person enabled")
	
	elif view_mode == perspectives.THIRD_PERSON:
		camera_controller.bob_head.spring_length = 0.0
		make_actor_face_camera_direction()
		third_person_actor.visible = false
		camera_controller.swing_head_enabled = camera_controller.init_head_swing_was_enabled
		camera_controller.bob_enabled = camera_controller.init_head_bob_was_enabled
		view_mode = perspectives.FIRST_PERSON
		#print_debug("First Person enabled")
	
	character_perspective_changed.emit(view_mode)
	
func make_actor_face_camera_direction():
		# Make actor root face camera direction
		global_rotation_degrees.y = camera_controller.global_rotation_degrees.y
