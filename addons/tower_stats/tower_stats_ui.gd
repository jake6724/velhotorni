@tool
class_name TowerStatsUI
extends VBoxContainer

func _ready():
	%FireTowerStatsTable.set_tower_name_label("Fire Tower")
	%NatureTowerStatsTable.set_tower_name_label("Nature Tower")
	%WaterTowerStatsTable.set_tower_name_label("Water Tower")