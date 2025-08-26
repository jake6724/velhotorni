extends Node

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