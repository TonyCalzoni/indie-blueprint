extends Node3D


### CRITICAL INFO this script simply causes the "ThirdPersonPlayerContainer" node to go away -
### CRITICAL INFO - doing this helps eliminate quite a few stupid bugs


func _ready() -> void:
	print_debug("ContainerBreaker: Initial Child Count: " + str(get_child_count(true)))
	GameGlobals.reparent_node_deferred($ThirdPersonController, get_tree().current_scene)
	GameGlobals.reparent_node_deferred($CameraController, get_tree().current_scene)


func _physics_process(_delta: float) -> void:
	var child_count = get_child_count(false)
	#print_debug("ContainerBreaker: Current Child Count: " + str(child_count))
	if child_count == 0:
		print_debug("ContainerBreaker: Succeeded")
		queue_free()
	pass
