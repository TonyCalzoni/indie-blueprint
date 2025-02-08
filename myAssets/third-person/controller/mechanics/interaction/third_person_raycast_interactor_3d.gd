class_name RayCastInteractor3P extends RayCast3D

@export var interact_input_action: StringName = InputControls.Interact
@export var cancel_interact_input_action: StringName = InputControls.CancelInteraction
@export var actor: ThirdPersonController

var current_interactable: Interactable3D
var focused: bool = false
var interacting: bool = false


#func _ready() -> void:
	#asm = actor.third_person_animation_tree.get("parameters/playback")


func _unhandled_input(_event: InputEvent):
	if InputMap.has_action(interact_input_action) && Input.is_action_just_pressed(interact_input_action) and current_interactable and not interacting:
		interact(current_interactable)
		
	
	if InputMap.has_action(cancel_interact_input_action) && Input.is_action_just_pressed(cancel_interact_input_action) and current_interactable:
		cancel_interact(current_interactable)


func _enter_tree():
	enabled = true
	exclude_parent = true
	collide_with_areas = true
	collide_with_bodies = true
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.interactables_collision_layer | GameGlobals.grabbables_collision_layer
	

func _physics_process(_delta):
	var detected_interactable = get_collider() if is_colliding() else null

	if detected_interactable is Interactable3D:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func interact(interactable: Interactable3D = current_interactable):
	if interactable and not interacting:
		enabled = false
		interacting = interactable.lock_player_on_interact
		if interacting and actor.camera_controller.view_mode == actor.camera_controller.perspectives.FIRST_PERSON:
			# Fixes a bug that occurs when sitting while first person
			actor.camera_controller.switch_perspective()
		
		interactable.interacted.emit(self)


# Used to exit chairs and vehicles
func cancel_interact(interactable: Interactable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		enabled = true
		current_interactable = null
		
		interactable.canceled_interaction.emit(self)


func focus(interactable: Interactable3D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit()


func unfocus(interactable: Interactable3D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false
		enabled = true
		
		interactable.unfocused.emit()
