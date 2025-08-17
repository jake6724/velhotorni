extends Node

var timer: Timer = Timer.new()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(timer)
	timer.ignore_time_scale = true

func apply_time_stop() -> void:
	# Need vars for all these 
	Engine.time_scale = 0.1
	timer.start(.1)
	await timer.timeout
	Engine.time_scale = 1