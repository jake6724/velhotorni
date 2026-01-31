extends Node

signal spell_loadout_updated
signal tower_loadout_updated

func trigger_spell_loadout_update() -> void:
	equipped_spells = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]
	spell_loadout_updated.emit()

func trigger_tower_loadout_update() -> void:
	equipped_towers = [equipped_tower_1, equipped_tower_2, equipped_tower_3, equipped_tower_4, equipped_tower_5, equipped_tower_6]
	tower_loadout_updated.emit() 

var light_shield: SpellData = load("res://data/spells/light/spell_data_shield_directional_light.tres")
var arcane_basic: SpellData = load("res://data/spells/spell_data_bullet_arcane_basic.tres")
var arcane_horn: SpellData = load("res://data/spells/spell_data_bullet_arcane_basic_triple.tres")
var ice_sword: SpellData = load("res://data/spells/water/spell_data_melee_water_ice_sword.tres")
var fireball: SpellData = load("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres")

# SPELLS ###################################################################################################################
var equipped_spell_1: SpellData = arcane_basic
var equipped_spell_2: SpellData = arcane_horn
var equipped_spell_3: SpellData = fireball
var equipped_spell_4: SpellData = ice_sword
var equipped_spells: Array[SpellData] = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]

var spells: Dictionary[SpellData, bool] = {
	load("res://data/spells/spell_data_bullet_arcane_basic.tres"): true,
	load("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"): true,
	load("res://data/spells/water/spell_data_melee_water_ice_sword.tres"): true,
	load("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"): false,
	light_shield: true,
}

# TOWERS ###################################################################################################################
# Preload started causing issues after I added the bullet_modifier stuff in TowerGlobal data (and other related scripts such as bullet) when working on perk_data_tower_bullet_modifier_coin. Likely caused a cyclical dependency
var equipped_tower_1: TowerData = load("res://data/towers/tower_data_arcane.tres")
var equipped_tower_2: TowerData = load("res://data/towers/tower_data_wind_storm.tres")
var equipped_tower_3: TowerData = load("res://data/towers/tower_data_water_ice.tres")
var equipped_tower_4: TowerData = load("res://data/towers/tower_data_earth_crystal.tres")
var equipped_tower_5: TowerData = load("res://data/towers/tower_data_light.tres")
var equipped_tower_6: TowerData = load("res://data/towers/tower_data_dark.tres")
var equipped_towers: Array[TowerData] = [equipped_tower_1, equipped_tower_2, equipped_tower_3, 
equipped_tower_4, equipped_tower_5, equipped_tower_6]

var towers: Dictionary[TowerData, bool] = {
	preload("res://data/towers/tower_data_fire.tres"): true,
	preload("res://data/towers/tower_data_fire_lava.tres"): false,
	preload("res://data/towers/tower_data_fire_plasma.tres"): false,
	preload("res://data/towers/tower_data_wind.tres"): false,
	preload("res://data/towers/tower_data_wind_storm.tres"): false,
	preload("res://data/towers/tower_data_wind_lightning.tres"): false,
	preload("res://data/towers/tower_data_water.tres"): false,
	preload("res://data/towers/tower_data_water_ice.tres"): false,
	preload("res://data/towers/tower_data_water_flood.tres"): false,
	preload("res://data/towers/tower_data_earth.tres"): false,
	preload("res://data/towers/tower_data_earth_mud.tres"): false,
	preload("res://data/towers/tower_data_earth_crystal.tres"): false,
	preload("res://data/towers/tower_data_light.tres"): false,
	preload("res://data/towers/tower_data_light_spirit.tres"): false,
	preload("res://data/towers/tower_data_light_sun.tres"): false,
	preload("res://data/towers/tower_data_dark.tres"): false,
	preload("res://data/towers/tower_data_dark_curse.tres"): false,
	preload("res://data/towers/tower_data_dark_void.tres"): false,
	preload("res://data/towers/tower_data_arcane.tres"): true,
}
