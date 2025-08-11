class_name BoonArea
extends Area2D

@onready var boon_collider: CollisionShape2D = $BoonCollider

var boon_data: BoonData
var cast_timer: Timer

func _ready():
	pass
	# cast_timer.timeout.connect(on_cast_timer_timeout)

func initialize(_boon_data: BoonData):
	boon_data = _boon_data
	
	match boon_data.mode:
		Boon.Mode.TIMER: 
			cast_timer = Timer.new()
			cast_timer.timeout.connect(on_cast_timer_timeout)
			cast_timer.start(boon_data.cast_speed)

		Boon.Mode.COLLISION:
			boon_collider.area_entered.connect(on_buff_area_entered)
			boon_collider.area_exited.connect(on_buff_area_exited)
			
func on_cast_timer_timeout() -> void:
	pass

func on_buff_area_entered(intruder) -> void:
	pass

func on_buff_area_exited(intruder) -> void:
	pass