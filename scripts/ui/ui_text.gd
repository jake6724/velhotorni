class_name UIText
extends Object

var damage_button_hovered: String = "Damage applied to an enemy on-hit"
var speed_button_hovered: String = "Delay between firing a new shot"
var range_button_hovered: String = "The max range of this tower"
var special_button_hovered: String = "Special placeholder text! This will need to be different for each debuff"

var targeting_hovered_options: Dictionary[Tower.TargetPriority, String] = {
	Tower.TargetPriority.FIRST: "Target the enemy farthest along on the path",
	Tower.TargetPriority.LAST: "Target the enemy closest to the spawn point",
	Tower.TargetPriority.HIGHEST: "Target the enemy with the highest current health",
	Tower.TargetPriority.LOWEST: "Target the enemy with the lowest current health"
}
var targeting_hovered: String = ""