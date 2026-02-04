class_name PlayerSpellPerkManager
extends Node

@onready var player: PlayerCharacter = get_owner()

## Observed by ManaDropManager, connected in Main
signal spell_mana_drop_perk_bonus_incremented
signal spell_mana_drop_chance_multiplier_added

## Observed by CoinDropManager
signal spawn_tower_mana_as_spell_mana_chance_incremented

func on_modify_stat_requested(perk_data: PerkData) -> void:
	match perk_data.stat:
		PerkDataSpell.SpellStat.MANA_MAX: 
			player.player_mana.increase_all_weapon_of_element_max_mana(perk_data.element, perk_data.base_value)
		PerkDataSpell.SpellStat.ELEMENT_DAMAGE:
			player.player_spell_spawner.spell_element_damage_perk_modifier[perk_data.element] += perk_data.base_value
		PerkDataSpell.SpellStat.COOLDOWN:
			player.player_spell_spawner.spell_element_cooldown_perk_modifier[perk_data.element] += perk_data.base_value
		PerkDataSpell.SpellStat.FREE_CAST:
			player.player_spell_spawner.spell_element_free_cast_perk_modifier[perk_data.element] += perk_data.base_value
		PerkDataSpell.SpellStat.EXECUTE:
			player.player_spell_spawner.spell_execution_threshold += perk_data.base_value
		PerkDataSpell.SpellStat.DOUBLE_SPELL_MANA_CHANCE:
			player.player_spell_spawner.double_spell_mana_drop_chance += perk_data.base_value

		PerkDataSpell.SpellStat.PERK_DEBUFF_CHANCE: #TODO: Not the cleanest way to do this
			var debuff_data: DebuffData
			match perk_data.debuff_type:
				Debuff.Type.BURN: debuff_data = preload("res://data/debuffs/perk_debuffs/debuff_data_burn_perk.tres")
				Debuff.Type.KNOCKBACK: debuff_data = preload("res://data/debuffs/perk_debuffs/debuff_data_knockback_perk.tres")
				Debuff.Type.SLOW: debuff_data = preload("res://data/debuffs/perk_debuffs/debuff_data_slow_perk.tres")
				Debuff.Type.FREEZE: debuff_data = preload("res://data/debuffs/perk_debuffs/debuff_data_freeze_perk.tres")
				Debuff.Type.STUN: debuff_data = preload("res://data/debuffs/perk_debuffs/debuff_data_stun_perk.tres")
				Debuff.Type.WEAKEN: debuff_data = preload("res://data/debuffs/perk_debuffs/debuff_data_weaken_perk.tres")
			player.player_spell_spawner.perk_debuffs[debuff_data] += perk_data.base_value

		PerkDataSpell.SpellStat.SPELL_MANA_DROP:
			spell_mana_drop_perk_bonus_incremented.emit(perk_data.base_value)
		PerkDataSpell.SpellStat.MANA_MAX_LIST:
			for element_list_item: Constants.Element in perk_data.element_list:
				player.player_mana.increase_all_weapon_of_element_max_mana(element_list_item, perk_data.base_value)
		PerkDataSpell.SpellStat.MANA_DROP_CHANCE_INCREASE_DAMAGE:
			# Signal to ManaDropManager that all fire spell chances should increase
			spell_mana_drop_chance_multiplier_added.emit(player.player_spells.get_all_spell_data_of_element(perk_data.element), perk_data.secondary_value)
			# Increase damage of element's spells
			player.player_spell_spawner.spell_element_damage_perk_modifier[perk_data.element] += perk_data.base_value

			# DIRECTLY MODIFY TowerGlobalData. Probably not a great idea but here we are...
			TowerGlobalData.tower_element_damage_perk_modifier[perk_data.element] += perk_data.base_value
		PerkDataSpell.SpellStat.SPAWN_TOWER_MANA_AS_SPELL_MANA_CHANCE:
			spawn_tower_mana_as_spell_mana_chance_incremented.emit(perk_data.base_value)

		PerkDataSpell.SpellStat.NONE: push_error("PlayerSpellPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")