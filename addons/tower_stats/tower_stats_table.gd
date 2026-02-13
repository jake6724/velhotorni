@tool
class_name TowerStatsTable
extends Control

# @onready var tower_name_label: Label = %TowerName

func set_tower_name_label(new_name: String) -> void:
	%TowerName.text = new_name

func calc_stats() -> void:
	pass
