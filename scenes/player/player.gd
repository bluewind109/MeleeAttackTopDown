extends CharacterBody2D
class_name Player

@export var state_machine: CallableStateMachine

@export var character_sprite: Sprite2D
var idle_texture: Texture2D = preload("./sprites/Player_idle.png")
var run_texture: Texture2D = preload("./sprites/Player_run.png")

@export var component_health: ComponentHealth
@export var component_look: ComponentLook
@export var component_velocity: ComponentVelocity
@export var component_anim_ss: ComponentAnimSpriteSheet
@export var trail_effect: ComponentTrailEffect
@export var component_charge_dash: ChargeDash

var max_health: float = 100.0

var STATE: Dictionary[String, String] = {
	"Idle": "Idle",
	"Run": "Run",
	"Attack": "Attack",
}

@export var anim_player: AnimationPlayer
var anim_dict: Dictionary [String, Variant] = {
	"idle": {
		"anim_id": "player_idle",
		"texture": idle_texture,
		"hframes": 6
	},
	"run": {
		"anim_id": "player_run",
		"texture": run_texture,
		"hframes": 8
	},
}
var current_anim: String = ""

func _ready() -> void:
	component_velocity.owner_node = self
	component_charge_dash.on_dash_started.connect(_on_dash_started)
	component_charge_dash.on_dash_finished.connect(_on_dash_finished)

	state_machine.add_states(STATE.Idle, CallableState.new(
		_on_idle_state,
		_on_enter_idle_state,
		_on_leave_idle_state
	))

	state_machine.add_states(STATE.Run, CallableState.new(
		_on_run_state,
		_on_enter_run_state,
		_on_leave_run_state
	))

	state_machine.set_initial_state(STATE.Idle)

	var health = max_health
	component_health.init.call_deferred(max_health, health)

	trail_effect.toggle_effect(false)

func _physics_process(delta: float) -> void:
	state_machine.update(delta)

	var target_pos = get_global_mouse_position()
	component_look.look(target_pos)

func _play_anim(anim_name: String):
	if (not anim_dict.has(anim_name)): return
	if (current_anim == anim_name): return
	# print("_play_anim: ", anim_name)
	var sprite_size: float = 32
	var anim_data: Variant = anim_dict[anim_name]
	character_sprite.texture = anim_data.texture
	character_sprite.hframes = anim_data.hframes
	character_sprite.region_rect.size = Vector2(sprite_size * character_sprite.hframes, sprite_size)
	anim_player.play(anim_dict[anim_name].anim_id)
	anim_player.speed_scale = 0.25
	current_anim = anim_name

func _on_enter_idle_state():
	_play_anim("idle")

func _on_idle_state(_delta: float):
	if (velocity != Vector2.ZERO):
		state_machine.change_state(STATE.Run)

func _on_leave_idle_state():
	pass

func _on_enter_run_state():
	_play_anim("run")

func _on_run_state(_delta: float):
	if (velocity == Vector2.ZERO):
		state_machine.change_state(STATE.Idle)

func _on_leave_run_state():
	pass

func _on_dash_started():
	trail_effect.toggle_effect(true)

func _on_dash_finished():
	trail_effect.toggle_effect(false)
