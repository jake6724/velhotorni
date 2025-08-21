## Used by `Tower` to manage Hexes which have been applied to it.
class_name HexManager
extends Node

signal new_hex_added
signal active_hex_removed

func add_hex(_hex_data: HexData, _source: HexArea) -> void:
	var new_hex: Hex = create_hex(_hex_data, _source, calc_hex_modified_value(_hex_data))
	add_child(new_hex)
	new_hex_added.emit(new_hex)

func calc_hex_modified_value(_hex_data: HexData) -> float:
	var _modified_value: float = _hex_data.value / (2 ** get_hex_count_by_type(_hex_data.type))
	return _modified_value

func get_hex_count_by_type(match_type: Hex.Type) -> int:
	var count: int = 0
	for child in get_children():
		var hex: Hex = child as Hex
		if hex and hex.type == match_type:
			count += 1
	return count

func create_hex(_hex_data: HexData, _source, _modified_value) -> Hex:
	var new_hex: Hex = Hex.new(_hex_data.duplicate())
	new_hex.data.source = _source
	new_hex.data.modified_value = _modified_value
	return new_hex

func remove_hex(active_hex: Hex) -> void:
	remove_child(active_hex)
	active_hex_removed.emit(active_hex)
	active_hex.queue_free()

func remove_all_hexes() -> void:
	for child in get_children():
		var hex: Hex = child as Hex
		if hex:
			remove_hex(hex)

func prioritize_hexs() -> void:
	if get_children().size() > 1:
		# Save a copy of all active hexs
		var hexes: Array[Hex] = get_sorted_hex_duplicates_by_type()

		# Clear all the original hexs
		remove_all_hexes()

		# Add the duplicates in the correct order
		for hex: Hex in hexes:
			add_hex(hex.data, hex.data.source)

func get_sorted_hex_duplicates_by_type() -> Array[Hex]:
	var sorted_hexes: Array[Hex] = []
	for child in get_children():
		var active_hex: Hex = child as Hex
		if active_hex:
			var copy_hex: Hex = create_hex(active_hex.data, active_hex.data.source, active_hex.data.modified_value)
			sorted_hexes.append(copy_hex)

	sorted_hexes.sort_custom(compare_by_hex_value)
	return sorted_hexes

func check_source_already_active(_source: HexArea) -> bool:
	for child in get_children():
		if child is Hex and child.data.source == _source:
			return true
	return false

func get_hexes_by_source(_source: HexArea) -> Array[Hex]:
	var hex_list: Array[Hex] = []
	for child in get_children():
		if child is Hex:
			if child.data.source == _source:
				hex_list.append(child)
	return hex_list

func compare_by_hex_value(hex_a: Hex, hex_b: Hex) -> bool:
	return hex_a.data.value > hex_b.data.value