extends Node2D
class_name RaycastBullet

# code to init the bullet
# var bullet_instance: RaycastBullet = raycast_bullet_scene.instantiate()
# bullet_instance.init(pos, _direction, owner_ref.collision_mask)
# get_tree().current_scene.add_child(bullet_instance)

@export var speed: float = 120.0 * 120
@export var bounce_count: int = 2
@export var life_time: float = 0.3

var _current_pos: Vector2
var _direction: Vector2
var _rotation: float
var _time: float
var _collision_mask: int

var trace_line: Array

func _ready() -> void:
	pass

func init(
	pos: Vector2, 
	dir: Vector2,
	col_mask: int
):
	_current_pos = pos
	_direction = dir
	_collision_mask = col_mask

func _draw() -> void:
	if (not trace_line.is_empty()):
		for i in trace_line.size() - 1:
			var _point1: Vector2 = trace_line[i]
			var _point2: Vector2 = trace_line[i + 1]
			var _color: Color = Color.WHITE
			draw_line(_point1, _point2, _color)


func _physics_process(delta: float) -> void:
	if (bounce_count > 0 and _time < life_time):
		_bullet_process(delta)
	_time += delta

	if (_time >= life_time):
		queue_free()

	queue_redraw()

func _bullet_process(delta: float):
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var remain_length: float = speed * delta
	var end_pos: Vector2
	trace_line.append(_current_pos)
	var collision_data: Dictionary

	while remain_length > 0.001 and bounce_count > 0:
		end_pos = _current_pos + _direction * remain_length
		var param: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
			_current_pos, 
			end_pos,
			_collision_mask
		)
		collision_data = space_state.intersect_ray(param)
		
		if (collision_data):
			# move the end point back slightly out of the collider
			end_pos = collision_data.position - (collision_data.position - _current_pos).normalized() * 0.01
			_direction = _direction.bounce(collision_data["normal"]).normalized()
			bounce_count -= 1
		remain_length -= (end_pos - _current_pos).length()
		_current_pos = end_pos
		trace_line.append(_current_pos)
