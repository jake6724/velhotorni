extends Node

signal spell_loadout_updated
signal tower_loadout_updated

var player_level_index: int = 3

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

var tower_fire: TowerData = load("res://data/towers/tower_data_fire.tres")
var tower_lava: TowerData = load("res://data/towers/tower_data_fire_lava.tres")
var tower_plasma: TowerData = load("res://data/towers/tower_data_fire_plasma.tres")
var tower_wind: TowerData = load("res://data/towers/tower_data_wind.tres")
var tower_storm: TowerData = load("res://data/towers/tower_data_wind_storm.tres")
var tower_lightning: TowerData = load("res://data/towers/tower_data_wind_lightning.tres")
var tower_water: TowerData = load("res://data/towers/tower_data_water.tres")
var tower_ice: TowerData = load("res://data/towers/tower_data_water_ice.tres")
var tower_flood: TowerData = load("res://data/towers/tower_data_water_flood.tres")
var tower_earth: TowerData = load("res://data/towers/tower_data_earth.tres")
var tower_mud: TowerData = load("res://data/towers/tower_data_earth_mud.tres")
var tower_crystal: TowerData = load("res://data/towers/tower_data_earth_crystal.tres")
var tower_light: TowerData = load("res://data/towers/tower_data_light.tres")
var tower_spirit: TowerData = load("res://data/towers/tower_data_light_spirit.tres")
var tower_sun: TowerData = load("res://data/towers/tower_data_light_sun.tres")
var tower_dark: TowerData = load("res://data/towers/tower_data_dark.tres")
var tower_curse: TowerData = load("res://data/towers/tower_data_dark_curse.tres")
var tower_void: TowerData = load("res://data/towers/tower_data_dark_void.tres")
var tower_arcane: TowerData = load("res://data/towers/tower_data_arcane.tres")

var equipped_tower_1: TowerData = tower_fire
var equipped_tower_2: TowerData = tower_wind
var equipped_tower_3: TowerData = tower_crystal
var equipped_tower_4: TowerData = tower_ice
var equipped_tower_5: TowerData = tower_sun
var equipped_tower_6: TowerData = tower_void
var equipped_towers: Array[TowerData] = [equipped_tower_1, equipped_tower_2, equipped_tower_3, 
equipped_tower_4, equipped_tower_5, equipped_tower_6]

var towers: Dictionary[TowerData, bool] = {
	tower_fire: true,
	tower_lava: true,
	tower_plasma: true,
	tower_wind: true,
	tower_storm: true,
	tower_lightning: true,
	tower_water: true,
	tower_ice: true,
	tower_flood: true,
	tower_earth: true,
	tower_mud: true,
	tower_crystal: true,
	tower_light: true,
	tower_spirit: true,
	tower_sun: true,
	tower_dark: true,
	tower_curse: true,
	tower_void: true,
	tower_arcane: true,
}