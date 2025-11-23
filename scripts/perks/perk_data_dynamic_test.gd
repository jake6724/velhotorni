@tool 

class_name PerkDataDynamicTest
extends Resource

enum Type {PlayerStat, TowerStat, BaseStat, SpellStat, TowerDebuffStat, SpellDebuffStat, }
enum Trigger {OneShot, OnWaveComplete, OnPlayerDamage}

@export_enum("PlayerStat", "TowerStat", "BaseStat", "SpellStat", "TowerDebuffStat", "SpellDebuffStat") var perk_type: String = "PlayerStat":
	set(value):
		perk_type = value
		notify_property_list_changed()

var always_show_property_names: Array[String] = ["perk_type"]
var category_names: Array[String] = ["Player Stat Perk", "Tower Stat Perk"]

# Do not include this in player_stat_property_names or hide it
# Will hide automatically when all children are hidden
# @export_category("Player Stat Perk")
var player_stat_property_names: Array[String] = ["player_stat", "player_stat_increase_percentage"]
@export_enum("MaxHealth", "MoveSpeed", "SpecialCooldown") var player_stat: String = "MaxHealth"
@export var player_stat_increase_percentage: float = .5

# @export_category("Tower Stat Perk")
var tower_stat_property_names: Array[String] = ["tower_stat", "tower_stat_modify_percentage"]
@export_enum("Cost") var tower_stat: String = "Cost"
@export var tower_stat_modify_percentage: float = -.1

func _validate_property(property: Dictionary):
	print("Perk Type: ", perk_type)
	match perk_type:
		"PlayerStat":
			if property.name in player_stat_property_names or property.name in always_show_property_names:
				property.usage = PROPERTY_USAGE_EDITOR
			else:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"TowerStat":
			if property.name in tower_stat_property_names or property.name in always_show_property_names:
				property.usage = PROPERTY_USAGE_EDITOR
			else:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		_: 
			if property.name not in always_show_property_names and property.name not in category_names:
				property.usage = PROPERTY_USAGE_NO_EDITOR
			else:
				if property.name in always_show_property_names:
					property.usage = PROPERTY_USAGE_EDITOR
				else:
					property.usage = PROPERTY_USAGE_CATEGORY
