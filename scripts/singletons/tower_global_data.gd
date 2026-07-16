extends Node

const TOWER_MIN_UPGRADE_PRICE_MODIFIER: float = .01
var TOWER_MIN_PLACEMENT_PRICE: int = 1

var tower_data: Dictionary[Constants.Element, TowerData] = {
	Constants.Element.FIRE: load("res://data/towers/tower_data_fire.tres"),
	Constants.Element.WIND: load("res://data/towers/tower_data_wind.tres"),
	Constants.Element.WATER: load("res://data/towers/tower_data_water.tres"),
	Constants.Element.EARTH: load("res://data/towers/tower_data_earth.tres"),
	Constants.Element.LIGHT: load("res://data/towers/tower_data_light.tres"),
	Constants.Element.DARK: load("res://data/towers/tower_data_dark.tres"),
	Constants.Element.LAVA: load("res://data/towers/tower_data_fire_lava.tres"),
	Constants.Element.PLASMA: load("res://data/towers/tower_data_fire_plasma.tres"),
	Constants.Element.STORM: load("res://data/towers/tower_data_wind_storm.tres"),
	Constants.Element.LIGHTNING: load("res://data/towers/tower_data_wind_lightning.tres"),
	Constants.Element.ICE: load("res://data/towers/tower_data_water_ice.tres"),
	Constants.Element.FLOOD: load("res://data/towers/tower_data_water_flood.tres"),
	Constants.Element.MUD: load("res://data/towers/tower_data_earth_mud.tres"),
	Constants.Element.CRYSTAL: load("res://data/towers/tower_data_earth_crystal.tres"),
	Constants.Element.SPIRIT: load("res://data/towers/tower_data_light_spirit.tres"),
	Constants.Element.SUN: load("res://data/towers/tower_data_light_sun.tres"),
	Constants.Element.CURSE: load("res://data/towers/tower_data_dark_curse.tres"),
	Constants.Element.VOID: load("res://data/towers/tower_data_dark_void.tres"),
	Constants.Element.ARCANE: load("res://data/towers/tower_data_arcane.tres"),
}

var tower_prices_base: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE:  50,
	Constants.Element.WIND:  50,
	Constants.Element.WATER: 50,
	Constants.Element.EARTH: 50,
	Constants.Element.LIGHT: 50,
	Constants.Element.DARK:  50,
	Constants.Element.LAVA: 75,
	Constants.Element.PLASMA: 100,
	Constants.Element.STORM: 75,
	Constants.Element.LIGHTNING: 100,
	Constants.Element.ICE: 75,
	Constants.Element.FLOOD: 100,
	Constants.Element.MUD: 100,
	Constants.Element.CRYSTAL: 75,
	Constants.Element.SPIRIT: 100,
	Constants.Element.SUN: 75,
	Constants.Element.CURSE: 75,
	Constants.Element.VOID: 100,
	Constants.Element.ARCANE: 50,
}

var tower_prices: Dictionary[Constants.Element, int] = {
	Constants.Element.FIRE:  tower_prices_base[Constants.Element.FIRE],
	Constants.Element.WIND:  tower_prices_base[Constants.Element.WIND],
	Constants.Element.WATER: tower_prices_base[Constants.Element.WATER],
	Constants.Element.EARTH: tower_prices_base[Constants.Element.EARTH],
	Constants.Element.LIGHT: tower_prices_base[Constants.Element.LIGHT],
	Constants.Element.DARK:  tower_prices_base[Constants.Element.DARK],
	Constants.Element.LAVA: tower_prices_base[Constants.Element.LAVA],
	Constants.Element.PLASMA: tower_prices_base[Constants.Element.PLASMA],
	Constants.Element.STORM: tower_prices_base[Constants.Element.STORM],
	Constants.Element.LIGHTNING: tower_prices_base[Constants.Element.LIGHTNING],
	Constants.Element.ICE: tower_prices_base[Constants.Element.ICE],
	Constants.Element.FLOOD: tower_prices_base[Constants.Element.FLOOD],
	Constants.Element.MUD: tower_prices_base[Constants.Element.MUD],
	Constants.Element.CRYSTAL: tower_prices_base[Constants.Element.CRYSTAL],
	Constants.Element.SPIRIT: tower_prices_base[Constants.Element.SPIRIT],
	Constants.Element.SUN: tower_prices_base[Constants.Element.SUN],
	Constants.Element.CURSE: tower_prices_base[Constants.Element.CURSE],
	Constants.Element.VOID: tower_prices_base[Constants.Element.VOID],
	Constants.Element.ARCANE: tower_prices_base[Constants.Element.ARCANE],
}

var tower_price_modifier: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 0.0,
	Constants.Element.WIND: 0.0,
	Constants.Element.WATER: 0.0,
	Constants.Element.EARTH: 0.0,
	Constants.Element.LIGHT: 0.0,
	Constants.Element.DARK: 0.0,
	Constants.Element.ARCANE: 0.0,
}

var tower_upgrade_price_modifier: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE:  1.0,
	Constants.Element.WIND:  1.0,
	Constants.Element.WATER: 1.0,
	Constants.Element.EARTH: 1.0,
	Constants.Element.LIGHT: 1.0,
	Constants.Element.DARK:  1.0,
	Constants.Element.LAVA: 1.0,
	Constants.Element.PLASMA: 1.0,
	Constants.Element.STORM: 1.0,
	Constants.Element.LIGHTNING: 1.0,
	Constants.Element.ICE: 1.0,
	Constants.Element.FLOOD: 1.0,
	Constants.Element.MUD: 1.0,
	Constants.Element.CRYSTAL: 1.0,
	Constants.Element.SPIRIT: 1.0,
	Constants.Element.SUN: 1.0,
	Constants.Element.CURSE: 1.0,
	Constants.Element.VOID: 1.0,
	Constants.Element.ARCANE: 1.0,
}

var tower_icon_atl: Texture2D = load("res://assets/art/sprites/ui/atl_ui_tower_icon.png")
var tower_icon_atl_locked: Texture2D = load("res://assets/art/sprites/ui/atl_ui_tower_icon_locked.png")
var tower_icon_atl_regions: Dictionary[Constants.Element, Rect2] = {
	Constants.Element.FIRE:  Rect2(0,0,32,32),
	Constants.Element.WIND:  Rect2(96,0,32,32),
	Constants.Element.WATER: Rect2(0,32,32,32),
	Constants.Element.EARTH: Rect2(96,32,32,32),
	Constants.Element.LIGHT: Rect2(0,64,32,32),
	Constants.Element.DARK:  Rect2(96,64,32,32),
	Constants.Element.LAVA: Rect2(32,0,32,32),
	Constants.Element.PLASMA: Rect2(64,0,32,32),
	Constants.Element.STORM: Rect2(128,0,32,32),
	Constants.Element.LIGHTNING: Rect2(160,0,32,32),
	Constants.Element.ICE: Rect2(32,32,32,32),
	Constants.Element.FLOOD: Rect2(64,32,32,32),
	Constants.Element.MUD: Rect2(160,32,32,32),
	Constants.Element.CRYSTAL: Rect2(128,32,32,32),
	Constants.Element.SPIRIT: Rect2(32,64,32,32),
	Constants.Element.SUN: Rect2(64,64,32,32),
	Constants.Element.CURSE: Rect2(160,64,32,32),
	Constants.Element.VOID: Rect2(128,64,32,32),
	Constants.Element.ARCANE: Rect2(0,96,32,32),
}

# TODO: I think this is obsolete
var ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
 	Constants.Element.FIRE: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.WIND: load("res://assets/art/sprites/ui/spr_ui_tower_wind.png"),
	Constants.Element.WATER: load("res://assets/art/sprites/ui/spr_ui_tower_water_fish.png"),
	Constants.Element.EARTH: load("res://assets/art/sprites/ui/spr_ui_tower_earth.png"),
	Constants.Element.LIGHT: load("res://assets/art/sprites/ui/spr_ui_tower_light.png"),
	Constants.Element.DARK: load("res://assets/art/sprites/ui/spr_ui_tower_dark.png"),
	Constants.Element.LAVA: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.PLASMA: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.STORM: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.LIGHTNING: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.ICE: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.FLOOD: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.MUD: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.CRYSTAL: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.SPIRIT: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.SUN: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.CURSE: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.VOID: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
	Constants.Element.ARCANE: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
}

var locked_ui_tower_sprites: Dictionary[Constants.Element, Texture] = {
	Constants.Element.FIRE: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.WIND: load("res://assets/art/sprites/ui/spr_ui_tower_wind_locked.png"),
	Constants.Element.WATER: load("res://assets/art/sprites/ui/spr_ui_tower_water_fish_locked.png"),
	Constants.Element.EARTH: load("res://assets/art/sprites/ui/spr_ui_tower_earth_locked.png"),
	Constants.Element.LIGHT: load("res://assets/art/sprites/ui/spr_ui_tower_light_locked.png"),
	Constants.Element.DARK: load("res://assets/art/sprites/ui/spr_ui_tower_dark_locked.png"),
	Constants.Element.LAVA: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.PLASMA: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.STORM: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.LIGHTNING: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.ICE: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.FLOOD: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.MUD: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.CRYSTAL: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.SPIRIT: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.SUN: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.CURSE: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.VOID: load("res://assets/art/sprites/ui/spr_ui_tower_fire_locked.png"),
	Constants.Element.ARCANE: load("res://assets/art/sprites/ui/spr_ui_tower_fire.png"),
}

var tower_element_damage_perk_modifier: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 1.0,
	Constants.Element.WIND: 1.0,
	Constants.Element.WATER: 1.0,
	Constants.Element.EARTH: 1.0,
	Constants.Element.LIGHT: 1.0,
	Constants.Element.DARK: 1.0,
	Constants.Element.ARCANE: 1.0,
}

var debuff_perk_modifier: Dictionary[Debuff.Type, float] = {
	Debuff.Type.BURN: 0.0,
	Debuff.Type.STUN: 0.0,
	Debuff.Type.SLOW: 0.0,
	Debuff.Type.FREEZE: 0.0,
	Debuff.Type.WEAKEN: 0.0,
	Debuff.Type.KNOCKBACK: 0.0,
}

var buff_perk_modifier: Dictionary[Buff.Type, float] = {
	Buff.Type.RANGE: 1.0,
	Buff.Type.SPEED: 1.0,
	Buff.Type.DAMAGE: 1.0,
}

var bullet_modifier_perk_modifier: Dictionary[BulletModifierData.Type, float] = {
	BulletModifierData.Type.COIN: 0.0,
	BulletModifierData.Type.NONE: 0.0
}

var tower_max: int: # Set manually by Main from active_level
	set(value):
		tower_max = value
		tower_max_updated.emit(tower_max) 

var reflect_chance: float = 0.0

## Additive to the tower mana drop chance in coin_drop_manager.gd
var tower_mana_drop_perk_bonus: float = 0.0

signal tower_max_updated
signal tower_debuff_perk_modifier_data_updated
signal tower_buff_perk_modifier_data_updated
signal tower_prices_updated
signal tower_upgrade_price_modifier_updated

func _ready():
	WaveManager.wave_completed.connect(TowerGlobalData.checkpoint)
	WaveManager.wave_failed.connect(TowerGlobalData.revert_to_checkpoint)

func reset() -> void:
	for _element in Constants.Element.values():
		tower_evolution_status[_element] = true

	for _element in Constants.Element.values():
		checkpointed_tower_evolution_status[_element] = true

func checkpoint() -> void:
	copy_dict_data(tower_evolution_status, checkpointed_tower_evolution_status)

func revert_to_checkpoint() -> void:
	copy_dict_data(checkpointed_tower_evolution_status, tower_evolution_status)

func copy_dict_data(source: Dictionary, copy_to: Dictionary) -> void:
	for item in source:
		copy_to[item] = source[item]

func on_modify_stat_requested(perk_data: PerkDataTower) -> void:
	match perk_data.stat:
		PerkDataTower.TowerStat.PLACEMENT_COST:

			tower_price_modifier[perk_data.element] += perk_data.base_value

			for element: Constants.Element in tower_prices.keys():
				tower_prices[element] = int(tower_prices[element] - (roundf(tower_prices_base[element] * tower_price_modifier[Constants.get_base_element(element)])))
			tower_prices_updated.emit()

			# var new_price: int =  int(tower_prices[perk_data.element] - (roundf(tower_prices_base[perk_data.element] * perk_data.base_value)))
			# tower_prices[perk_data.element] = max(new_price, TOWER_MIN_PLACEMENT_PRICE)
			# tower_prices_updated.emit()
		PerkDataTower.TowerStat.UPGRADE_COST:
			var new_upgrade_price_modifier: float = tower_upgrade_price_modifier[perk_data.element] + perk_data.base_value
			tower_upgrade_price_modifier[perk_data.element] = max(new_upgrade_price_modifier, TOWER_MIN_UPGRADE_PRICE_MODIFIER)
			tower_upgrade_price_modifier_updated.emit()
		PerkDataTower.TowerStat.DEBUFF_MODIFIER: 
			debuff_perk_modifier[perk_data.debuff] += perk_data.base_value
			tower_debuff_perk_modifier_data_updated.emit()
		PerkDataTower.TowerStat.BUFF_MODIFIER:
			buff_perk_modifier[perk_data.buff] += perk_data.base_value
			tower_buff_perk_modifier_data_updated.emit()
		PerkDataTower.TowerStat.TOWER_CAP: 
			tower_max += perk_data.base_value
		PerkDataTower.TowerStat.ALL_REFLECT_CHANCE:
			reflect_chance += perk_data.base_value
		PerkDataTower.TowerStat.ALL_ELEMENT_DAMAGE:
			tower_element_damage_perk_modifier[perk_data.element] += perk_data.base_value
		PerkDataTower.TowerStat.TOWER_MANA_DROP:
			tower_mana_drop_perk_bonus += perk_data.base_value
		PerkDataTower.TowerStat.BULLET_MODIFIER:
			bullet_modifier_perk_modifier[perk_data.bullet_modifier] += perk_data.base_value
		PerkDataTower.TowerStat.NONE: push_error("TowerPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")














# True = tower evolution is unused
var tower_evolution_status: Dictionary[Constants.Element, bool] = {
	Constants.Element.FIRE:  true, # Not used, set here to make reset simpler
	Constants.Element.WIND:  true, # Not used, set here to make reset simpler
	Constants.Element.WATER: true, # Not used, set here to make reset simpler
	Constants.Element.EARTH: true, # Not used, set here to make reset simpler
	Constants.Element.LIGHT: true, # Not used, set here to make reset simpler
	Constants.Element.DARK:  true, # Not used, set here to make reset simpler
	Constants.Element.LAVA: true,
	Constants.Element.PLASMA: true,
	Constants.Element.STORM: true,
	Constants.Element.LIGHTNING: true,
	Constants.Element.ICE: true,
	Constants.Element.FLOOD: true,
	Constants.Element.MUD: true,
	Constants.Element.CRYSTAL: true,
	Constants.Element.SPIRIT: true,
	Constants.Element.SUN: true,
	Constants.Element.CURSE: true,
	Constants.Element.VOID: true,
}

var checkpointed_tower_evolution_status: Dictionary[Constants.Element, bool] = {
	Constants.Element.FIRE:  true, # Not used, set here to make reset simpler
	Constants.Element.WIND:  true, # Not used, set here to make reset simpler
	Constants.Element.WATER: true, # Not used, set here to make reset simpler
	Constants.Element.EARTH: true, # Not used, set here to make reset simpler
	Constants.Element.LIGHT: true, # Not used, set here to make reset simpler
	Constants.Element.DARK:  true, # Not used, set here to make reset simpler
	Constants.Element.LAVA: true,
	Constants.Element.PLASMA: true,
	Constants.Element.STORM: true,
	Constants.Element.LIGHTNING: true,
	Constants.Element.ICE: true,
	Constants.Element.FLOOD: true,
	Constants.Element.MUD: true,
	Constants.Element.CRYSTAL: true,
	Constants.Element.SPIRIT: true,
	Constants.Element.SUN: true,
	Constants.Element.CURSE: true,
	Constants.Element.VOID: true,
}
