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