class_name ManaWell extends Area2D

@export var buff_data_list: Array[BuffData] = []
@export var buff_area: BuffArea
@export var sprite: AnimatedSprite2D

# Should be matched with what is in Tower
const RANGE_BUFF_LEVEL_MODIFIER: float = .5
const DAMAGE_BUFF_LEVEL_MODIFIER: float = .3334
const SPEED_BUFF_LEVEL_MODIFIER: float = .3334

func _ready() -> void:
	sprite.z_index = Constants.z_index_map["tower_shield"]
	update_buff_data()


func update_buff_data() -> void:
	# # Connect to BuffArea
	# if buff_data_list.size() > 0:
	# 	buff_area.initialize()
	# else:
	# 	buff_area.uninitialize()

	for buff_data: BuffData in buff_data_list:
		buff_data.leveled_value = buff_data.value		

	if buff_data_list and buff_data_list[0]:
		match buff_data_list[0].type:
			Buff.Type.RANGE:
				buff_data_list[0].leveled_value = (buff_data_list[0].value + ((buff_data_list[0].value * RANGE_BUFF_LEVEL_MODIFIER) * TowerGlobalData.buff_perk_modifier[buff_data_list[0].type]) * 0)
			Buff.Type.DAMAGE:
				buff_data_list[0].leveled_value = (buff_data_list[0].value + ((buff_data_list[0].value * DAMAGE_BUFF_LEVEL_MODIFIER) * TowerGlobalData.buff_perk_modifier[buff_data_list[0].type]) * 0)
			Buff.Type.SPEED:
				buff_data_list[0].leveled_value = (buff_data_list[0].value + ((buff_data_list[0].value * SPEED_BUFF_LEVEL_MODIFIER) * TowerGlobalData.buff_perk_modifier[buff_data_list[0].type]) * 0)

		buff_data_list = buff_data_list.duplicate(true)
