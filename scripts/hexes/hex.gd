class_name Hex
extends Node

enum Type {DAMAGE, SPEED, RANGE, DISABLE}

var data: HexData

func _init(_data: HexData) -> void:
	data = _data