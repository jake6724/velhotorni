extends Node

signal spell_loadout_updated
signal tower_loadout_updated

var player_level_index: int = 1

func trigger_spell_loadout_update() -> void:
	equipped_spells = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]
	spell_loadout_updated.emit()

func trigger_tower_loadout_update() -> void:
	equipped_towers = [equipped_tower_1, equipped_tower_2, equipped_tower_3, equipped_tower_4, equipped_tower_5, equipped_tower_6]
	tower_loadout_updated.emit() 

# SPELLS ###################################################################################################################
var light_shield: SpellData = load("res://data/spells/light/spell_data_shield_directional_light.tres")
var arcane_basic: SpellData = load("res://data/spells/spell_data_bullet_arcane_basic.tres")
var arcane_horn: SpellData = load("res://data/spells/spell_data_bullet_arcane_basic_triple.tres")
var ice_sword: SpellData = load("res://data/spells/water/spell_data_melee_water_ice_sword.tres")
var fireball: SpellData = load("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres")
var tornado: SpellData = load("res://data/spells/spell_data_melee_bullet_wind_tornado.tres")
var dark_revolver: SpellData = load("res://data/spells/spell_data_bullet_dark_revolver.tres")
var earth_drill: SpellData = load("res://data/spells/spell_data_bullet_earth_drill.tres")
var test: SpellData = load("res://data/spells/spell_data_bullet_arcane_flamethrower.tres")
var arcane_dagger: SpellData = load("res://data/spells/spell_data_melee_arcane_dagger.tres")

var equipped_spell_1: SpellData = fireball
var equipped_spell_2: SpellData = light_shield
var equipped_spell_3: SpellData = arcane_basic
var equipped_spell_4: SpellData = ice_sword
var equipped_spells: Array[SpellData] = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]

var spells: Dictionary[SpellData, bool] = {
	arcane_basic: true,
	arcane_horn: true,
	ice_sword: true,
	fireball: true,
	light_shield: true,
	tornado: true,
	dark_revolver: true,
	earth_drill: true,
	arcane_dagger: true,
}

# TOWERS ###################################################################################################################
# Preload started causing issues after I added the bullet_modifier stuff in TowerGlobal data (and other related scripts such as bullet) when working on perk_data_tower_bullet_modifier_coin. Likely caused a cyclical dependency
var equipped_tower_1: TowerData = load("res://data/towers/tower_data_earth.tres")
var equipped_tower_2: TowerData = load("res://data/towers/tower_data_fire_plasma.tres")
var equipped_tower_3: TowerData = load("res://data/towers/tower_data_dark.tres")
var equipped_tower_4: TowerData = load("res://data/towers/tower_data_water.tres")
var equipped_tower_5: TowerData = load("res://data/towers/tower_data_wind_storm.tres")
var equipped_tower_6: TowerData = load("res://data/towers/tower_data_arcane.tres")
var equipped_towers: Array[TowerData] = [equipped_tower_1, equipped_tower_2, equipped_tower_3, 
equipped_tower_4, equipped_tower_5, equipped_tower_6]

var towers: Dictionary[TowerData, bool] = {
	load("res://data/towers/tower_data_fire.tres"): true,
	load("res://data/towers/tower_data_fire_lava.tres"): true,
	load("res://data/towers/tower_data_fire_plasma.tres"): true,
	load("res://data/towers/tower_data_wind.tres"): true,
	load("res://data/towers/tower_data_wind_storm.tres"): true,
	load("res://data/towers/tower_data_wind_lightning.tres"): true,
	load("res://data/towers/tower_data_water.tres"): true,
	load("res://data/towers/tower_data_water_ice.tres"): true,
	load("res://data/towers/tower_data_water_flood.tres"): true,
	load("res://data/towers/tower_data_earth.tres"): true,
	load("res://data/towers/tower_data_earth_mud.tres"): true,
	load("res://data/towers/tower_data_earth_crystal.tres"): true,
	load("res://data/towers/tower_data_light.tres"): true,
	load("res://data/towers/tower_data_light_spirit.tres"): true,
	load("res://data/towers/tower_data_light_sun.tres"): true,
	load("res://data/towers/tower_data_dark.tres"): true,
	load("res://data/towers/tower_data_dark_curse.tres"): true,
	load("res://data/towers/tower_data_dark_void.tres"): true,
	load("res://data/towers/tower_data_arcane.tres"): true,
}