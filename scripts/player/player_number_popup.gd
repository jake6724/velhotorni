class_name PlayerNumberPopup
extends NumberPopup

var up_distance_timer: Timer = Timer.new()

var up_distance_increment: int = 12
var up_distance_reset_delay: float = 1.0


func _ready():
	up_distance_timer.autostart = false
	up_distance_timer.one_shot = true
	up_distance_timer.timeout.connect(on_up_distance_timer_timeout)
	add_child(up_distance_timer)

	up_distance = 32

func increase_up_distance() -> void:
	up_distance += up_distance_increment
	up_distance_timer.start(up_distance_reset_delay)

func on_up_distance_timer_timeout() -> void:
	reset_up_distance()

func reset_up_distance() -> void:
	up_distance = 64