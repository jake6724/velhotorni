class_name TowerUpgradeMenu
extends Control

"""NOTES
It would be nice if each component (stat upgrade button, target prio, desc, etc. ) were all separate child
components that could handle their own update functionality
"""

@onready var damage_button: Button = %DamageButton
@onready var speed_button: Button = %SpeedButton
@onready var range_button: Button = %RangeButton
@onready var special_button: Button = %SpecialButton
@onready var close_button: Button = %CloseButton

@onready var current_damage_label: Label = %CurrentDamageLabel
@onready var upgraded_damage_label: Label = %UpgradedDamageLabel
@onready var current_speed_label: Label = %CurrentSpeedLabel
@onready var upgraded_speed_label: Label = %UpgradedSpeedLabel
@onready var current_range_label: Label = %CurrentRangeLabel
@onready var upgrade_range_label: Label = %UpgradedRangeLabel
@onready var current_special_label: Label = %CurrentSpecialLabel
@onready var upgraded_special_label: Label = %UpgradedSpecialLabel   

@onready var current_level_label: Label = %CurrentLevelLabel
@onready var next_level_label: Label = %NextLevelLabel

@onready var cost_label: RichTextLabel = %CostLabel

@onready var desc: RichTextLabel = $%Description

var tower: Tower = null:
	set(_tower):
		tower = _tower
		update_stats()

var ui_text: UIText = UIText.new()

signal damage_button_pressed
signal speed_button_pressed
signal range_button_pressed
signal special_button_pressed

signal close_button_pressed

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

	close_button.pressed.connect(on_close_button_pressed)

func update_stats() -> void:
	current_damage_label.text = str(snappedf(tower.curr_damage,.01))
	upgraded_damage_label.text = str(snappedf(tower.preview_damage, .01))

	current_speed_label.text = str(snappedf(tower.curr_speed, .01))
	upgraded_speed_label.text = str(snappedf(tower.preview_speed, .01))

	current_range_label.text = str(snappedf(tower.curr_range, .01))
	upgrade_range_label.text = str(snappedf(tower.preview_range, .01))

	# current_special_label.text = str(tower.damage_level + 1)
	# upgraded_special_label.text = str(tower.damage_level + 2)

	current_level_label.text = str("LV",tower.level + 1)
	next_level_label.text = str("LV",tower.level + 2)

	cost_label.text = str(tower.level_upgrade_price)

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

func on_close_button_pressed() -> void:
	close_button_pressed.emit()
