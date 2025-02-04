class_name InputActionKeybindingGroupDisplay extends VBoxContainer

const InputActionKeybindingScene = preload("res://indie-blueprint/ui/menus/components/panel/input_action_keybinding.tscn")


#@onready var input_key_label: Label = $InputActionKeybinding/InputKey
#@onready var input_key_panel: Panel = $InputActionKeybinding/InputKeyPanel
@onready var input_action_label: Label = $HBoxContainer/InputActionGroupLabel
@onready var input_action_add_bind: Button = $HBoxContainer/AddKeybindButton

var action: StringName
var keybindings: Array[InputEvent]
var new_bind = InputEvent


var is_remapping: bool = false:
	set(value):
		if value != is_remapping:
			is_remapping = value
			
			set_process_input(is_remapping)
			
var current_action_to_remap: InputActionKeybindingDisplay = null


func _ready() -> void:	
	set_process_input(is_remapping)


func _input(event: InputEvent) -> void:
	## Only detects keyboards binding for now, gamepad support in the future
	if event is InputEventKey:
		accept_event()
		
		## Important line to accept modifiers when this are keep pressed
		if InputHelper.any_key_modifier_is_pressed() and event.pressed:
			return
		
		current_action_to_remap.update_keybinding(event)
		reset_remapping()
		
	elif event is InputEventMouseButton and event.pressed:
		accept_event()
		
		event = InputHelper.double_click_to_single(event)
		
		current_action_to_remap.update_keybinding(event)
		reset_remapping()
		accept_event()
		

func reset_remapping() -> void:
	is_remapping = false
	current_action_to_remap = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready
		
		#display_keybindings()


func setup(_action: StringName, _keybindings: Array[InputEvent]) -> void:
	action = _action
	keybindings = _keybindings
	input_action_label.text = tr(_action).to_upper()
	
	for i in keybindings:
		var input_action_keybinding: InputActionKeybindingDisplay = InputActionKeybindingScene.instantiate() as InputActionKeybindingDisplay
		add_child(input_action_keybinding)
		input_action_keybinding.setup(action, i)
		input_action_keybinding.input_key_panel.gui_input.connect(on_input_keybinding_pressed.bind(input_action_keybinding))


func on_input_keybinding_pressed(event: InputEvent, input_action_keybinding: InputActionKeybindingDisplay) -> void:
	if InputHelper.is_mouse_left_click(event) and not is_remapping:
		is_remapping = true
		current_action_to_remap = input_action_keybinding
		current_action_to_remap.change_to_remapping_text()


#region Add keybind
func _on_add_keybind_button_toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		input_action_add_bind.text = "Waiting for input..."
		#release_focus()
	else:
		input_action_add_bind.text = "ADD_BIND"
		add_key(new_bind)
		#grab_focus()
	
	pass # Replace with function body.


func _unhandled_input(new_event):
	if new_event.pressed:
		InputMap.action_add_event(action, new_event)
		new_bind = new_event
		input_action_add_bind.button_pressed = false
		# TODO check if binding exists


func add_key(new_event):
	InputMap.action_add_event(action, new_event)
	SettingsManager.create_keybinding_events_for_action(action)
	
	# Add keybind to display
	var input_action_keybinding: InputActionKeybindingDisplay = InputActionKeybindingScene.instantiate() as InputActionKeybindingDisplay
	add_child(input_action_keybinding)
	input_action_keybinding.setup(action, new_event)
	input_action_keybinding.input_key_panel.gui_input.connect(on_input_keybinding_pressed.bind(input_action_keybinding))
#endregion
