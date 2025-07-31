class_name BuffManager
extends Node

signal add_new_buff
signal remove_active_buff

var buff_data: BuffData

var buff_pool: Array[Buff]

func add_buff(new_buff_data: BuffData, _source: BuffArea) -> void:
	if not check_source_already_active(_source):
		set_buff_data_effectiveness(new_buff_data)
		var new_buff: Buff = create_buff(new_buff_data, _source)

		add_child(new_buff)
		add_new_buff.emit(new_buff)

func set_buff_data_effectiveness(_buff_data: BuffData) -> void: #TODO: Rename
	print("Type count: ", get_buff_type_count(_buff_data.type))
	print("pre-effectiveness _buff_data.modified_value: ", _buff_data.modified_value)
	_buff_data.modified_value = _buff_data.value / (2 ** get_buff_type_count(_buff_data.type))
	print("post-effectiveness _buff_data.modified_value: ", _buff_data.modified_value)

func get_active_buffs_duplicates_sorted_() -> Array[Buff]:
	var sorted_buffs: Array[Buff] = []
	for child in get_children():
		var active_buff: Buff = child as Buff
		if active_buff:
			var copy_buff: Buff = create_buff(active_buff.data, active_buff.data.source)
			sorted_buffs.append(copy_buff)

	sorted_buffs.sort_custom(compare_by_buff_value)
	return sorted_buffs

func reorder_buffs() -> void:

	# TODO: Check if more than 1 buff, no need to order if only 1 
	print("REORDER BUFFS")
	# Save a copy of all active buffs
	var all_buffs: Array[Buff] = get_active_buffs_duplicates_sorted_()
	print("Sorted buff duplicates: ", all_buffs)

	# Clear all the original buffs
	remove_all_buffs()

	# Add the duplicates back, now in the correct order
	for buff: Buff in all_buffs:
		add_buff(buff.data, buff.data.source)

func get_buff_type_count(_type: Buff.Type) -> int:
	var count: int = 0
	for child in get_children():
		if child is Buff and child.data.type == _type:
			count += 1
	# print("Type count: ", count)
	return count

func create_buff(_data: BuffData, _source: BuffArea=null) -> Buff:
	# Create a new Buff object of the class defined in debuff_script
	var new_buff: Buff = Buff.new(_data.duplicate()) # Duplicate necessary if you are modifying the resource itself
	if _source:
		new_buff.data.source = _source
	return new_buff

func check_source_already_active(_source: BuffArea) -> bool:
	for child in get_children():
		if child is Buff and child.data.source == _source:
			return true
	return false

func get_buff_by_source(_source: BuffArea) -> Buff:
	for child in get_children():
		print(child)
		if child is Buff:
			if child.data.source == _source:
				return child
	return null

func remove_all_buffs() -> void:
	for child in get_children():
		var buff: Buff = child as Buff
		if buff:
			remove_buff(buff)

func remove_buff(active_buff: Buff) -> void:
	# print("REMOVING BUFF")
	remove_child(active_buff)
	remove_active_buff.emit(active_buff)
	active_buff.queue_free()

func compare_by_buff_value(buff_a: Buff, buff_b: Buff) -> bool:
	return buff_a.data.value > buff_b.data.value
