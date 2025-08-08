extends Node2D
class_name ComponentProjectileVelocity

var target_pos: Vector2
var direction: Vector2 = Vector2.ZERO
var speed: float = 75

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if (direction):
		get_parent().global_position += direction * speed * delta
