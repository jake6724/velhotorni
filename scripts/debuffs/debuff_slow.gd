class_name DebuffSlow
extends Debuff

## Emitted with a value to reduce `speed` by
signal debuff_apply_slow

## Emitted with a value to increase `speed` by
signal debuff_remove_slow

func start_debuff() -> void:
	debuff_apply_slow.emit(data.value)
	total_timer.start(data.total_duration)
	print("Start slow debuff")

func on_total_timer_timeout() -> void:
	debuff_remove_slow.emit(data.value)
	queue_free()
	print("End slow debuff")
