class_name BuffManager
extends Node

signal add_new_buff
signal remove_active_buff

var buff_data: BuffData

var buff_area: Area2D:
	set(value):
		buff_area = value
		buff_area.area_entered.connect(on_buff_area_entered)
		buff_area.area_exited.connect(on_buff_area_exited)

# @export var buff_collider: CollisionShape2D

func add_buff(new_buff_data: BuffData, _source: BuffManager) -> void:
	if not check_source_already_active(_source):
		set_buff_data_effectiveness(new_buff_data)
		var new_buff: Buff = create_buff(new_buff_data)
		new_buff.data.source = _source

		add_child(new_buff)
		add_new_buff.emit(new_buff)

func get_active_buffs_sorted() -> Array[Buff]:
	var sorted_buffs: Array[Buff]
	for child in get_children():
		var active_buff: Buff = child as Buff
		if active_buff:
			sorted_buffs.append(active_buff)

	sorted_buffs.sort_custom(compare_by_buff_value)
	return sorted_buffs

func set_buff_data_effectiveness(_buff_data: BuffData) -> void:
	# print("pre-effectiveness _buff_data.value: ", _buff_data.value)
	_buff_data.value = _buff_data.value / (2 ** get_buff_type_count(_buff_data.type))
	print("post-effectiveness _buff_data.value: ", _buff_data.value)

func get_buff_type_count(_type: Buff.Type) -> int:
	var count: int = 0
	for child in get_children():
		if child is Buff and child.data.type == _type:
			count += 1

	print("Type count: ", count)
	return count

func create_buff(_data: BuffData) -> Buff:
	# Create a new Buff object of the class defined in debuff_script
	var new_buff: Buff = Buff.new(_data.duplicate())
	return new_buff

func check_source_already_active(_source: BuffManager) -> bool:
	for child in get_children():
		if child is Buff and child.data.source == _source:
			print("Source already active!")
			return true
	print("Source NOT already active!")
	return false

func get_buff_by_source(_source: BuffManager) -> Buff:
	for child in get_children():
		if child is Buff and child.data.source == _source:
			print("Buff found by source")
			return child
	print("Buff not found by source")
	return null

func on_buff_area_entered(intruder) -> void:
	if intruder.owner != owner and intruder.owner is Tower:	
		apply_buff_to_ally(intruder.owner.buff_manager)

func on_buff_area_exited(intruder) -> void:
	print("Area exited")
	if intruder.owner != owner and intruder.owner is Tower:	
		print("Pass")
		var ally_buff_manager: BuffManager = intruder.owner.buff_manager
		var active_buff: Buff = ally_buff_manager.get_buff_by_source(self)
		if active_buff:
			ally_buff_manager.remove_buff(active_buff)

func apply_buff_to_ally(ally_buff_manager: BuffManager) -> void:
	ally_buff_manager.add_buff(buff_data, self)

func remove_all_buffs() -> void:
	for child in get_children():
		var buff: Buff = child as Buff
		if buff:
			remove_buff(buff)

func remove_buff(active_buff: Buff) -> void:
	print("REMOVING BUFF")
	remove_active_buff.emit(active_buff)
	active_buff.queue_free()

func compare_by_buff_value(buff_a: Enemy, buff_b: Enemy) -> bool:
	return buff_a.data.value > buff_b.data.value
