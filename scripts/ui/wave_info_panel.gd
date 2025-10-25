class_name WaveInfoPanel
extends PanelContainer 

@export var path: int
@onready var grid_container: GridContainer = $GridContainer

var wave_previews: Array[Dictionary] = []
var unit_wave_info_scene: PackedScene = preload("res://scenes/ui/UnitWaveInfo.tscn")

func _ready():
	z_index = Constants.z_index_map["top"]

func get_path_enemy_info(active_level: LevelEnvironment) -> void:
	for i in range(active_level.waves.size()): 
		var new_dict: Dictionary[EnemyData, int] = {} 
		wave_previews.append(new_dict)
		for j in range(active_level.waves[i].data.size()):
			var spawn: Spawn = active_level.waves[i].data[j]
			if spawn.path_index == path:
				if spawn.enemy_data in wave_previews[i]:
					wave_previews[i][spawn.enemy_data] += 1
				else:
					wave_previews[i][spawn.enemy_data] = 1

	print(wave_previews)
				
func populate_unit_wave_info(wave_index: int) -> void:
	if wave_previews[wave_index].keys():
		# Remove existing children to make way for new wave
		for child in grid_container.get_children():
			child.queue_free()

		for enemy_data: EnemyData in wave_previews[wave_index].keys():
			var new_unit_wave_info: UnitWaveInfo = unit_wave_info_scene.instantiate()
			grid_container.add_child(new_unit_wave_info)
			new_unit_wave_info.initialize(enemy_data.icon, wave_previews[wave_index][enemy_data]) # enemy_data_icon, count

		if wave_previews[wave_index].keys().size() == 0:
			hide()
		else:
			show()
	else:
		hide()

# func get_wave_preview_data(wave_index: int) -> Dictionary[Constants.Element, float]:
# 	return wave_previews[wave_index]

# func get_all_wave_preview_data(active_level: LevelEnvironment):
# 	for wave: Wave in active_level.waves:
# 		var fire_count: float = 0.0
# 		var wind_count: float = 0.0
# 		var water_count: float = 0.0
# 		var earth_count: float = 0.0
# 		var light_count: float = 0.0
# 		var dark_count: float = 0.0
# 		var total_count: float = 0.0

# 		for spawn: Spawn in wave.data:
# 			total_count += 1
# 			match spawn.enemy_data.element:
# 				Constants.Element.FIRE: fire_count += 1
# 				Constants.Element.WIND: wind_count += 1
# 				Constants.Element.WATER: water_count += 1
# 				Constants.Element.EARTH: earth_count += 1
# 				Constants.Element.LIGHT: light_count += 1
# 				Constants.Element.DARK: dark_count += 1

# 		var wave_results: Dictionary[Constants.Element, float] = {
# 			Constants.Element.FIRE: ((fire_count / total_count) * 100),
# 			Constants.Element.WIND: ((wind_count / total_count) * 100),
# 			Constants.Element.WATER: ((water_count / total_count) * 100),
# 			Constants.Element.EARTH: ((earth_count / total_count) * 100),
# 			Constants.Element.LIGHT: ((light_count / total_count) * 100),
# 			Constants.Element.DARK: ((dark_count / total_count) * 100),
# 		}
# 		# print(wave_results)
# 		wave_previews.append(wave_results)

# func set_preview_labels(wave_index: int) -> void:
# 	var data: Dictionary = get_wave_preview_data(wave_index)

	# fire_label.text = str(int(snappedf(data[Constants.Element.FIRE],1)))
	# wind_label.text = str(int(snappedf(data[Constants.Element.WIND],1)))
	# water_label.text = str(int(snappedf(data[Constants.Element.WATER],1)))
	# earth_label.text = str(int(snappedf(data[Constants.Element.EARTH],1)))
	# light_label.text = str(int(snappedf(data[Constants.Element.LIGHT],1)))
	# dark_label.text = str(int(snappedf(data[Constants.Element.DARK],1)))
