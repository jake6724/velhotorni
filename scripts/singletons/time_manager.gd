extends Node

var timer: Timer = Timer.new()

const NORMAL_SPEED: float = 1
const FAST_FORWARD_SPEED: float = 2

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.time_scale = NORMAL_SPEED
	Engine.physics_ticks_per_second = 60 * NORMAL_SPEED

	# add_child(timer)
	# timer.ignore_time_scale = true

func set_fast_forward_speed() -> void:
	Engine.time_scale = FAST_FORWARD_SPEED
	Engine.physics_ticks_per_second = 60 * FAST_FORWARD_SPEED

func set_normal_speed() -> void:
	Engine.time_scale = 1
	Engine.physics_ticks_per_second = 60 * NORMAL_SPEED

# func set_fast_forward_speed() -> void:
# 	Engine.time_scale = FAST_FORWARD_SPEED

# func set_normal_speed() -> void:
# 	Engine.time_scale = 1

# func apply_time_stop() -> void:
# # 	# Need vars for all these 
# # 	Engine.time_scale = 0.1
# # 	timer.start(.1)
# # 	await timer.timeout
# # 	Engine.time_scale = 1
