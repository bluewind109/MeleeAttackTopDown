extends Node2D
class_name ComponentMeleeWeapon

@export var component_hitbox: ComponentHitbox

@export var pivot: Marker2D
@export var weapon_sprite: Sprite2D
@export var animation_player: AnimationPlayer

@export var is_custom_position: bool = false
@export var is_custom_rotation: bool = false
@export var rotation_range: Vector2 = Vector2(355, 275)

@export var is_attacking: bool = false

func _ready() -> void:
	component_hitbox.toggle_hitbox(false)

func _process(_delta: float) -> void:
	if (Input.is_action_pressed("attack")):
		attack()

func _physics_process(_delta):
	if (is_attacking): return
	var mouse_pos: Vector2 = get_global_mouse_position()
	pivot.look_at(mouse_pos)

	if (mouse_pos.x < global_position.x):
		pivot.scale.y = -1
	else:
		pivot.scale.y = 1

func attack():
	if (is_attacking): return
	is_attacking = true
	animation_player.play("attack1")
