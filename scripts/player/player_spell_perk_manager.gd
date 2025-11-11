class_name PlayerSpellPerkManager
extends Node

@onready var player = get_owner()

func on_modify_stat_requested(stat_to_modify: PerkDataPlayer.PlayerStat, value: float, element: Constants.Element) -> void:
	match stat_to_modify:
		PerkDataSpell.SpellStat.MANA_MAX: 
			player.player_mana.spell_mana_maxes[element] += (player.player_mana.spell_mana_max_base[element] * value)

		PerkDataSpell.SpellStat.NONE: push_error("PlayerSpellPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")
