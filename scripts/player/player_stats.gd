class_name PlayerCharacterStats
extends Node

var health: float = 6.0:
	set(value):
		health = value
		health_updated.emit(health)

var mana: float = 100.0:
	set(value):
		mana = value
		mana_updated.emit(mana)

var speed: float = 100.0
var knockback_multiplier: float = 70.0

signal health_updated
signal mana_updated