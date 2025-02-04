extends PanelContainer

const InputActionKeybindingGroupScene = preload("res://indie-blueprint/ui/menus/components/panel/input_action_group.tscn")


@export var include_ui_actions: bool = false
@export var exclude_actions: Array[String] = []
@onready var action_list: VBoxContainer = %ActionListVboxContainer
@onready var reset_to_default_button: Button = $MarginContainer/ActionListVboxContainer/ResetToDefaultButton


func _ready() -> void:
	for child in NodeTraversal.find_nodes_of_custom_class(action_list, InputActionKeybindingDisplay):
		child.queue_free()
	
	#set_process_input(is_remapping)
	load_input_keybindings(_get_input_map_actions())
		
	reset_to_default_button.pressed.connect(on_reset_to_default_pressed)


func load_input_keybindings(target_actions: Array[StringName]) -> void:
	for action: StringName in target_actions:
		var actions: Array[InputEvent] = InputMap.action_get_events(action)
		
		if actions.size() > 0:
			var input_action_keybinding_group: InputActionKeybindingGroupDisplay = InputActionKeybindingGroupScene.instantiate() as InputActionKeybindingGroupDisplay
			action_list.add_child(input_action_keybinding_group)
			input_action_keybinding_group.setup(action, actions)
	
	## Move the reset to default button to the end of the list
	action_list.move_child(reset_to_default_button, action_list.get_child_count() - 1)


func _get_input_map_actions() -> Array[StringName]:
	var input_map_actions: Array[StringName] = InputMap.get_actions() if include_ui_actions else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))

	if exclude_actions.size() > 0:
		input_map_actions = input_map_actions.filter(func(action): return not action in exclude_actions)
		
	return input_map_actions
	

func on_reset_to_default_pressed() -> void:
	#reset_remapping()
	pass
	
	var default_input_map_actions: Dictionary = GameSettings.DefaultSettings[GameSettings.DefaultInputMapActionsSetting]
	
	if not default_input_map_actions.is_empty():
		for input_action_keybinding: InputActionKeybindingDisplay in NodeTraversal.find_nodes_of_custom_class(action_list, InputActionKeybindingDisplay):
			var current_action: StringName = StringName(input_action_keybinding.action)
			
			if default_input_map_actions.has(current_action):
				input_action_keybinding.setup(current_action, default_input_map_actions[current_action].front())
