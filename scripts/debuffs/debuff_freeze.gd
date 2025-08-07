class_name DebuffFreeze
extends Debuff

## Emitted with a value to reduce `speed` by
signal debuff_apply_freeze

## Emitted with a value to increase `speed` by
signal debuff_remove_freeze

func start_debuff() -> void:
	debuff_apply_freeze.emit()
	total_timer.start(data.modified_total_duration)

func on_total_timer_timeout() -> void:
	debuff_remove_freeze.emit()
	queue_free()
