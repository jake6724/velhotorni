class_name TowerHurtbox
extends Area2D

signal hit


func _ready():
	area_entered.connect(on_area_entered)

func on_area_entered(_intruder: Area2D) -> void:
	var enemy_bullet: EnemyBullet = _intruder.owner as EnemyBullet
	if enemy_bullet: 
		hit.emit(enemy_bullet.damage)
