@icon("res://components/interaction/3D/ui/interactable_information.svg")
extends Label3D

var current_interactable: Interactable3D


func _ready() -> void:
	text = ""
	hide()

	GlobalGameEvents.interactable_focused.connect(on_interactable_focused)
	GlobalGameEvents.interactable_unfocused.connect(on_interactable_unfocused)
	GlobalGameEvents.interactable_canceled_interaction.connect(on_interactable_unfocused)
	GlobalGameEvents.interactable_interacted.connect(on_interactable_unfocused)


func on_interactable_focused(interactable: Interactable3D) -> void:
	current_interactable = interactable
	
	if current_interactable:
		show()
		text = tr(current_interactable.title_translation_key)

func on_interactable_unfocused(_interactable: Interactable3D, _ignore = null) -> void:
	# _ignore is a shitty bug fix, I'm attempting to log who interacts with what \
	# globally and somehow this became necessary
	current_interactable = null
	text = ""
	hide()
