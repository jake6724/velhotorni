class_name BuffArea
extends Area2D

var buff_data: BuffData:
	set(data):
		buff_data = data
		area_entered.connect(on_area_entered) # Only look for allies if a buff to apply is set
		area_exited.connect(on_area_exited)

func on_area_entered(intruder) -> void:
	if intruder.owner != owner and intruder.owner is Tower and intruder.owner.data.element != Constants.Element.LIGHT:	
		apply_buff_to_ally(intruder.owner.buff_manager)

func on_area_exited(intruder) -> void:
	if intruder.owner != owner and intruder.owner is Tower and intruder.owner.data.element != Constants.Element.LIGHT:	
		var ally_buff_manager: BuffManager = intruder.owner.buff_manager
		var active_buff: Buff = ally_buff_manager.get_buff_by_source(self)
		if active_buff:
			ally_buff_manager.remove_buff(active_buff)
			ally_buff_manager.prioritize_buffs()
			# ally_buff_manager.test()

func apply_buff_to_ally(ally_buff_manager: BuffManager) -> void:
	ally_buff_manager.add_buff(buff_data.duplicate(), self)
	ally_buff_manager.prioritize_buffs()
