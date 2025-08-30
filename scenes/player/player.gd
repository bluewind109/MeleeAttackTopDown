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
	"WindUp": "WindUp",
	"Attack": "Attack",
}
var speed_dict: Dictionary[String, float] = {}

var current_anim: String = ""

func _ready() -> void:
	init_speed_dict()
	init_anim_dict("")
	bind_signals()

	component_velocity.owner_node = self
	var health = max_health
	component_health.init.call_deferred(max_health, health)
	trail_effect.toggle_effect(false)

	add_states()

func init_speed_dict():
	speed_dict = {
		STATE.Idle: 150.0,
		STATE.Run: 75.0,
		STATE.WindUp: 150.0,
		STATE.Attack: 150.0,
	}

func init_anim_dict(_lib_name: String):
	var lib_name = ""
	if (_lib_name != ""): lib_name = _lib_name + "/"
	component_anim_ss.init_anim_data({
		"idle": {
			"anim_id": lib_name + "player_idle",
			"hframes": 10
		},
		"run": {
			"anim_id": lib_name + "player_run",
			"hframes": 16
		},
		"wind_up": {
			"anim_id": lib_name + "player_wind_up",
			"hframes": 4
		},
		"attack": {
			"anim_id": lib_name + "player_attack",
			"hframes": 1
		}
	})

func bind_signals():
	component_charge_dash.on_dash_wind_up.connect(_on_dash_wind_up)
	component_charge_dash.on_dash_started.connect(_on_dash_started)
	component_charge_dash.on_dash_finished.connect(_on_dash_finished)

func add_states():
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

	state_machine.add_states(STATE.WindUp, CallableState.new(
		_on_wind_up_state,
		_on_enter_wind_up_state,
		_on_leave_wind_up_state
	))

	state_machine.add_states(STATE.Attack, CallableState.new(
		_on_attack_state,
		_on_enter_attack_state,
		_on_leave_attack_state
	))

	state_machine.set_initial_state(STATE.Idle)

func _physics_process(delta: float) -> void:
	state_machine.update(delta)


func _on_enter_idle_state():
	component_anim_ss.play_anim("idle")

func _on_idle_state(_delta: float):
	# if (velocity != Vector2.ZERO):
	# 	state_machine.change_state(STATE.Run)
	component_look.look(get_global_mouse_position())

func _on_leave_idle_state():
	pass

func _on_enter_run_state():
	component_anim_ss.play_anim("run")

func _on_run_state(_delta: float):
	if (velocity == Vector2.ZERO):
		state_machine.change_state(STATE.Idle)
	component_look.look(get_global_mouse_position())

func _on_leave_run_state():
	pass

func _on_enter_wind_up_state():
	component_anim_ss.play_anim("wind_up")

func _on_wind_up_state(_delta: float):
	component_look.look(get_global_mouse_position())

func _on_leave_wind_up_state():
	pass

func _on_enter_attack_state():
	component_anim_ss.play_anim("attack")

func _on_attack_state(_delta: float):
	pass

func _on_leave_attack_state():
	pass

func _on_dash_wind_up():
	state_machine.change_state(STATE.WindUp)

func _on_dash_started():
	state_machine.change_state(STATE.Attack)
	trail_effect.reset_effect()
	trail_effect.toggle_effect(true)

func _on_dash_finished():
	state_machine.change_state(STATE.Idle)
	trail_effect.reset_effect()
	trail_effect.toggle_effect(false)
