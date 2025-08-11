extends Line2D
class_name TrajectoryLine

@export var character_body_2d: CharacterBody2D
@export var max_points: int = 40
@export var speed_multiplier: float = 0.5

func _ready() -> void:
	pass

func render_trajectory(
	_position: Vector2,
	_direction: Vector2, 
	_distance: float, 
	_speed: float, 
	delta: float
):
	var pos: Vector2 = _position
	var line_velocity: Vector2 = _direction * _speed * speed_multiplier

	clear_points()
	for i in max_points:
		add_point(pos)
		if (pos.distance_to(_position) < _distance):
			var collision = get_body().move_and_collide(line_velocity * delta, false, true, true)
			if (collision):
				line_velocity = line_velocity.bounce(collision.get_normal()) * 0.6

			pos += line_velocity * delta
			get_body().position = pos

func get_body() -> CharacterBody2D:
	return character_body_2d
