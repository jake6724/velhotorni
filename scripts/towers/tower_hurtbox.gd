class_name TowerHurtbox
extends Area2D

signal hit

func take_damage(_damage) -> void:
	if owner.alive:
		hit.emit(_damage)
