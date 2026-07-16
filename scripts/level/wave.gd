class_name Wave
extends Resource

@export var data: Array[Spawn]

@export var path_data_list: Array[PathData]
@export var reward: float = 1.0
@export var token_reward: int = 0

func configure_data() -> void:
	for path_data: PathData in path_data_list:
		for spawn: Spawn in path_data.spawns:
			spawn.path_index = path_data.path_index
			data.append(spawn.duplicate(true))
