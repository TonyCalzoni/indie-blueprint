extends CanvasLayer

@export var actor: Node3D
@export var actor_root: Node3D
@export var finite_state_machine: FiniteStateMachine
@export var speed_unit: VelocityHelper.SpeedUnit = VelocityHelper.SpeedUnit.KilometersPerHour

@onready var velocity_label: Label = %VelocityLabel
@onready var speed_label: Label = %SpeedLabel
@onready var state_label: Label = %State
@onready var fov_label: Label = %FOV
@onready var player_position_label: Label = %PlayerPosition
#@onready var container_position_label: Label = %ContainerPosition


@onready var control: Control = $Control


func _ready() -> void:
	#assert(actor is ThirdPersonController, "ThirdPersonControllerDebugUI: Needs a ThirdPersonController to display the debug parameters")
	
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if finite_state_machine:
		finite_state_machine.state_changed.connect(on_state_changed)
		
		state_label.text = "State: [%s]" % finite_state_machine.current_state.name
	
	if actor.camera:
		fov_label.text = str(actor.camera.fov)
	

func _process(_delta: float) -> void:
	var velocity = actor.get_real_velocity()
	var velocity_snapped : Array[float] = [
		snappedf(velocity.x, 0.001),
		snappedf(velocity.y, 0.001),
		snappedf(velocity.z, 0.001)
	]
	
	velocity_label.text = "Velocity: (%s, %s, %s)" % [velocity_snapped[0], velocity_snapped[1], velocity_snapped[2]]
	
	match speed_unit:
		VelocityHelper.SpeedUnit.KilometersPerHour:
			speed_label.text = "Speed: %d km/h" % VelocityHelper.current_speed_on_kilometers_per_hour(velocity)
		VelocityHelper.SpeedUnit.MilesPerHour:
			speed_label.text = "Speed: %d mp/h" % VelocityHelper.current_speed_on_miles_per_hour(velocity)
	
		
	if actor.camera:
		fov_label.text = str(actor.camera.fov)
		
	player_position_label.text = "Player Position: (%s, %s, %s)" % [actor.position.x, actor.position.y, actor.position.z]
	#container_position_label.text = "Container Position: (%s, %s, %s)" % [actor_root.position.x, actor_root.position.y, actor_root.position.z]


func on_state_changed(from: MachineState, to: MachineState) -> void:
	state_label.text = "State: %s -> [%s]" % [from.name, to.name]
	
