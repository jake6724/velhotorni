class_name BasePerkManager
extends Node

"""
This node directly manages and makes changes to Base and its child nodes based on signals emitted from
PerkBase objects. 
"""

@onready var base: Base = get_owner()

func on_modify_stat_requested(stat_to_modify: PerkDataBase.BaseStat, value: float) -> float:
	var modified_value: float
	match stat_to_modify:
		PerkDataBase.BaseStat.HEALTH:
			modified_value = value
			base.health += value
			
		PerkDataBase.BaseStat.MAX_HEALTH:
			modified_value = value
			base.max_health += value
			base.health += value
	return modified_value
