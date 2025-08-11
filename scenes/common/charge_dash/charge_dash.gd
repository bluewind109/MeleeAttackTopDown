extends Node2D
class_name ChargeDash

@export var owner_ref: CharacterBody2D
@export var trajectory_line: TrajectoryLine

var start_pos: Vector2
var mouse_pos: Vector2

var is_start_pos_set: bool = false
var is_holding: bool = false
var dash_direction: Vector2 = Vector2.ZERO

var distance_dragged: float = 0
var distance_remaining: float = 0
@export var distance_range: Vector2 = Vector2(25, 300)

@export var dash_speed: float = 1500
var is_dashing: bool = false

signal on_dash_started
signal on_dash_finished

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if (not is_dashing):
		mouse_pos = get_global_mouse_position()
		if (Input.is_action_pressed("attack")):
			if (not is_start_pos_set):
				start_pos = mouse_pos
				is_start_pos_set = true

			is_holding = true
			distance_dragged = clampf(
				mouse_pos.distance_to(start_pos), 
				distance_range.x, 
				distance_range.y
			)
			if (is_more_than_minimum_distance()):
				trajectory_line.render_trajectory(
					owner_ref.global_position,
					mouse_pos.direction_to(start_pos), 
					distance_dragged, 
					dash_speed, 
					delta
				)
		
		if (Input.is_action_just_released("attack") and is_holding):
			dash_direction = mouse_pos.direction_to(start_pos)
			distance_dragged = mouse_pos.distance_to(start_pos)
			if (is_more_than_minimum_distance()): distance_remaining = distance_dragged
			is_start_pos_set = false
			is_holding = false
			trajectory_line.clear_points()
	
	if (is_more_than_minimum_distance() and dash_direction and distance_remaining > 0):
		if (not is_dashing): 
			on_dash_started.emit()
			is_dashing = true
		owner_ref.move_and_collide(dash_direction * dash_speed * delta)
		distance_remaining -= dash_direction.length() * dash_speed * delta
		if (distance_remaining <= 0 and is_dashing):
			is_dashing = false
			is_start_pos_set = false
			on_dash_finished.emit()

func is_more_than_minimum_distance() -> bool:
	return distance_dragged >= distance_range.x