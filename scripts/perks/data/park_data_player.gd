class_name PerkDataPlayer
extends PerkData

enum PlayerPerkAction {PlayerStat, TimedPlayerStat}
enum PlayerStat {NONE, HEALTH, MAX_HEALTH, MOVE_SPEED, SPECIAL_COOLDOWN, REFLECT_CHANCE, IFRAME_DURATION}

@export var trigger: Trigger = Trigger.OneShot
@export var action: PlayerPerkAction = PlayerPerkAction.PlayerStat
@export var stat: PlayerStat = PlayerStat.NONE
## This value is ONLY USED if `action` is TimedPlayerStat
@export var duration: float = -1