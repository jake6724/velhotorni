class_name PlayerPerkManager
extends Node

## TODO: If I could get everything in playerstats i could just pass a ref to that...? 

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

## Modify a player stat based on perk data. All stat changes are either additive, or work off of a base value
func on_modify_stat_requested(data: PerkData) -> float:
	add_perk_mini_icon(data)
	var modified_value: float
	match data.stat:
		PerkDataPlayer.PlayerStat.HEALTH: 
			modified_value = data.base_value
			player.player_stats.health += modified_value
			player.player_hud.on_health_updated(player.player_stats.health)
		PerkDataPlayer.PlayerStat.MAX_HEALTH: 
			modified_value = data.base_value
			player.player_stats.max_health += modified_value
			player.player_stats.health += modified_value
		PerkDataPlayer.PlayerStat.MOVE_SPEED: 
			modified_value = (player.player_stats.base_move_speed * data.base_value)
			player.player_stats.move_speed += modified_value
		PerkDataPlayer.PlayerStat.SPECIAL_COOLDOWN: 
			modified_value = (player.player_stats.special_charge_cooldown_duration_base * data.base_value)
			player.player_stats.special_charge_cooldown_duration -= modified_value
		PerkDataPlayer.PlayerStat.REFLECT_CHANCE:
			modified_value = data.base_value
			player.player_stats.reflect_chance += modified_value
		PerkDataPlayer.PlayerStat.SPECIAL_MAX_CHARGE:
			modified_value = data.base_value
			player.player_stats.special_charges_max += modified_value
			player.on_special_charge_sprite_update_requested(player.player_stats.special_charges_max)
		PerkDataPlayer.PlayerStat.IFRAME_DURATION:
			modified_value = player.player_stats.hurtbox_iframe_duration_base * data.base_value
			player.player_stats.hurtbox_iframe_duration = modified_value

		PerkDataPlayer.PlayerStat.NONE: push_error("PlayerPerkManager.on_modify_stat_requested() called with stat_to_modify = NONE")
	return modified_value

func on_timed_modify_stat_requested(data: PerkData) -> void:
	if timed_modify_stat_stack_count[data.stat] < timed_modify_stat_stack_max[data.stat]:
		var modified_value: float = on_modify_stat_requested(data)
		var timer: Timer = Timer.new()
		timer.one_shot = true
		timer.autostart = false
		timer.timeout.connect(on_timed_modify_stat_expired.bind(data.stat, modified_value))
		add_child(timer)
		timer.start(data.duration)

		timed_modify_stat_stack_count[data.stat] += 1

func on_player_aoe_requested(perk_data: PerkDataPlayer) -> void:
	player.player_aoe.attack(perk_data.base_value, perk_data.debuffs, perk_data.element) 

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

func add_perk_mini_icon(data: PerkData) -> void:
	var new_icon: TextureRect = TextureRect.new()
	new_icon.texture = data.perk_mini_icon
	player.player_hud.perk_mini_icons.add_child(new_icon)
