@icon("res://components/vfx/2D/pop_effect/pop-effect.svg")
class_name PopCircleEffect extends Node2D

signal finished

## The circle color
@export var circle_color: Color = Color.WHITE
## The radius of the circle to display
@export var radius: float = 6.0
## The angle range available to spawn the circle, default 360º
@export_range(0.0, 360.0, 0.01, "degrees") var angle_range: float = 360.0
## The velocity of the circle to scale down
@export var timescale: float =  1.0
## The step smoothness factor to decrease velocity based on delta
@export var step_speed: float = 3.0
## The min speed for the random factor to apply as an initial impulse in the circle
@export var min_distance: float = 300.0
## The max speed for the random factor to apply as an initial impulse in the circle
@export var max_distance: float = 600.0
## The times a circle will be created on the pop effect
@export var times: int = 5:
	set(value):
		times = max(1, value)
## When the circle reachs this scale it resets the effect and apply a new pop
@export var target_scale: float = 0.1

@onready var velocity: Vector2 = Vector2.ZERO
@onready var initial_position: Vector2 = position
@onready var initial_scale: Vector2 = scale

var times_applied: int = 0


func _ready():
	finished.connect(func(): queue_free())
	setup(false)
	
	
func setup(count_as_applied : bool = true):
	scale = initial_scale
	position = initial_position
	velocity = Vector2.from_angle(randf() * deg_to_rad(angle_range)) * randf_range(min_distance, max_distance)
	modulate = circle_color
	
	if count_as_applied:
		times_applied += 1
		
		if times_applied >= times:
			finished.emit()
	

func _process(delta: float) -> void:
	delta *= timescale
	velocity *= 1.0 - (step_speed * delta)
	
	position += velocity * delta
	scale *= 1.0 - (step_speed * delta)
	
	if scale.x < target_scale and times_applied <= times:
		setup()


func _draw():
	draw_circle(Vector2.ZERO, radius, circle_color)
