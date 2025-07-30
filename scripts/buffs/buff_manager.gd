class_name BuffManager
extends Node

signal add_new_buff
signal remove_existing_buff

var buff_data: BuffData

var buff_area: Area2D:
	set(value):
		buff_area = value
		buff_area.area_entered.connect(on_buff_area_entered)

# @export var buff_collider: CollisionShape2D

func add_buff(new_buff_data: BuffData, _source: BuffManager) -> void:
	if not check_source_already_active(_source):
		print(self, ": Adding buff to myself")
		set_buff_data_effectiveness(new_buff_data)
		new_buff_data.source = _source
		var new_buff: Buff = create_buff(new_buff_data)
		add_child(new_buff)
		add_new_buff.emit(new_buff)

func remove_buff(_source: Tower) -> void:
	for child in get_children():
		if child is Buff and child.source == _source:
			remove_existing_buff.emit(child)

func set_buff_data_effectiveness(_buff_data: BuffData) -> void:
	_buff_data.value = _buff_data.value / (2 ** get_buff_type_count(_buff_data.type))

func get_buff_type_count(_type: Buff.Type) -> int:
	var count: int = 0
	for child in get_children():
		if child is Buff and child.data.type == _type:
			count += 1
	return count

func create_buff(_data: BuffData) -> Buff:
	# Create a new Buff object of the class defined in debuff_script
	var new_buff: Buff = Buff.new(_data)
	return new_buff

func check_source_already_active(_source: BuffManager) -> bool:
	for child in get_children():
		if child is Buff and child.data.source == _source:
			return true
	return false

func on_buff_area_entered(intruder) -> void:
	print("intruder: ", intruder)
	if intruder.owner != owner:
		var tower: Tower = intruder.owner as Tower
		if tower: # Only pass if intruder successfully cast as a tower
			print(self, ": Tower entered my buff zone!")
			tower.buff_manager.add_buff(buff_data, self)
