extends Line2D
class_name TrajectoryLine

@export var character_body_2d: CharacterBody2D

func _ready() -> void:
	pass

func get_body() -> CharacterBody2D:
	return character_body_2d
