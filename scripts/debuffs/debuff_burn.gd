class_name DebuffBurn
extends Debuff

"""
Burn scales on damage and uses modified_value, not modified_total_duration
"""

signal debuff_apply_burn
signal debuff_remove_burn

var can_burn: bool = true

func start_debuff() -> void:
	if can_burn:
		debuff_apply_burn.emit(data.modified_value, data.element)
		if repeat_timer.is_node_ready(): repeat_timer.start(data.repeat_duration)
		if total_timer.is_node_ready(): total_timer.start(data.total_duration)

func on_repeat_timer_timeout() -> void:
	if can_burn:
		debuff_apply_burn.emit(data.modified_value, data.element)
		repeat_timer.start(data.repeat_duration)

func on_total_timer_timeout() -> void:
	can_burn = false
	repeat_timer.stop()
	debuff_remove_burn.emit(self)
