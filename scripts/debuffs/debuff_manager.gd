## Manages all information related to debuffs for an entity. 
class_name DebuffManager
extends Node

func add_debuff(type: Constants.Debuff, value: float, duration: float) -> void:
	pass
	
func check_debuff_type_present(type: Constants.Debuff) -> bool:
	for debuff: Debuff in get_children():
		if debuff.type == type:
			return true
	return false

func choose_best_debuff():
	pass
