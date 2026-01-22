class_name PlayerSpellPerkManager
extends Node

@onready var player: PlayerCharacter = get_owner()

func on_modify_stat_requested(perk_data: PerkData) -> void:
	match perk_data.stat:
		PerkDataSpell.SpellStat.MANA_MAX: 
			print("Max mana perk called")
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
		
		PerkDataSpell.SpellStat.NONE: push_error("PlayerSpellPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")