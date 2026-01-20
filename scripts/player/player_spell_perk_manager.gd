class_name PlayerSpellPerkManager
extends Node

@onready var player: PlayerCharacter = get_owner()

func on_modify_stat_requested(perk_data: PerkData) -> void:
	match perk_data.stat:
		PerkDataSpell.SpellStat.MANA_MAX: 
			player.player_mana.increase_all_weapon_of_element_max_mana(perk_data.element, perk_data.base_value)
		PerkDataSpell.SpellStat.ELEMENT_DAMAGE:
			player.player_spell_spawner.spell_element_damage_perk_modifier[perk_data.element] += perk_data.base_value

		PerkDataSpell.SpellStat.NONE: push_error("PlayerSpellPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")