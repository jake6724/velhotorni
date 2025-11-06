class_name PerkTower
extends Perk

signal modify_stat_requested

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataTower.TowerPerkAction.TowerStat: modify_stat_requested.emit(data)

# func modify_player_stat(stat_to_modify: PerkDataPlayer.PlayerStat, value: float, element: Constants.Element) -> void:
# 	modify_stat_requested.emit(stat_to_modify, value, element)