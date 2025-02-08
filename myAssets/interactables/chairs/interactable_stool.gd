class_name InteractableStool3D extends Node3D

@export var footSpot: Node3D
@export var footSpotSpringArm: SpringArm3D
@export var interactable: Interactable3D

var is_occupied: bool = false
var occupant = null

func _ready():
	assert(interactable is Interactable3D, "Stool: An interactable 3D object must be set")
	interactable.interacted.connect(on_interacted)
	interactable.canceled_interaction.connect(on_canceled_interaction)


func on_interacted(interactor):
	if !is_occupied:
		is_occupied = true
		occupant = interactor
		_move_foot_spot(interactor.actor)
		# Make player sit / animation; move THEN look
		interactor.actor.global_position = footSpot.global_position
		interactor.actor.look_at_from_position(footSpot.global_position, global_position, Vector3.UP, true)
		interactor.actor.lock_movement()
		interactor.actor.asm.travel(&"Sit Down")
	else:
		# Alert NPC sitting there
		pass


func on_canceled_interaction(interactor) -> void:
	is_occupied = false
	occupant = null
	# Make player get up / animation
	interactor.actor.asm.travel(&"Sit Get Up")
	await interactor.actor.third_person_animation_tree.animation_finished
	interactor.actor.unlock_movement()
	#camera.make_current()
	
	interactable.activate()
	pass


func _move_foot_spot(_player_node: CharacterBody3D):
	footSpotSpringArm.look_at(_player_node.global_position, Vector3.UP, true)
	pass
