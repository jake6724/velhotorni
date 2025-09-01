class_name TowerUpgradeMenuUIText
extends Object

var damage_button_hovered: String = "Damage applied to an enemy on-hit."
var speed_button_hovered: String = "The number of shots fired each second."
var range_button_hovered: String = "The radius of the tower's max range in pixels."

var special_button_hovered: String = "Special placeholder text"
var special_debuff_burn: String = "Upgrades burn damage. \n Does not stack. \n Burning enemies take damage every .5 seconds. Lasts for 6 seconds."
var special_debuff_slow: String = "Upgrades slow duration. \n Does not stack. \n stronger slows take priority over weaker ones."
var special_debuff_freeze: String = "Upgrades freeze duration. \n Frozen enemies build resistance to freezes with each application."
var special_debuff_stun: String = "Upgrades stun duration. \n Stunned enemies build resistance to stuns with each application."
var special_debuff_knockback: String = "Upgrades knockback distance. \n Affected enemies build resistance to knockbacks with each application."
var special_debuff_weaken: String = "Upgrades weaken duration. \n Does not stack. \n Weakened enemies take increased damage \n from all sources."
var special_debuff_button_hovered_options: Dictionary[Debuff.Type, String] = {
	Debuff.Type.BURN: special_debuff_burn,
	Debuff.Type.SLOW: special_debuff_slow,
	Debuff.Type.FREEZE: special_debuff_freeze,
	Debuff.Type.STUN: special_debuff_stun,
	Debuff.Type.KNOCKBACK: special_debuff_knockback,
	Debuff.Type.WEAKEN: special_debuff_weaken,}

var special_buff_range: String = "Increases the range of allied towers. Does not affect itself nor other light towers."
var special_buff_damage: String = "Increases the damage of allied towers. Does not affect itself nor other light towers."
var special_buff_speed: String = "Increases the speed of allied towers. Does not affect itself nor other light towers."
var special_buff_button_hovered_options: Dictionary[Buff.Type, String] = {
	Buff.Type.DAMAGE: special_buff_damage,
	Buff.Type.RANGE: special_buff_range,
	Buff.Type.SPEED: special_buff_speed,
}

var special_bullet_modifier_coin = "Increase coin drops or something"
var special_bullet_modifier_button_hovered_options: Dictionary[BulletModifierData.Type, String] = {
	BulletModifierData.Type.COIN: special_bullet_modifier_coin,
}

var targeting_priority_first: String = "Target the enemy farthest along on the path."
var targeting_priority_last: String = "Target the enemy closest to the start of the path."
var targeting_priority_highest: String = "Target the enemy with the highest current health."
var targeting_priority_lowest: String = "Target the enemy with the lowest current health."
var targeting_hovered_options: Dictionary[Tower.TargetPriority, String] = {
	Tower.TargetPriority.FIRST: targeting_priority_first,
	Tower.TargetPriority.LAST: targeting_priority_last,
	Tower.TargetPriority.HIGHEST: targeting_priority_highest,
	Tower.TargetPriority.LOWEST: targeting_priority_lowest,
}

var requirements_hovered: String = "Cost to upgrade 1 stat for this tower."
var level_hovered: String = "The current and next level of this tower."
var level_hovered_maxed: String = "Max level reached!"
