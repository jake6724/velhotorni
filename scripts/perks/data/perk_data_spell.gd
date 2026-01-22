class_name PerkDataSpell
extends PerkData

enum SpellPerkAction {MODIFY_SPELL_STAT}
enum SpellStat {NONE, MANA_MAX, MANA_COST, ELEMENT_DAMAGE, COOLDOWN, FREE_CAST, EXECUTE, DOUBLE_SPELL_MANA_CHANCE, PERK_DEBUFF_CHANCE}

@export var trigger: Trigger = Trigger.OneShot
@export var action: SpellPerkAction = SpellPerkAction.MODIFY_SPELL_STAT
@export var stat: SpellStat = SpellStat.NONE
@export var element: Constants.Element = Constants.Element.NONE
@export var debuff_type: Debuff.Type = Debuff.Type.NONE
