class_name TowerInfoMenu
extends Panel

@export_group("Pages")
@export var page_1: TowerInfoMenuPage1

@onready var exit_button: TextureButton = %ExitButton

var tower: Tower

signal exited

func _ready():
	page_1.tower_targeting_priority_updated.connect(on_tower_targeting_priority_updated)
	exit_button.pressed.connect(on_exit_button_pressed)

func update(_tower: Tower) -> void:
	tower = _tower
	page_1.update(_tower)

func on_exit_button_pressed() -> void:
	tower = null
	exited.emit()

func on_tower_targeting_priority_updated(_target_priority) -> void:
	tower.target_priority = _target_priority as Tower.TargetPriority
