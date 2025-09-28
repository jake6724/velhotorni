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
var dashing: bool = false
var dash_velocity: float = 400.0

var knockback_multiplier: float = 50.0

signal health_updated
signal mana_updated