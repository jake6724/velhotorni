class_name WavePreviewPanel
extends PanelContainer

@onready var fire_label: Label = %FireLabel
@onready var wind_label: Label = %WindLabel
@onready var water_label: Label = %WaterLabel
@onready var earth_label: Label = %EarthLabel
@onready var light_label: Label = %LightLabel
@onready var dark_label: Label = %DarkLabel

var wave_previews: Array[Dictionary] = []

var total_health_values: Array = []

func get_wave_preview_data(wave_index: int) -> Dictionary[Constants.Element, float]:
	return wave_previews[wave_index]

func get_all_wave_preview_data(active_level: LevelEnvironment):
	for wave: Wave in active_level.waves:
		var fire_count: float = 0.0
		var wind_count: float = 0.0
		var water_count: float = 0.0
		var earth_count: float = 0.0
		var light_count: float = 0.0
		var dark_count: float = 0.0
		var total_count: float = 0.0

		for spawn: Spawn in wave.data:
			total_count += spawn.enemy_data.health
			match spawn.enemy_data.element:
				Constants.Element.FIRE: fire_count += spawn.enemy_data.health
				Constants.Element.WIND: wind_count += spawn.enemy_data.health
				Constants.Element.WATER: water_count += spawn.enemy_data.health
				Constants.Element.EARTH: earth_count += spawn.enemy_data.health
				Constants.Element.LIGHT: light_count += spawn.enemy_data.health
				Constants.Element.DARK: dark_count += spawn.enemy_data.health

		var wave_results: Dictionary[Constants.Element, float] = {
			Constants.Element.FIRE: ((fire_count / total_count) * 100),
			Constants.Element.WIND: ((wind_count / total_count)* 100),
			Constants.Element.WATER: ((water_count / total_count) * 100),
			Constants.Element.EARTH: ((earth_count / total_count) * 100),
			Constants.Element.LIGHT: ((light_count / total_count) * 100),
			Constants.Element.DARK: ((dark_count / total_count) * 100),
		}

		var wave_health_result = fire_count + wind_count + water_count + earth_count + light_count + dark_count
		total_health_values.append(wave_health_result)

		wave_previews.append(wave_results)
	
	print(total_health_values)

func set_preview_labels(wave_index: int) -> void:
	var data: Dictionary = get_wave_preview_data(wave_index)
	fire_label.text = str(int(snappedf(data[Constants.Element.FIRE],1)))
	wind_label.text = str(int(snappedf(data[Constants.Element.WIND],1)))
	water_label.text = str(int(snappedf(data[Constants.Element.WATER],1)))
	earth_label.text = str(int(snappedf(data[Constants.Element.EARTH],1)))
	light_label.text = str(int(snappedf(data[Constants.Element.LIGHT],1)))
	dark_label.text = str(int(snappedf(data[Constants.Element.DARK],1)))
