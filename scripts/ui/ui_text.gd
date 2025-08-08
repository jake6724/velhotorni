class_name UIText
extends Object

var damage_button_hovered: String = "Damage applied to an enemy on-hit"
var speed_button_hovered: String = "Delay between firing a new shot"
var range_button_hovered: String = "The max range of this tower"


var special_button_hovered: String = "Special placeholder text! This will need to be different for each debuff"
var special_debuff_burn: String = "Apply burn to enemies"
var special_debuff_slow: String = "Apply slow to enemies"
var special_debuff_freeze: String = "Apply freeze to enemies"
var special_debuff_stun: String = "Apply stun to enemies"
var special_debuff_knockback: String = "Apply knockback to enemies"
var special_debuff_weaken: String = "Apply weaken to enemies"

var special_debuff_button_hovered_options: Dictionary[Debuff.Type, String] = {
	Debuff.Type.BURN: special_debuff_burn,
	Debuff.Type.SLOW: special_debuff_slow,
	Debuff.Type.FREEZE: special_debuff_freeze,
	Debuff.Type.STUN: special_debuff_stun,
	Debuff.Type.KNOCKBACK: special_debuff_knockback,
	Debuff.Type.WEAKEN: special_debuff_weaken,}

var special_buff_range: String = "Increases the range of allied towers"
var special_buff_button_hovered_options: Dictionary[Buff.Type, String] = {
	Buff.Type.RANGE: special_buff_range,
}

var targeting_hovered_options: Dictionary[Tower.TargetPriority, String] = {
	Tower.TargetPriority.FIRST: "Target the enemy farthest along on the path",
	Tower.TargetPriority.LAST: "Target the enemy closest to the spawn point",
	Tower.TargetPriority.HIGHEST: "Target the enemy with the highest current health",
	Tower.TargetPriority.LOWEST: "Target the enemy with the lowest current health"
}
var targeting_hovered: String = ""