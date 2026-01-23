class_name TeleportArea
extends Area2D

@export var link: TeleportArea
@onready var teleport_point: Node2D = %TeleportPoint

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(player: PlayerCharacter) -> void:
	# player.player_camera.position_smoothing_enabled = false
	SceneTransition.teleport_player(player, link.teleport_point.global_position)
