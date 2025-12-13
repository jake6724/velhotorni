class_name DebuffBurn
extends Debuff

"""
Burn scales on damage and uses modified_value, not modified_total_duration
"""

signal debuff_apply_burn
signal debuff_remove_burn

var can_burn: bool = false

## Call BEFORE add_child. Configure timer before adding to scene helps avoid a certain bug related to starting timer that 
## has not been added to scene.
func initialize() -> void:
	repeat_timer.autostart = true
	repeat_timer.wait_time = data.repeat_duration

func start_debuff() -> void:
	can_burn = true
	debuff_apply_burn.emit(data.modified_value, data.element)

func on_repeat_timer_timeout() -> void:
	if can_burn:
		debuff_apply_burn.emit(data.modified_value, data.element)
		repeat_timer.call_deferred("start",data.repeat_duration)

func on_total_timer_timeout() -> void:
	can_burn = false
	repeat_timer.stop()
	total_timer.stop()
	debuff_remove_burn.emit(self)
