extends CharacterBody2D
class_name Player

@export var state_machine: CallableStateMachine

@export var character_sprite: Sprite2D

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

var current_anim: String = ""

func _ready() -> void:
	component_velocity.owner_node = self
	component_charge_dash.on_dash_started.connect(_on_dash_started)
	component_charge_dash.on_dash_finished.connect(_on_dash_finished)

	component_anim_ss.init_anim_data({
		"idle": {
			"anim_id": "player_idle",
			"hframes": 10
		},
		"run": {
			"anim_id": "player_run",
			"hframes": 16
		},
		"wind_up": {
			"anim_id": "player_wind_up",
			"hframes": 4
		},
		"attack": {
			"anim_id": "player_attack",
			"hframes": 1
		}
	})

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

func _on_enter_idle_state():
	component_anim_ss.play_anim("idle")

func _on_idle_state(_delta: float):
	if (velocity != Vector2.ZERO):
		state_machine.change_state(STATE.Run)

func _on_leave_idle_state():
	pass

func _on_enter_run_state():
	component_anim_ss.play_anim("run")

func _on_run_state(_delta: float):
	if (velocity == Vector2.ZERO):
		state_machine.change_state(STATE.Idle)

func _on_leave_run_state():
	pass

func _on_dash_started():
	trail_effect.reset_effect()
	trail_effect.toggle_effect(true)

func _on_dash_finished():
	trail_effect.reset_effect()
	trail_effect.toggle_effect(false)
