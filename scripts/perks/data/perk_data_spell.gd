class_name PerkDataSpell
extends PerkData

enum SpellPerkAction {MODIFY_SPELL_STAT}
enum SpellStat {NONE, MANA_MAX, MANA_COST}

@export var trigger: Trigger = Trigger.OneShot
@export var action: SpellPerkAction = SpellPerkAction.MODIFY_SPELL_STAT
@export var stat: SpellStat = SpellStat.NONE
@export var element: Constants.Element = Constants.Element.NONE