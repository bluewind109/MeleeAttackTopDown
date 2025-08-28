extends Line2D
class_name TrajectoryLine

@export var character_body_2d: CharacterBody2D
@export var max_points: int = 40
@export var speed_multiplier: float = 1.0

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
		if (pos.distance_to(_position) < _distance):
			add_point(pos)
			var collision = get_body().move_and_collide(
				line_velocity * delta, 
				false, 
				true, 
				true
			)
			if (collision):
				var bounce_multiplier: float = 0.6
				line_velocity = line_velocity.bounce(collision.get_normal()) * bounce_multiplier

			pos += line_velocity * delta
			get_body().position = pos

func get_body() -> CharacterBody2D:
	return character_body_2d
