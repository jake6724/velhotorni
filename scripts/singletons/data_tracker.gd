## Used for tracking data that may be needed for tower performance or end of round reports
extends Node

var damage_totals_by_source: Dictionary[Variant, float] = {}

func submit_damage_data(_source: Variant, _damage_amount: float):
    if _source:
        if damage_totals_by_source.has(_source):
            damage_totals_by_source[_source] += _damage_amount
        else:
            damage_totals_by_source[_source] = _damage_amount
    else:
        push_error("DataTracker.submit_damage_data(): No source provided")