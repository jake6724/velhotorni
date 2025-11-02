class_name PerkDataPlayer
extends PerkData

enum PlayerPerkAction {PlayerStat,}
enum PlayerStat {NONE, HEALTH, MAX_HEALTH, MOVE_SPEED, SPECIAL_COOLDOWN}

@export var trigger: Trigger = Trigger.OneShot
@export var action: PlayerPerkAction = PlayerPerkAction.PlayerStat
@export var stat: PlayerStat = PlayerStat.NONE
