extends Node

var hitstun_timer: Timer = Timer.new()

const HALF_SPEED: float = .5
const NORMAL_SPEED: float = 1
const FAST_FORWARD_SPEED: float = 10
const HITSTOP_SPEED: float = 0
const HITSTOP_DURATION: float = .1

func _input(_event):
	if Input.is_action_just_pressed("q"):
		set_fast_forward_speed()
	if Input.is_action_just_released("q"):
		set_normal_speed()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.time_scale = NORMAL_SPEED
	Engine.physics_ticks_per_second = 60 * NORMAL_SPEED


	hitstun_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	hitstun_timer.ignore_time_scale = true
	hitstun_timer.one_shot = true
	hitstun_timer.autostart = false
	add_child(hitstun_timer)
	hitstun_timer.timeout.connect(on_hitstun_timer_timeout)

func set_fast_forward_speed() -> void:
	Engine.time_scale = FAST_FORWARD_SPEED 
	Engine.physics_ticks_per_second = 60 * FAST_FORWARD_SPEED

func set_normal_speed() -> void:
	Engine.time_scale = 1
	Engine.physics_ticks_per_second = 60 * NORMAL_SPEED

func set_half_speed() -> void:
	Engine.time_scale = HALF_SPEED
	Engine.physics_ticks_per_second = 60 * HALF_SPEED

func apply_hitstop() -> void:
	Engine.time_scale = HITSTOP_SPEED
	hitstun_timer.start(HITSTOP_DURATION)

func on_hitstun_timer_timeout() -> void:
	Engine.time_scale = NORMAL_SPEED