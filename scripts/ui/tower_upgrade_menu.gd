class_name TowerUpgradeMenu
extends Control

@onready var damage_button: Button = %DamageButton
@onready var speed_button: Button = %SpeedButton
@onready var range_button: Button = %RangeButton
@onready var special_button: Button = %SpecialButton

@onready var desc: RichTextLabel = $%Description

var ui_text: UIText = UIText.new()

signal damage_button_pressed
signal speed_button_pressed
signal range_button_pressed
signal special_button_pressed

func _ready():
	# Connect to child signals
	damage_button.mouse_entered.connect(update_description.bind(ui_text.damage_button_hovered))
	damage_button.pressed.connect(on_damage_button_pressed)

	speed_button.mouse_entered.connect(update_description.bind(ui_text.speed_button_hovered))
	speed_button.pressed.connect(on_speed_button_pressed)

	range_button.mouse_entered.connect(update_description.bind(ui_text.range_button_hovered))
	range_button.pressed.connect(on_range_button_pressed)

	special_button.mouse_entered.connect(update_description.bind(ui_text.special_button_hovered))
	special_button.pressed.connect(on_special_button_pressed)

func update_description(_text) -> void:
	desc.text = _text

func on_damage_button_pressed() -> void:
	damage_button_pressed.emit()

func on_speed_button_pressed() -> void:
	speed_button_pressed.emit()

func on_range_button_pressed() -> void:
	range_button_pressed.emit()

func on_special_button_pressed() -> void:
	special_button_pressed.emit()