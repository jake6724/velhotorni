class_name PerkDataTower
extends PerkData

enum TowerPerkAction {TowerStat}
enum TowerStat {NONE, ALL_COSTS, PLACEMENT_COST, UPGRADE_COST, TOWER_CAP, DEBUFF_MODIFIER, BUFF_MODIFIER, 
                ALL_REFLECT_CHANCE, ALL_ELEMENT_DAMAGE, TOWER_MANA_DROP, BULLET_MODIFIER}

@export var trigger: Trigger = Trigger.OneShot
@export var action: TowerPerkAction = TowerPerkAction.TowerStat
@export var stat: TowerStat = TowerStat.NONE
## This variable is ONLY USED if the perk uses elements. Certain perk actions such as TOWER CAP will ignore this.
@export var element: Constants.Element = Constants.Element.NONE
## This variable is ONLY USED if the TowerStat is DEBUFF_MODIFIER
@export var debuff: Debuff.Type = Debuff.Type.NONE
## This variable is ONLY USED if the TowerStat is BUFF_MODIFIER
@export var buff: Buff.Type = Buff.Type.NONE
@export var bullet_modifier: BulletModifierData.Type = BulletModifierData.Type.NONE