class_name PerkSpell
extends Perk

signal modify_stat_requested

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataSpell.SpellPerkAction.MODIFY_SPELL_STAT: modify_player_stat(data.stat, data.base_value, data.element)

func modify_player_stat(stat_to_modify: PerkDataSpell.SpellStat, value: float, element: Constants.Element) -> void:
	modify_stat_requested.emit(stat_to_modify, value, element)