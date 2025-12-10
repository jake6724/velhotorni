class_name TowerHurtbox
extends Area2D

@onready var tower: Tower = get_owner()

signal hit

func take_damage(_damage) -> void:
	if tower.alive:
		hit.emit(_damage)
