class_name PerkPlayer
extends Perk

signal modify_stat_requested
signal timed_modify_stat_requested

func perk_action() -> void: 
	match data.action: # could use a func_ref instead
		PerkDataPlayer.PlayerPerkAction.PlayerStat: modify_player_stat(data.stat, data.base_value)
		PerkDataPlayer.PlayerPerkAction.TimedPlayerStat: timed_modify_player_stat(data.stat, data.base_value, data.duration)

func modify_player_stat(stat_to_modify: PerkDataPlayer.PlayerStat, value: float) -> void:
	modify_stat_requested.emit(stat_to_modify, value)

func timed_modify_player_stat(stat_to_modify: PerkDataPlayer.PlayerStat, value: float, duration: float) -> void:
	timed_modify_stat_requested.emit(stat_to_modify, value, duration)