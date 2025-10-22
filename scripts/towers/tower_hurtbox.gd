class_name TowerHurtbox
extends Area2D

signal hit

func take_damage(_damage) -> void:
	hit.emit(_damage)
