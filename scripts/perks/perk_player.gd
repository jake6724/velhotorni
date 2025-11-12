class_name PerkPlayer
extends Perk

signal modify_stat_requested
signal timed_modify_stat_requested

var spell_damage_accumulated: float = 0

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataPlayer.PlayerPerkAction.MODIFY_PLAYER_STAT: modify_stat_requested.emit(data)
		PerkDataPlayer.PlayerPerkAction.MODIFY_TIMED_PLAYER_STAT: timed_modify_player_stat(data.stat, data.base_value, data.duration)

func timed_modify_player_stat(stat_to_modify: PerkDataPlayer.PlayerStat, value: float, duration: float) -> void:
	timed_modify_stat_requested.emit(stat_to_modify, value, duration)

## Called each time PlayerSpellSpawner emits `DamageDealt`. Accumulates damage until `data.required_spell_damage` is 
## met or surpassed; `perk_action()` is then called and spell_damage_accumulated reset (does not save overkill damage)
func accumulate_spell_damage(damage_applied: float) -> void:
	spell_damage_accumulated += damage_applied
	if spell_damage_accumulated > data.required_spell_damage:
		perk_action()
		spell_damage_accumulated = 0