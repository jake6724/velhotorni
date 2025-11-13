class_name PlayerCharacterStats # TODO: Change this to PlayerStats
extends Node 

signal health_updated

var max_health: float
var base_move_speed: float
var move_speed: float
var knockback_multiplier: float
var reflect_chance: float
var hitstun_recovery_multiplier: float 
var hurtbox_iframe_duration: float

func load_player_data(data: PlayerData) -> void:
	max_health = data.max_health
	base_move_speed = data.base_move_speed
	move_speed = base_move_speed
	knockback_multiplier = data.knockback_multiplier
	reflect_chance = data.reflect_chance
	hitstun_recovery_multiplier = data.hitstun_recovery_multiplier
	hurtbox_iframe_duration = data.hurtbox_iframe_duration

var health: float = 8.0:
	set(value):
		health = min(value, max_health)
		if health < 1:
			health = 0
		health_updated.emit(health)
