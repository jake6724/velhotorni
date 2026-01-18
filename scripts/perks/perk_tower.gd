class_name PerkTower
extends Perk

signal modify_stat_requested

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataTower.TowerPerkAction.TowerStat: modify_stat_requested.emit(data)