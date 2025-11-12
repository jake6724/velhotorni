class_name PlayerSpellPerkManager
extends Node

@onready var player = get_owner()

func on_modify_stat_requested(perk_data: PerkData) -> void:
	match perk_data.stat:
		PerkDataSpell.SpellStat.MANA_MAX: 
			player.player_mana.increase_all_weapon_of_element_max_mana(perk_data.element, perk_data.base_value)
			#player.player_mana.spell_mana_maxes[perk_data.element] += (player.player_mana.spell_mana_max_base[perk_data] * perk_data.value)

		PerkDataSpell.SpellStat.NONE: push_error("PlayerSpellPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")
