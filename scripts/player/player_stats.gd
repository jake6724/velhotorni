class_name PlayerCharacterStats # TODO: Change this to PlayerStats
extends Node 

signal health_updated
signal reflect_chance_updated

var max_health: float
var base_move_speed: float
var move_speed: float
var knockback_multiplier: float
var reflect_chance: float:
	set(value):
		reflect_chance = value
		reflect_chance_updated.emit(reflect_chance)
var hitstun_recovery_multiplier: float 
var hurtbox_iframe_duration: float
var hurtbox_iframe_duration_base: float

var special_charges_max: int
var special_charges: int
var special_charge_cooldown_duration: float
var special_charge_cooldown_duration_base: float

func load_player_data(data: PlayerData) -> void:
	max_health = data.max_health
	base_move_speed = data.base_move_speed
	move_speed = base_move_speed
	knockback_multiplier = data.knockback_multiplier
	reflect_chance = data.reflect_chance
	hitstun_recovery_multiplier = data.hitstun_recovery_multiplier
	hurtbox_iframe_duration = data.hurtbox_iframe_duration
	hurtbox_iframe_duration_base = hurtbox_iframe_duration
	special_charges_max = data.special_charges_max
	special_charges = data.special_charges
	special_charge_cooldown_duration = data.special_charge_cooldown_duration
	special_charge_cooldown_duration_base = special_charge_cooldown_duration

var health: float = 8.0:
	set(value):
		health = min(value, max_health)
		if health < 1:
			health = 0
		health_updated.emit(health)
