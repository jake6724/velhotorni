class_name HexManager
extends Node

func add_hex(_hex_data: HexData) -> void:
	pass

func calc_modified_value(_hex_data: Hex) -> float:
	var _modified_value: float = _hex_data.leveled_value / (2 ** get_hex_count_by_type(_hex_data.type))
	return _modified_value

func get_hex_count_by_type(match_type: Hex.Type) -> int:
	var count: int = 0
	for child in get_children():
		var hex: Hex = child as Hex
		if hex and hex.type == match_type:
			count += 1
	return count

# func create_hex()