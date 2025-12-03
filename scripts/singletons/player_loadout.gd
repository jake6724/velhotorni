extends Node

# SPELLS ###################################################################################################################
var equipped_spell_1: SpellData = preload("res://data/spells/spell_data_bullet_arcane_basic.tres")
var equipped_spell_2: SpellData = preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres")
var equipped_spell_3: SpellData = preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres")
var equipped_spell_4: SpellData = preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres")
var equipped_spells: Array[SpellData] = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]

var spells: Dictionary[SpellData, bool] = {
	preload("res://data/spells/spell_data_bullet_arcane_basic.tres"): true,
	preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"): true,
	preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres"): true,
	preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"): true,
}


# TOWERS ###################################################################################################################
var equipped_tower_1: TowerData = preload("res://data/towers/tower_data_fire.tres")
var equipped_tower_2: TowerData = preload("res://data/towers/tower_data_wind.tres")
var equipped_tower_3: TowerData = preload("res://data/towers/tower_data_water.tres")
var equipped_tower_4: TowerData = null
var equipped_tower_5: TowerData = null
var equipped_tower_6: TowerData = null
var equipped_towers: Array[TowerData] = [equipped_tower_1, equipped_tower_2, equipped_tower_3, 
equipped_tower_4, equipped_tower_5, equipped_tower_6]

var towers: Dictionary[TowerData, bool] = {
	preload("res://data/towers/tower_data_fire.tres"): true,
	preload("res://data/towers/tower_data_wind.tres"): true,
	preload("res://data/towers/tower_data_water.tres"): true,
	preload("res://data/towers/tower_data_earth.tres"): true,
	preload("res://data/towers/tower_data_light.tres"): true,
	preload("res://data/towers/tower_data_dark.tres"): true,
	preload("res://data/towers/tower_data_fire_lava.tres"): true,
	preload("res://data/towers/tower_data_fire_plasma.tres"): true,
	preload("res://data/towers/tower_data_wind_storm.tres"): true,
	preload("res://data/towers/tower_data_wind_lightning.tres"): true,
	preload("res://data/towers/tower_data_earth_mud.tres"): true,
	preload("res://data/towers/tower_data_earth_crystal.tres"): true,
	preload("res://data/towers/tower_data_light_spirit.tres"): true,
	preload("res://data/towers/tower_data_light_sun.tres"): true,
	preload("res://data/towers/tower_data_dark_curse.tres"): true,
	preload("res://data/towers/tower_data_dark_void.tres"): true,
}