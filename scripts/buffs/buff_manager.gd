class_name BuffManager
extends Node

signal add_new_buff
signal remove_active_buff

var buff_pool: Array[Buff]

func add_buff(new_buff_data: BuffData, _source: BuffArea) -> void:
	var new_buff: Buff = create_buff(new_buff_data, _source, calc_buff_modified_value(new_buff_data))
	add_child(new_buff)
	add_new_buff.emit(new_buff)

func calc_buff_modified_value(_buff_data: BuffData) -> float:
	var _modified_value: float = _buff_data.leveled_value / (2 ** get_buff_type_count(_buff_data.type))
	return _modified_value

func create_buff(_data: BuffData, _source: BuffArea, _modified_value: float) -> Buff:
	var new_buff: Buff = Buff.new(_data.duplicate())
	new_buff.data.source = _source
	new_buff.data.modified_value = _modified_value
	return new_buff

func prioritize_buffs() -> void:
	if get_children().size() > 1:
		# Save a copy of all active buffs
		var buffs: Array[Buff] = get_sorted_buff_duplicates_by_type()

		# Clear all the original buffs
		remove_all_buffs()

		# Add the duplicates in the correct order
		for buff: Buff in buffs:
			add_buff(buff.data, buff.data.source)

func get_sorted_buff_duplicates_by_type() -> Array[Buff]:
	var sorted_buffs: Array[Buff] = []
	for child in get_children():
		var active_buff: Buff = child as Buff
		if active_buff:
			var copy_buff: Buff = create_buff(active_buff.data, active_buff.data.source, active_buff.data.modified_value)
			sorted_buffs.append(copy_buff)

	sorted_buffs.sort_custom(compare_by_buff_value)
	return sorted_buffs

func remove_all_buffs() -> void:
	for child in get_children():
		var buff: Buff = child as Buff
		if buff:
			remove_buff(buff)

func remove_buff(active_buff: Buff) -> void:
	remove_child(active_buff)
	remove_active_buff.emit(active_buff)
	active_buff.queue_free()

func get_buff_type_count(_type: Buff.Type) -> int:
	var count: int = 0
	for child in get_children():
		if child is Buff and child.data.type == _type:
			count += 1
	return count

func check_source_already_active(_source: BuffArea) -> bool:
	for child in get_children():
		if child is Buff and child.data.source == _source:
			return true
	return false

func get_buffs_by_source(_source: BuffArea) -> Array[Buff]:
	var buff_list: Array[Buff] = []
	for child in get_children():
		if child is Buff:
			if child.data.source == _source:
				buff_list.append(child)
	return buff_list

func compare_by_buff_value(buff_a: Buff, buff_b: Buff) -> bool:
	return buff_a.data.value > buff_b.data.value
