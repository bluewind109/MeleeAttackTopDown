extends Node2D
class_name ChargeDash

@export var owner_ref: CharacterBody2D
var start_pos: Vector2
var is_first_touch: bool = true
var is_holding: bool = false
var direction: Vector2 = Vector2.ZERO
var distance_to_reach: float = 0
var speed: float = 1500
var is_dashing: bool = false

signal on_dash_started
signal on_dash_finished

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if (not is_dashing):
		var mouse_pos = get_global_mouse_position()
		if (Input.is_action_pressed("attack")):
			is_holding = true
			if (is_first_touch):
				start_pos = mouse_pos
				is_first_touch = false
		
		if (Input.is_action_just_released("attack") and is_holding):
			direction = mouse_pos.direction_to(start_pos)
			distance_to_reach = mouse_pos.distance_to(start_pos)
			is_holding = false
	
	if (distance_to_reach > 0 and direction):
		if (not is_dashing): 
			on_dash_started.emit()
			is_dashing = true
		owner_ref.position += direction * speed * delta
		distance_to_reach -= direction.length() * speed * delta
		if (distance_to_reach <= 0 and is_dashing):
			is_first_touch = true
			is_dashing = false
			on_dash_finished.emit()
