class_name DebuffKnockback
extends Debuff

## Emitted with a value to reduce `speed` by
signal debuff_apply_knockback

## Emitted with a value to increase `speed` by
signal debuff_remove_knockback

func start_debuff() -> void:
	debuff_apply_knockback.emit(data.modified_value)
	total_timer.start(data.total_duration)

func on_total_timer_timeout() -> void:
	debuff_remove_knockback.emit()
	queue_free()