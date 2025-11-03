class_name PerkPlayer
extends Perk

# This has been duplicated before setting for the perk;
# dhanges can be made to data without affecting other instances
var data: PerkData

signal modify_stat_requested

func _ready():
	set_rarity_value()

func perk_action() -> void:
	match data.action:
		PerkDataPlayer.PlayerPerkAction.PlayerStat: modify_player_stat(data.stat, data.base_value)

func modify_player_stat(stat_to_modify: PerkDataPlayer.PlayerStat, value: float) -> void:
	modify_stat_requested.emit(stat_to_modify, value)

func set_rarity_value() -> void:
	match data.rarity:
		PerkData.Rarity.One: pass
		PerkData.Rarity.Two: data.base_value *= 2
		PerkData.Rarity.Three: data.base_value *= 4