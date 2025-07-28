## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node2D

# TODO: TEMP!
@onready var enemy: Enemy = $".."

signal add_new_debuff

var x: float 

func add_debuff(_data: DebuffData) -> void:
	# Create a new Debuff object of the class defined in debuff_script
	var new_debuff: Debuff = _data.debuff_script.new(_data)
	add_child(new_debuff)

	# Emit Debuff ref for parent to connect to
	add_new_debuff.emit(new_debuff)

	new_debuff.call_deferred("start_debuff")

# func check_debuff_type_present(type: Constants.Debuff) -> bool:
# 	for debuff: Debuff in get_children():
# 		if debuff.type == type:
# 			return true
# 	return false

# func choose_best_debuff():
# 	pass
