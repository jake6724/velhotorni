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

@onready var targeting: VBoxContainer = %Targeting 
@onready var target_left_button: TextureButton = %TargetLeftButton
@onready var target_right_button: TextureButton = %TargetRightButton
@onready var target_priority_label: Label = %TargetPriorityLabel
var target_priority_index: int = 0

@onready var damage_level_arrow: TextureRect = %DamageLevelArrow
@onready var speed_level_arrow: TextureRect = %SpeedLevelArrow
@onready var range_level_arrow: TextureRect = %RangeLevelArrow
@onready var special_level_arrow: TextureRect = %SpecialLevelArrow

@onready var portrait: TextureRect = %Portrait

@onready var cost_label: RichTextLabel = %CostLabel

@onready var desc: RichTextLabel = $%Description

var tower: Tower = null:
	set(_tower):
		tower = _tower
		update_stats()
		set_target_priority_data(tower.target_priority)
		set_portrait(tower.data.portrait)
		set_all_level_arrows()

var ui_text: UIText = UIText.new()

signal damage_button_pressed
signal speed_button_pressed
signal range_button_pressed
signal special_button_pressed
signal target_priority_changed
signal close_button_pressed

func _ready():
	# Connect to child signals
	damage_button.mouse_entered.connect(update_description.bind(ui_text.damage_button_hovered))
	damage_button.mouse_exited.connect(clear_description)
	damage_button.pressed.connect(on_damage_button_pressed)

	speed_button.mouse_entered.connect(update_description.bind(ui_text.speed_button_hovered))
	speed_button.mouse_exited.connect(clear_description)
	speed_button.pressed.connect(on_speed_button_pressed)

	range_button.mouse_entered.connect(update_description.bind(ui_text.range_button_hovered))
	range_button.mouse_exited.connect(clear_description)
	range_button.pressed.connect(on_range_button_pressed)

	special_button.mouse_entered.connect(update_description.bind(ui_text.special_button_hovered))
	special_button.mouse_exited.connect(clear_description)
	special_button.pressed.connect(on_special_button_pressed)

	close_button.pressed.connect(on_close_button_pressed)

	targeting.mouse_entered.connect(update_description.bind(ui_text.targeting_hovered))
	targeting.mouse_exited.connect(clear_description)
	target_left_button.pressed.connect(on_target_left_button_pressed)
	target_right_button.pressed.connect(on_target_right_button_pressed)

func update_stats() -> void:
	current_damage_label.text = str(snappedf(tower.curr_damage,.01))
	upgraded_damage_label.text = str(snappedf(tower.preview_damage, .01))

	current_speed_label.text = str(snappedf(tower.curr_speed, .01))
	upgraded_speed_label.text = str(snappedf(tower.preview_speed, .01))

	current_range_label.text = str(snappedf(tower.curr_range, .01))
	upgrade_range_label.text = str(snappedf(tower.preview_range, .01))

	update_debuff_stats()
	update_buff_stats()
	update_level_labels()
	update_ui_text()

	cost_label.text = str(tower.level_upgrade_price)

func update_debuff_stats() -> void:
	if tower.data.debuff_data:
		current_special_label.text = str(snappedf(tower.data.debuff_data.modified_total_duration, .01))
		upgraded_special_label.text = str(snappedf(tower.data.debuff_data.preview_modified_total_duration, .01))

func update_buff_stats() -> void:
	if tower.data.buff_data_list and tower.data.buff_data_list[0]:
		current_special_label.text = str(snappedf(tower.data.buff_data_list[0].leveled_value, .01))
		upgraded_special_label.text = str(snappedf(tower.data.buff_data_list[0].preview_leveled_value, .01))

func update_level_labels() -> void:
	if tower.level < 12:
		current_level_label.text = str("LV",tower.level + 1)
		next_level_label.text = str("LV",tower.level + 2)
	else:
		current_level_label.text = str("LV",tower.level + 1)
		next_level_label.text = str("MAX")

func update_ui_text() -> void:
	special_button.mouse_entered.disconnect(update_description)

	if tower.data.debuff_data:
		special_button.mouse_entered.connect(update_description.bind(ui_text.special_debuff_button_hovered_options[tower.data.debuff_data.type]))

	if tower.data.buff_data_list and tower.data.buff_data_list[0]:
		special_button.mouse_entered.connect(update_description.bind(ui_text.special_buff_button_hovered_options[tower.data.buff_data_list[0].type]))


func update_description(_text) -> void:
	desc.text = _text

func clear_description() -> void:
	desc.text = ""

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

func on_target_left_button_pressed() -> void:
	target_priority_changed.emit(get_prev_target_priority())

func on_target_right_button_pressed() -> void:
	target_priority_changed.emit(get_next_target_priority())

func get_next_target_priority() -> Tower.TargetPriority:
	match tower.target_priority:
		Tower.TargetPriority.FIRST: return Tower.TargetPriority.LAST
		Tower.TargetPriority.LAST: return Tower.TargetPriority.HIGHEST
		Tower.TargetPriority.HIGHEST: return Tower.TargetPriority.LOWEST
		Tower.TargetPriority.LOWEST: return Tower.TargetPriority.FIRST
		_: return Tower.TargetPriority.FIRST

func get_prev_target_priority() -> Tower.TargetPriority:
	match tower.target_priority:
		Tower.TargetPriority.FIRST: return Tower.TargetPriority.LOWEST
		Tower.TargetPriority.LAST: return Tower.TargetPriority.FIRST
		Tower.TargetPriority.HIGHEST: return Tower.TargetPriority.LAST
		Tower.TargetPriority.LOWEST: return Tower.TargetPriority.HIGHEST
		_: return Tower.TargetPriority.FIRST

func set_target_priority_data(priority: Tower.TargetPriority):
	ui_text.targeting_hovered = ui_text.targeting_hovered_options[priority]
	match priority:
		Tower.TargetPriority.FIRST: target_priority_label.text = "FIRST"
		Tower.TargetPriority.LAST: target_priority_label.text = "LAST"
		Tower.TargetPriority.HIGHEST: target_priority_label.text = "MOST HEALTH"
		Tower.TargetPriority.LOWEST: target_priority_label.text = "LEAST HEALTH"
		_: pass

func set_portrait(_texture: Texture) -> void:
	portrait.texture = _texture

func set_all_level_arrows() -> void:
	update_damage_level_arrow()
	update_speed_level_arrow()
	update_range_level_arrow()
	update_special_level_arrow() 

func update_damage_level_arrow() -> void:
	damage_level_arrow.texture.region = Rect2((8 * tower.damage_level), 0, 8, 0)

func update_speed_level_arrow() -> void:
	speed_level_arrow.texture.region = Rect2((8 * tower.speed_level), 0, 8, 0)

func update_range_level_arrow() -> void:
	range_level_arrow.texture.region = Rect2((8 * tower.range_level), 0, 8, 0)

func update_special_level_arrow() -> void:
	special_level_arrow.texture.region = Rect2((8 * tower.special_level), 0, 8, 0)