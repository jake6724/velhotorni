class_name TallGrass
extends Node2D

@onready var area: Area2D = $Area2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var overlay: Sprite2D = $Overlay
@onready var leaves: AnimatedSprite2D = $Leaves
var player_stopped: bool = false
var occupied: bool = false

func _ready():
	area.area_entered.connect(on_area_entered)
	area.area_exited.connect(on_area_exited)
	overlay.hide()

	overlay.z_index = Constants.z_index_map["tall_grass"]
	leaves.z_index = Constants.z_index_map["tall_grass"]

func on_area_entered(_player_ground_beacon: Area2D) -> void:
	ap.play("step")
	occupied = true

func on_area_exited(_player_ground_beacon: Area2D) -> void:
	ap.play("idle")
	occupied = false
	overlay.hide()

func on_player_stopped() -> void:
	if occupied and not player_stopped:
		player_stopped = true
		leaves.play("move")
		overlay.show()

func on_player_moving() -> void:
	player_stopped = false
	overlay.hide()
