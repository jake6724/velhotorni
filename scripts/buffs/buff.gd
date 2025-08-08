class_name Buff
extends Node

enum Type {RANGE, SPEED, DAMAGE}

var data: BuffData

func _init(_data: BuffData) -> void:
	data = _data