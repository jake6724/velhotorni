class_name HexArea
extends Area2D

func _ready():
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)

func on_area_entered(intruder: Area2D) -> void:
	var tower: Tower = intruder.owner as Tower
	if tower:
		pass

func on_area_exited(intruder: Area2D) -> void:
	var tower: Tower = intruder.owner as Tower
	if tower:
		pass