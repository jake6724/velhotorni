class_name PlayerDetection
extends Area2D

@onready var player_detection_collider = $PlayerDetectionCollider

@export var base_detection_radius: float = 64.0
@export var chase_detection_radius: float = 80.0

var is_off_path: bool = false

signal player_detected
signal path_exit_position_updated
signal move_func_change_requested
signal player_escaped

func _ready():
	body_entered.connect(on_player_detected)
	body_exited.connect(on_player_escaped)
	player_detection_collider.shape.set_deferred("radius", base_detection_radius)

func on_player_detected(_player: PlayerCharacter) -> void:
	if not is_off_path:
		is_off_path = true
		path_exit_position_updated.emit(global_position)
	player_detected.emit(_player)
	player_detection_collider.shape.set_deferred("radius", chase_detection_radius)
	move_func_change_requested.emit("move_to_player")

func on_player_escaped(_player: PlayerCharacter) -> void:
	player_escaped.emit()
	player_detection_collider.shape.set_deferred("radius", base_detection_radius)
	move_func_change_requested.emit("move_to_path")