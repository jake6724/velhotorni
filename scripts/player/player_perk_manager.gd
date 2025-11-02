class_name PlayerPerkManager
extends Node

"""
This node directly manages and makes changes to PlayerCharacter and its child nodes based on signals emitted from
PerkPlayer objects. 
"""

@onready var player: PlayerCharacter = get_owner()

func on_modify_stat_requested(stat_to_modify: PerkDataPlayer.PlayerStat, value: float) -> void:
	match stat_to_modify:
		PerkDataPlayer.PlayerStat.HEALTH: player.player_stats.health += value
		PerkDataPlayer.PlayerStat.MAX_HEALTH: player.player_stats.max_health += value
		PerkDataPlayer.PlayerStat.MOVE_SPEED: player.player_stats.move_speed += (player.player_stats.move_speed * value)
		PerkDataPlayer.PlayerStat.MOVE_SPEED: player.player_special.charge_cooldown_duration -= (player.player_special.charge_cooldown_duration * value)
		PerkDataPlayer.PlayerStat.NONE: push_error("PlayerPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")