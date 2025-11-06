class_name PerkBase
extends Perk

signal modify_stat_requested

var spell_damage_accumulated: float = 0

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataBase.BasePerkAction.BaseStat: modify_base_stat(data.stat, data.base_value)
	
func modify_base_stat(stat_to_modify: PerkDataBase.BaseStat, value: float) -> void:
	modify_stat_requested.emit(stat_to_modify, value)

## Called each time PlayerSpellSpawner emits `DamageDealt`. Accumulates damage until `data.required_spell_damage` is 
## met or surpassed; `perk_action()` is then called and spell_damage_accumulated reset (does not save overkill damage)
func accumulate_spell_damage(damage_applied: float) -> void:
	spell_damage_accumulated += damage_applied
	if spell_damage_accumulated > data.required_spell_damage:
		perk_action()
		spell_damage_accumulated = 0