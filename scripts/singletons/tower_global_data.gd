extends Node

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

# func _ready():
# 	WaveManager.wave_failed.connect(reset)
# 	WaveManager.wave_completed.connect(reset)



func reset() -> void:
	for _element in Constants.Element.values():
		tower_evolution_status[_element] = true