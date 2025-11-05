class_name PlayerPerkManager
extends Node

"""
This node directly manages and makes changes to PlayerCharacter and its child nodes based on signals emitted from
PerkPlayer objects. 
"""

@onready var player: PlayerCharacter = get_owner()

var timed_modify_stat_stack_max: Dictionary[PerkDataPlayer.PlayerStat, int] = {
	PerkDataPlayer.PlayerStat.HEALTH: 5,
	PerkDataPlayer.PlayerStat.MAX_HEALTH: 5,
	PerkDataPlayer.PlayerStat.MOVE_SPEED: 5,
	PerkDataPlayer.PlayerStat.SPECIAL_COOLDOWN: 5,
}

var timed_modify_stat_stack_count: Dictionary[PerkDataPlayer.PlayerStat, int] = {
	PerkDataPlayer.PlayerStat.HEALTH: 0,
	PerkDataPlayer.PlayerStat.MAX_HEALTH: 0,
	PerkDataPlayer.PlayerStat.MOVE_SPEED: 0,
	PerkDataPlayer.PlayerStat.SPECIAL_COOLDOWN: 0,
}

func on_modify_stat_requested(stat_to_modify: PerkDataPlayer.PlayerStat, value: float) -> float:
	var modified_value: float
	match stat_to_modify:
		PerkDataPlayer.PlayerStat.HEALTH: 
			modified_value = value
			player.player_statsa.health += value
		PerkDataPlayer.PlayerStat.MAX_HEALTH: 
			modified_value = value
			player.player_stats.max_health += value
		PerkDataPlayer.PlayerStat.MOVE_SPEED: 
			modified_value = (player.player_stats.move_speed * value)
			player.player_stats.move_speed += (player.player_stats.move_speed * value)
		PerkDataPlayer.PlayerStat.SPECIAL_COOLDOWN: 
			modified_value = (player.player_special.charge_cooldown_duration * value)
			player.player_special.charge_cooldown_duration -= (player.player_special.charge_cooldown_duration * value)
		PerkDataPlayer.PlayerStat.REFLECT_CHANCE:
			modified_value = value
			player.player_stats.chance_to_reflect += value
		PerkDataPlayer.PlayerStat.SPECIAL_MAX_CHARGE:
			modified_value = value
			player.player_special.charge_max += value
		PerkDataPlayer.PlayerStat.IFRAME_DURATION:
			modified_value = player.player_stats.hurtbox_iframe_duration * value
			player.player_stats.hurtbox_iframe_duration *= value

		PerkDataPlayer.PlayerStat.NONE: push_error("PlayerPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")
	return modified_value

func on_timed_modify_stat_requested(stat_to_modify: PerkDataPlayer.PlayerStat, value: float, duration: float) -> void:
	if timed_modify_stat_stack_count[stat_to_modify] < timed_modify_stat_stack_max[stat_to_modify]:

		var modified_value: float = on_modify_stat_requested(stat_to_modify, value)

		var timer: Timer = Timer.new()
		timer.timeout.connect(on_timed_modify_stat_expired.bind(stat_to_modify, modified_value))
		timer.start(duration)

		timed_modify_stat_stack_count[stat_to_modify] += 1

## Remove the effect applied by `on_timed_modify_stat_requested` on timer timeout. `value` has been pre-calculated
## to be the amount the stat was originally changed by. This avoids the error of adding a percentage back to a value
## that may have changed since the original effect was applied, which would make the percentage inaccurate
func on_timed_modify_stat_expired(stat_to_modify: PerkDataPlayer.PlayerStat, value: float) -> void:
	match stat_to_modify:
		PerkDataPlayer.PlayerStat.HEALTH: player.player_statsa.health -= value
		PerkDataPlayer.PlayerStat.MAX_HEALTH: player.player_stats.max_health -= value
		PerkDataPlayer.PlayerStat.MOVE_SPEED: player.player_stats.move_speed -= value
		PerkDataPlayer.PlayerStat.SPECIAL_COOLDOWN: player.player_special.charge_cooldown_duration += value
		PerkDataPlayer.PlayerStat.REFLECT_CHANCE: player.player_stats.chance_to_reflect -= value
		PerkDataPlayer.PlayerStat.NONE: push_error("PlayerPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")

	timed_modify_stat_stack_count[stat_to_modify] -= 1