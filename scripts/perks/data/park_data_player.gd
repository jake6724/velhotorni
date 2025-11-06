class_name PerkDataPlayer
extends PerkData

enum PlayerPerkAction {MODIFY_PLAYER_STAT, MODIFY_TIMED_PLAYER_STAT}
enum PlayerStat {NONE, HEALTH, MAX_HEALTH, MOVE_SPEED, SPECIAL_COOLDOWN, REFLECT_CHANCE, 
IFRAME_DURATION, SPECIAL_MAX_CHARGE}

@export var trigger: Trigger = Trigger.OneShot
@export var action: PlayerPerkAction = PlayerPerkAction.MODIFY_PLAYER_STAT
@export var stat: PlayerStat = PlayerStat.NONE
## This value is ONLY USED if `action` is `TimedPlayerStat`
@export var duration: float = -1
## This value is ONLY USED if `trigger` is `OnPlayerSpellDamageDealt`
@export var required_spell_damage: float = INF