extends Node

var equipped_spell_1: SpellData
var equipped_spell_2: SpellData
var equipped_spell_3: SpellData
var equipped_spell_4: SpellData

var unlocked_spells: Array[SpellData] = [
	preload("res://data/spells/spell_data_bullet_arcane_basic.tres"),
	preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"),
	preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres"),
	preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"),
	preload("res://data/spells/spell_data_bullet_arcane_basic.tres"),
	preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"),
	preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"),
	preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres"),
	preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"),
	preload("res://data/spells/spell_data_bullet_arcane_basic.tres"),
	
	preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres"),
	preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"),
	preload("res://data/spells/fire/spell_data_bullet_aoe_fireball.tres"),
	
	preload("res://data/spells/spell_data_bullet_arcane_basic_triple.tres"),
	preload("res://data/spells/water/spell_data_melee_water_ice_sword.tres"),
	preload("res://data/spells/spell_data_bullet_arcane_basic.tres"),
	
]