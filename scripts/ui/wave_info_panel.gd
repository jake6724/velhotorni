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
