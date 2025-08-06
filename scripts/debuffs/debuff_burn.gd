class_name DebuffBurn
extends Debuff

## Emitted with a value to reduce `speed` by
signal debuff_apply_burn

## Emitted with a value to increase `speed` by
signal debuff_remove_burn

var can_burn: bool = true

func start_debuff() -> void:
	debuff_apply_burn.emit(data.value, data.element)
	repeat_timer.start(data.repeat_duration)
	total_timer.start(data.total_duration)

func on_repeat_timer_timeout() -> void:
	if can_burn:
		debuff_apply_burn.emit(data.value, data.element)
		repeat_timer.start(data.repeat_duration)

func on_total_timer_timeout() -> void:
	can_burn = false
	debuff_remove_burn.emit(self)
	queue_free()
