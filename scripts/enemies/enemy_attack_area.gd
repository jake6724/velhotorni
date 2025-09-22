class_name EnemyAttackArea
extends Area2D

signal animation_requested
signal attack_requested

func _ready():
	body_entered.connect(on_player_reached)
	body_exited.connect(on_player_escaped)

func on_player_reached(_player: PlayerCharacter) -> void:
	attack_requested.emit(true)
	animation_requested.emit("wind_up")

func on_player_escaped(_player: PlayerCharacter) -> void:
	attack_requested.emit(false)

func check_continue_attacking() -> void:
	if get_overlapping_bodies().size():
		animation_requested.emit("wind_up")
	else:
		attack_requested.emit(false)