## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node2D

# TODO: TEMP!
@onready var enemy: Enemy = $".."

var x: float 

func add_debuff(_data: DebuffData) -> void:
	print("Add debuff called!")
	# Create a new Debuff object of the class defined in debuff_script
	var new_debuff: Debuff = _data.debuff_script.new(_data)
	add_child(new_debuff)
	# print(new_debuff.get_signal_list())

	for signal_dict in new_debuff.get_signal_list():
		var signal_name: String = signal_dict["name"]
		# print(signal_name)
		match signal_name:
			"debuff_apply_slow": new_debuff.connect(signal_name, Callable(self, "on_debuff_apply_slow"))
			"debuff_remove_slow": new_debuff.connect(signal_name, Callable(self, "on_debuff_remove_slow"))
			_: pass

	new_debuff.start_debuff()

func on_debuff_apply_slow(slow_percent: float):
	#TODO: Big cleanup

	x = enemy.speed

	enemy.speed = enemy.speed - (enemy.speed * (slow_percent/100))
	print("Apply slow called from Debuff Manager!")
	pass

func on_debuff_remove_slow(slow_percent: float):
	enemy.speed = x

# func check_debuff_type_present(type: Constants.Debuff) -> bool:
# 	for debuff: Debuff in get_children():
# 		if debuff.type == type:
# 			return true
# 	return false

# func choose_best_debuff():
# 	pass
