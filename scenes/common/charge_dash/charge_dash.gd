extends Node2D
class_name ChargeDash

@export var owner_ref: CharacterBody2D
@export var trajectory_line: TrajectoryLine

var start_pos: Vector2
var mouse_pos: Vector2

var is_first_touch: bool = true
var is_holding: bool = false
var direction: Vector2 = Vector2.ZERO

var distance_to_reach: float = 0
var distance_remainining: float = 0

var speed: float = 1500
var is_dashing: bool = false

signal on_dash_started
signal on_dash_finished

func _ready() -> void:
	pass

func render_trajectory(_direction: Vector2, _distance: float, _speed: float, delta: float):
	var max_points = 20
	var _speed_multiplier = 0.5

	var pos: Vector2 = owner_ref.global_position
	var line_velocity: Vector2 = _direction * _speed * _speed_multiplier

	trajectory_line.clear_points()
	for i in max_points:
		trajectory_line.add_point(pos)
		if (pos.distance_to(owner_ref.global_position) < _distance):
			var collision = trajectory_line.get_body().move_and_collide(line_velocity * delta, false, true, true)
			if (collision):
				line_velocity = line_velocity.bounce(collision.get_normal()) * 0.6

			pos += line_velocity * delta
			trajectory_line.get_body().position = pos

func _physics_process(delta: float) -> void:
	if (not is_dashing):
		mouse_pos = get_global_mouse_position()
		if (Input.is_action_pressed("attack")):
			if (is_first_touch):
				start_pos = mouse_pos
				is_first_touch = false

			is_holding = true
			var _distance = mouse_pos.distance_to(start_pos)
			if (_distance > 25):
				render_trajectory(mouse_pos.direction_to(start_pos), _distance, speed, delta)
		
		if (Input.is_action_just_released("attack") and is_holding):
			direction = mouse_pos.direction_to(start_pos)
			distance_to_reach = mouse_pos.distance_to(start_pos)
			if (distance_to_reach > 25): distance_remainining = distance_to_reach
			is_first_touch = true
			is_holding = false
			trajectory_line.clear_points()
	
	if (distance_to_reach > 25 and direction and distance_remainining > 0):
		if (not is_dashing): 
			on_dash_started.emit()
			is_dashing = true
		owner_ref.move_and_collide(direction * speed * delta)
		distance_remainining -= direction.length() * speed * delta
		if (distance_remainining <= 0 and is_dashing):
			is_dashing = false
			is_first_touch = true
			on_dash_finished.emit()
