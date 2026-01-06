extends Node

signal spell_loadout_updated
signal tower_loadout_updated

func trigger_spell_loadout_update() -> void:
	equipped_spells = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]
	spell_loadout_updated.emit()

func trigger_tower_loadout_update() -> void:
	equipped_towers = [equipped_tower_1, equipped_tower_2, equipped_tower_3, equipped_tower_4, equipped_tower_5, equipped_tower_6]
	tower_loadout_updated.emit() 

var stars: int = 0

var light_shield: SpellData = preload("res://data/spells/light/spell_data_shield_directional_light.tres")
var arcane_basic: SpellData = preload("res://data/spells/spell_data_bullet_arcane_basic.tres")
var arcane_horn: SpellData = preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres")
var ice_sword: SpellData = preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres")
var fireball: SpellData = preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres")

# SPELLS ###################################################################################################################
var equipped_spell_1: SpellData = arcane_basic
var equipped_spell_2: SpellData = arcane_horn
var equipped_spell_3: SpellData = fireball
var equipped_spell_4: SpellData = ice_sword
var equipped_spells: Array[SpellData] = [equipped_spell_1, equipped_spell_2, equipped_spell_3, equipped_spell_4]

var spells: Dictionary[SpellData, bool] = {
	preload("res://data/spells/spell_data_bullet_arcane_basic.tres"): true,
	preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"): true,
	preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres"): true,
	preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"): false,
	light_shield: true,
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

# var towers: Dictionary[TowerData, bool] = {
# 	preload("res://data/towers/tower_data_fire.tres"): true,
# 	preload("res://data/towers/tower_data_wind.tres"): false,
# 	preload("res://data/towers/tower_data_water.tres"): false,
# 	preload("res://data/towers/tower_data_earth.tres"): false,
# 	preload("res://data/towers/tower_data_light.tres"): false,
# 	preload("res://data/towers/tower_data_dark.tres"): false,
# 	preload("res://data/towers/tower_data_fire_lava.tres"): false,
# 	preload("res://data/towers/tower_data_fire_plasma.tres"): false,
# 	preload("res://data/towers/tower_data_wind_storm.tres"): false,
# 	preload("res://data/towers/tower_data_wind_lightning.tres"): false,
# 	preload("res://data/towers/tower_data_earth_mud.tres"): false,
# 	preload("res://data/towers/tower_data_earth_crystal.tres"): false,
# 	preload("res://data/towers/tower_data_light_spirit.tres"): false,
# 	preload("res://data/towers/tower_data_light_sun.tres"): false,
# 	preload("res://data/towers/tower_data_dark_curse.tres"): false,
# 	preload("res://data/towers/tower_data_dark_void.tres"): false,
# }

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
