class_name DebuffWeaken
extends Debuff

## Emitted with a value to reduce `speed` by
signal debuff_apply_weaken

## Emitted with a value to increase `speed` by
signal debuff_remove_weaken

func start_debuff() -> void:
	debuff_apply_weaken.emit(data.value)
	total_timer.start(data.modified_total_duration)

func on_total_timer_timeout() -> void:
	debuff_remove_weaken.emit()
	queue_free()