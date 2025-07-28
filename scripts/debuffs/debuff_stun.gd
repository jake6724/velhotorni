class_name DebuffStun
extends Debuff

## Emitted with a value to reduce `speed` by
signal debuff_apply_stun

## Emitted with a value to increase `speed` by
signal debuff_remove_stun

func start_debuff() -> void:
	debuff_apply_stun.emit()
	total_timer.start(data.total_duration)

func on_total_timer_timeout() -> void:
	debuff_remove_stun.emit()
	queue_free()