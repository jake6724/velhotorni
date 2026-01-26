class_name PerkDataPool
extends Resource

@export var perks: Array[PerkData] = [
    # Player Basic
    # preload("res://data/perks/player/basic/perk_data_player_health_on_wc.tres"),
    preload("res://data/perks/player/basic/perk_data_player_max_health.tres"),
    preload("res://data/perks/player/basic/perk_data_player_move_speed.tres"),
    preload("res://data/perks/player/basic/perk_data_player_special_cooldown.tres"),
    # preload("res://data/perks/player/basic/perk_data_player_timed_move_speed_on_spell_mana.tres"),
    # Player Legendary
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_increase_iframes_on_dmg.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_reflect_chance.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_restore_health_on_spell_dmg.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_special_cooldown.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_special_max_charge.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_speed_on_dmg.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_aoe_on_dmg_wind.tres"),
    # preload("res://data/perks/player/legendary/perk_data_player_lgd_aoe_on_special_wind.tres"),

    # Tower Basic
    # preload("res://data/perks/tower/basic/perk_data_tower_cap.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_cost_fire.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_range.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_mana_drop.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_fire_placement_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_wind_placement_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_water_placement_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_earth_placement_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_light_placement_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_dark_placement_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_burn.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_knockback.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_slow.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_weaken.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_bullet_modifier_coin.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_fire_upgrade_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_wind_upgrade_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_water_upgrade_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_light_upgrade_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_dark_upgrade_cost.tres"),
    # preload("res://data/perks/tower/basic/perk_data_tower_earth_upgrade_cost.tres"),
    # Tower Legendary
    # preload("res://data/perks/tower/legendary/perk_data_tower_lgd_knockback.tres"),
    # preload("res://data/perks/tower/legendary/perk_data_tower_lgd_reflect_chance.tres"),

    # Spell Basic
    # preload("res://data/perks/spell/basic/perk_data_spell_damage_fire.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_damage_wind.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_damage_water.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_damage_earth.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_damage_light.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_damage_dark.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_cooldown_fire.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_cooldown_wind.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_cooldown_water.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_cooldown_earth.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_cooldown_light.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_cooldown_dark.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_free_cast_fire.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_free_cast_wind.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_free_cast_water.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_free_cast_earth.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_free_cast_light.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_free_cast_dark.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_max_mana_fire.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_max_mana_wind.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_max_mana_water.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_max_mana_earth.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_max_mana_light.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_max_mana_dark.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_execute.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_double_spell_mana_drop.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_debuff_chance_knockback.tres"),
    # preload("res://data/perks/spell/basic/perk_data_spell_mana_drop.tres"),
    # Spell Legendary
    # preload("res://data/perks/spell/legendary/perk_data_spell_lgd_triple_max_mana_fire_wind_water.tres"),
    # preload("res://data/perks/spell/legendary/perk_data_spell_lgd_mana_drop_chance_dmg_fire.tres"),
    # preload("res://data/perks/spell/legendary/perk_data_spell_lgd_mana_drop_chance_dmg_wind.tres"),
    # preload("res://data/perks/spell/legendary/perk_data_spell_lgd_mana_drop_chance_dmg_water.tres"),
    # preload("res://data/perks/spell/legendary/perk_data_spell_spawn_tower_mana_as_spell.tres")
    
    # Base Basic
    # preload("res://data/perks/base/basic/perk_data_base_health_on_wc.tres"),
    # preload("res://data/perks/base/basic/perk_data_base_max_health.tres"),
    # Base Legendary
    # preload("res://data/perks/base/legendary/perk_data_base_lgd_restore_health_on_spell_dmg.tres"),
]