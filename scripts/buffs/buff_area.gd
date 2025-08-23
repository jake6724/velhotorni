class_name BuffArea
extends Area2D

var buff_data_list: Array[BuffData] = []

## Called directly by parent tower
func initialize() -> void:
	if not is_connected("area_entered", on_area_entered): area_entered.connect(on_area_entered) # Only look for allies if a buff to apply is set
	if not is_connected("area_exited", on_area_exited): area_exited.connect(on_area_exited)

func uninitialize() -> void:
	if is_connected("area_entered", on_area_entered): disconnect("area_entered", on_area_entered)
	if is_connected("area_exited", on_area_exited): disconnect("area_exited", on_area_exited)

func on_area_entered(intruder) -> void:
	if intruder.owner != owner and intruder.owner is Tower and intruder.owner.data.base_element != Constants.Element.LIGHT:	
		apply_buff_to_ally(intruder.owner.buff_manager)

func apply_buff_to_ally(ally_buff_manager: BuffManager) -> void:
	for buff_data: BuffData in buff_data_list:
		ally_buff_manager.add_buff(buff_data.duplicate(true), self)
	ally_buff_manager.prioritize_buffs()

func on_area_exited(intruder) -> void:
	if intruder.owner != owner and intruder.owner is Tower and intruder.owner.data.base_element != Constants.Element.LIGHT:	
		var ally_buff_manager: BuffManager = intruder.owner.buff_manager
		var active_buffs: Array[Buff] = ally_buff_manager.get_buffs_by_source(self)
		for buff: Buff in active_buffs:
			ally_buff_manager.remove_buff(buff)
		ally_buff_manager.prioritize_buffs()
