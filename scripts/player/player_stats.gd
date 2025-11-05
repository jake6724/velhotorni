class_name PlayerCharacterStats # TODO: Change this to PlayerStats
extends Node 

signal health_updated
signal mana_updated

var max_health = 8.0

var health: float = 8.0:
	set(value):
		health = value
		if health < 1:
			health = 0
		health_updated.emit(health)

var mana: float = 100.0:
	set(value):
		mana = value
		mana_updated.emit(mana)

# var combat_speed: float = 100.0
# var build_speed: float = 100.0
var move_speed: float = 100.0
var knockback_multiplier: float = 70.0
var chance_to_reflect: float = 0.0

var hitstun_recovery_multiplier: float = 300 # Influences how quickly the player stops sliding when hitstun and recovers back to normal mode
var hurtbox_iframe_duration: float = 1.5