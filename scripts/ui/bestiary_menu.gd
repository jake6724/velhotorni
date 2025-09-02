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

var parent_scene: Node2D

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	for entry: BestiaryEntry in entries.get_children():
		print(entry)
		entry.pressed.connect(on_entry_pressed.bind(entry))

	close_button.pressed.connect(on_close_button_pressed)

func update_stats(entry: BestiaryEntry) -> void:
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
