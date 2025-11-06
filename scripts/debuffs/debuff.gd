class_name Debuff
extends Node

enum Type {SLOW, STUN, FREEZE, BURN, WEAKEN, KNOCKBACK, NONE}
enum Priority {LOWEST, LOW, MEDIUM, HIGH, HIGHEST}

var data: DebuffData

var total_timer: Timer = Timer.new()
var repeat_timer: Timer = Timer.new()

func _init(_data: DebuffData) -> void:
	data = _data

func _ready():
	add_child(total_timer)
	add_child(repeat_timer)

	total_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	repeat_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS

	total_timer.timeout.connect(on_total_timer_timeout)
	repeat_timer.timeout.connect(on_repeat_timer_timeout)

## Triggered at the end of `_ready()`
func start_debuff() -> void:
	pass

func on_total_timer_timeout() -> void:
	pass

func on_repeat_timer_timeout() -> void:
	pass
