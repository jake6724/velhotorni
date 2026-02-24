class_name TowerInfoMenu
extends PanelContainer

var tower: Tower:
	set(_tower):
		tower = _tower
		target_priority_index = tower.target_priority as int
		target_priority_label.text = target_priority_label_options[target_priority_index]

@onready var target_left_button: TextureButton = %TargetLeftButton
@onready var target_right_button: TextureButton = %TargetRightButton
@onready var target_priority_label: Label = %TargetPriorityLabel
var target_priority_index: int = 0
var target_priority_index_max: int
var target_priority_label_options: Array[String] = ["First", "Last","Most Health", "Least Health"]

@onready var exit_button: TextureButton = %ExitButton

signal exited

func _ready():
	target_priority_index_max = target_priority_label_options.size()-1
	target_left_button.pressed.connect(on_tower_target_button_pressed.bind(-1))
	target_right_button.pressed.connect(on_tower_target_button_pressed.bind(1))
	
	exit_button.pressed.connect(on_exit_button_pressed)

func on_tower_target_button_pressed(_direction: int) -> void:
	target_priority_index += _direction
	if target_priority_index > target_priority_index_max:
		target_priority_index = 0
	elif target_priority_index < 0:
		target_priority_index = target_priority_index_max
	print(target_priority_index)
	target_priority_label.text = target_priority_label_options[target_priority_index]
	
	tower.target_priority = target_priority_index as Tower.TargetPriority

func on_exit_button_pressed() -> void:
	print("Press")
	exited.emit()
