class_name PerkDataBase
extends PerkData

enum BasePerkAction {BaseStat}
enum BaseStat {NONE, HEALTH, MAX_HEALTH}

@export var trigger: Trigger = Trigger.OneShot
@export var action: BasePerkAction = BasePerkAction.BaseStat
@export var stat: BaseStat = BaseStat.NONE
## This value is ONLY USED if `trigger` is `OnPlayerSpellDamageDealt`
@export var required_spell_damage: float = -1


## This value is ONLY USED if `action` is `TimedPlayerStat`
# @export var duration: float = -1
