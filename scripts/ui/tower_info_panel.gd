class_name TowerInfoPanel
extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var damage_label: Label = %DamageLabel 
@onready var speed_label: Label = %SpeedLabel
@onready var range_label: Label = %RangeLabel
@onready var special_label: Label = %SpecialLabel
@onready var desc: RichTextLabel = %Description

var ui_text: TowerInfoPanelUIText = TowerInfoPanelUIText.new()

func update_stats(_tower: Tower) -> void:
	if _tower:
		name_label.text = _tower.data.tower_name
		damage_label.text = str(snappedf(_tower.curr_damage, .01))
		#speed_label.text = str(snappedf((1 / _tower.curr_speed), .01))
		speed_label.text = str(snappedf(_tower.curr_speed, .01))
		range_label.text = str(snappedf(_tower.curr_range, .01))

		update_debuff_stats(_tower)
		update_buff_stats(_tower)
		update_description(_tower)

func update_debuff_stats(_tower: Tower) -> void:
	if _tower:
		if _tower.data.debuff_data:
			match _tower.data.debuff_data.type:
				Debuff.Type.BURN: special_label.text = str(snappedf(_tower.data.debuff_data.modified_value, .01))
				Debuff.Type.KNOCKBACK: special_label.text = str(snappedf(_tower.data.debuff_data.modified_value, .01))
				Debuff.Type.SLOW: special_label.text = str(snappedf(_tower.data.debuff_data.modified_total_duration, .01))
				Debuff.Type.FREEZE: special_label.text = str(snappedf(_tower.data.debuff_data.modified_total_duration, .01))
				Debuff.Type.STUN: special_label.text = str(snappedf(_tower.data.debuff_data.modified_total_duration, .01))
				Debuff.Type.WEAKEN: special_label.text = str(snappedf(_tower.data.debuff_data.modified_total_duration, .01))
				_: pass

func update_buff_stats(_tower: Tower) -> void:
	if _tower:
		if _tower.data.buff_data_list and _tower.data.buff_data_list[0]:
			match _tower.data.buff_data_list[0].type:
				Buff.Type.DAMAGE: special_label.text = str(snappedf(_tower.data.buff_data_list[0].leveled_value, .01))
				Buff.Type.SPEED: special_label.text = str(snappedf(_tower.data.buff_data_list[0].leveled_value, .01))
				Buff.Type.RANGE: special_label.text = str(snappedf(_tower.data.buff_data_list[0].leveled_value, .01))

func update_description(_tower: Tower) -> void:
	if _tower:
		if _tower.data.debuff_data:
			match _tower.data.debuff_data.type:
				Debuff.Type.BURN: update_desc(ui_text.desc_debuff_burn)
				Debuff.Type.SLOW: update_desc(ui_text.desc_debuff_slow)
				Debuff.Type.FREEZE: update_desc(ui_text.desc_debuff_freeze)
				Debuff.Type.STUN: update_desc(ui_text.desc_debuff_stun)
				Debuff.Type.KNOCKBACK: update_desc(ui_text.desc_debuff_knockback)
				Debuff.Type.WEAKEN: update_desc(ui_text.desc_debuff_weaken)
				_: pass

		if _tower.data.buff_data_list and _tower.data.buff_data_list[0]:
			match _tower.data.buff_data_list[0].type:
				Buff.Type.DAMAGE: update_desc(ui_text.desc_buff_damage)
				Buff.Type.SPEED: update_desc(ui_text.desc_buff_speed)
				Buff.Type.RANGE: update_desc(ui_text.desc_buff_range)
		
func update_desc(_text: String) -> void:
	desc.text = _text


###### Shop functions ######

func update_stats_shop(_tower_data: TowerData) -> void:
	if _tower_data:
		name_label.text = _tower_data.tower_name
		damage_label.text = str(snappedf(_tower_data.damage, .01))
		# speed_label.text = str(snappedf((1 / _tower_data.speed), .01))
		speed_label.text = str(snappedf(_tower_data.speed, .01))
		range_label.text = str(snappedf(_tower_data.attack_range, .01))

		update_debuff_stats_shop(_tower_data)
		update_buff_stats_shop(_tower_data)
		update_description_shop(_tower_data)

func update_debuff_stats_shop(_tower_data) -> void:
	if _tower_data:
		if _tower_data.debuff_data:
			match _tower_data.debuff_data.type:
				Debuff.Type.BURN: special_label.text = str(snappedf(_tower_data.debuff_data.value, .01))
				Debuff.Type.KNOCKBACK: special_label.text = str(snappedf(_tower_data.debuff_data.value, .01))
				Debuff.Type.SLOW: special_label.text = str(snappedf(_tower_data.debuff_data.total_duration, .01))
				Debuff.Type.FREEZE: special_label.text = str(snappedf(_tower_data.debuff_data.total_duration, .01))
				Debuff.Type.STUN: special_label.text = str(snappedf(_tower_data.debuff_data.total_duration, .01))
				Debuff.Type.WEAKEN: special_label.text = str(snappedf(_tower_data.debuff_data.total_duration, .01))
				_: pass

func update_buff_stats_shop(_tower_data) -> void: 
	if _tower_data:
		if _tower_data.buff_data_list and _tower_data.buff_data_list[0]:
			match _tower_data.buff_data_list[0].type:
				Buff.Type.DAMAGE: special_label.text = str(snappedf(_tower_data.buff_data_list[0].value, .01))
				Buff.Type.SPEED: special_label.text = str(snappedf(_tower_data.buff_data_list[0].value, .01))
				Buff.Type.RANGE: special_label.text = str(snappedf(_tower_data.buff_data_list[0].value, .01))

func update_description_shop(_tower_data) -> void: 
	if _tower_data:
		if _tower_data.debuff_data:
			match _tower_data.debuff_data.type:
				Debuff.Type.BURN: update_desc(ui_text.desc_debuff_burn)
				Debuff.Type.SLOW: update_desc(ui_text.desc_debuff_slow)
				Debuff.Type.FREEZE: update_desc(ui_text.desc_debuff_freeze)
				Debuff.Type.STUN: update_desc(ui_text.desc_debuff_stun)
				Debuff.Type.KNOCKBACK: update_desc(ui_text.desc_debuff_knockback)
				Debuff.Type.WEAKEN: update_desc(ui_text.desc_debuff_weaken)
				_: pass

		if _tower_data.buff_data_list and _tower_data.buff_data_list[0]:
			match _tower_data.buff_data_list[0].type:
				Buff.Type.DAMAGE: update_desc(ui_text.desc_buff_damage)
				Buff.Type.SPEED: update_desc(ui_text.desc_buff_speed)
				Buff.Type.RANGE: update_desc(ui_text.desc_buff_range)
