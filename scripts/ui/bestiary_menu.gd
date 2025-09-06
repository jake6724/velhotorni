class_name BestiaryMenu
extends NinePatchRect

@onready var entries: VBoxContainer = %Entries
@onready var entry_name: Label = %EntryName
@onready var description: RichTextLabel = %Description

@onready var health_value: Label = %HealthValue
@onready var damage_value: Label = %DamageValue
@onready var speed_value: Label = %SpeedValue
@onready var element_icon: TextureRect = %ElementIcon

@onready var close_button: Button = %CloseButton

# @onready var stats: VBoxContainer = %Stats

var parent_scene: Node2D
var enemy_data_in_level: Dictionary[EnemyData, bool] = {}
var entry_map: Dictionary[EnemyData, BestiaryEntry]

var bestiary_entry_scene: PackedScene = preload("res://scenes/ui/BestiaryEntry.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	close_button.pressed.connect(on_close_button_pressed)

## Called manually by Main
func add_entries() -> void:
	for wave: Wave in WaveManager.level_waves:
		for spawn: Spawn in wave.data:
			if spawn.enemy_data not in enemy_data_in_level:
				enemy_data_in_level[spawn.enemy_data] = true
				print(spawn.enemy_data.enemy_name)

	for enemy_data: EnemyData in enemy_data_in_level:
		var new_entry: BestiaryEntry = bestiary_entry_scene.instantiate()
		new_entry.data = enemy_data
		new_entry.pressed.connect(on_entry_pressed.bind(new_entry))

		entry_map[enemy_data] = new_entry
		entries.add_child(new_entry)
		# new_entry.hide()

func update_stats(entry: BestiaryEntry) -> void:
	# stats.show()
	
	# Text
	entry_name.text = entry.data.enemy_name
	description.text = entry.data.enemy_description

	# Stats
	health_value.text = str(int(entry.data.health))
	damage_value.text = str(int(entry.data.damage))
	speed_value.text = str(int(entry.data.speed))

	match entry.data.element:
		Constants.Element.FIRE: element_icon.texture.region = Rect2(10, 0, 10, 10)
		Constants.Element.WIND: element_icon.texture.region = Rect2(0, 0, 10, 10)
		Constants.Element.WATER: element_icon.texture.region = Rect2(0, 10, 10, 10)
		Constants.Element.EARTH: element_icon.texture.region = Rect2(10, 10, 10, 10)
		Constants.Element.LIGHT: element_icon.texture.region = Rect2(20, 0, 10, 10)
		Constants.Element.DARK: element_icon.texture.region = Rect2(20, 10, 10, 10)

func on_entry_pressed(entry: BestiaryEntry) -> void:
	update_stats(entry)

func on_entry_mouse_exited() -> void:
	pass

func on_close_button_pressed():
	parent_scene.unpause_game_with_bestiary()

func on_enemy_spawned(enemy: Enemy) -> void:
	if enemy_data_in_level[enemy.data]:
		enemy_data_in_level[enemy.data] = false

		entry_map[enemy.data].hidden_icon.hide()
