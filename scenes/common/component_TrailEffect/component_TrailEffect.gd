extends Line2D
class_name ComponentTrailEffect

@export var MAX_LENGTH: int
@export var offset: Vector2 = Vector2.ZERO

func _process(_delta) -> void:
	add_point(get_parent().global_position + offset)
	if (points.size() > MAX_LENGTH):
		remove_point(0)

func toggle_effect(val: bool):
	visible = val

func reset_effect():
	clear_points()