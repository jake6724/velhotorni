class_name PerkSpell
extends Perk

signal modify_stat_requested

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataSpell.SpellPerkAction.MODIFY_SPELL_STAT: modify_stat_requested.emit(data)