class_name TowerInfoMenuPage1
extends Panel

@export_group("Node References")
@export_subgroup("General")
@export var tower_display: TextureRect
@export var tower_level_display: TextureRect
var animate_tower_display_timer: Timer = Timer.new()
const ANIMATE_TOWER_DISPLAY_FRAME_DURATION: float = .15
@export_subgroup("Targeting")
@export var targeting_left_button: TextureButton
@export var targeting_right_button: TextureButton
@export var target_priority_label: Label
@export var target_option_text_0: String
@export var target_option_text_1: String
@export var target_option_text_2: String
@export var target_option_text_3: String
var target_priority_index: int = 0
var target_priority_index_max: int
var target_priority_label_options: Array[String]

@export_subgroup("Stats")
@export var stat_damage: Label
@export var stat_speed: Label
@export var stat_range: Label
@export var stat_health: Label
@export var stat_max_health: Label
@export var stat_pierce: Label
@export var special_label: Label
@export var secondary_label: Label 
@export_multiline var debuff_text_slow: String
@export_multiline var debuff_text_stun: String
@export_multiline var debuff_text_freeze: String
@export_multiline var debuff_text_burn: String
@export_multiline var debuff_text_weaken: String
@export_multiline var debuff_text_knockback: String
@export_multiline var buff_text_range: String
@export_multiline var buff_text_speed: String
@export_multiline var buff_text_damage: String
@export_multiline var shield_text: String
@export_multiline var bullet_modifier_coin_text: String
var debuff_texts: Dictionary[Debuff.Type, String] = {}
var buff_texts: Dictionary[Buff.Type, String] = {}

@export_subgroup("Hints")
@export var hint_parent: VBoxContainer
@export var hint_1: Label
@export var hint_2: Label
@export var hint_3: Label

signal tower_targeting_priority_updated

func _ready():
	targeting_left_button.pressed.connect(on_tower_target_button_pressed.bind(-1))
	targeting_right_button.pressed.connect(on_tower_target_button_pressed.bind(1))
	target_priority_label_options = [target_option_text_0, target_option_text_1, target_option_text_2, target_option_text_3]
	target_priority_index_max = target_priority_label_options.size()-1

	animate_tower_display_timer.one_shot = false
	animate_tower_display_timer.autostart = false
	add_child(animate_tower_display_timer)
	animate_tower_display_timer.timeout.connect(on_animate_tower_display_timer_timeout)

	debuff_texts = {
	Debuff.Type.SLOW: debuff_text_slow,
	Debuff.Type.STUN: debuff_text_stun,
	Debuff.Type.FREEZE: debuff_text_freeze,
	Debuff.Type.BURN: debuff_text_burn,
	Debuff.Type.WEAKEN: debuff_text_weaken,
	Debuff.Type.KNOCKBACK: debuff_text_knockback,
	Debuff.Type.NONE: "",}

	buff_texts = {
		Buff.Type.RANGE: buff_text_range,
		Buff.Type.SPEED: buff_text_speed,
		Buff.Type.DAMAGE: buff_text_damage,
	}

func update(tower: Tower) -> void:
	# Update stats
	stat_damage.text = str(snappedf(tower.curr_damage, .01))
	stat_speed.text = str(snappedf(tower.curr_speed, .001))
	stat_range.text = str(snappedf(tower.curr_range, .01))
	stat_health.text = str(int(tower.health))
	stat_max_health.text = str(int(tower.curr_max_health))
	stat_pierce.text = str(int(tower.data.bullet_pierce))

	special_label.text = get_special_label_text(tower)
	secondary_label.text = get_secondary_label_text(tower)
	tower_display.texture = AtlasTexture.new()
	tower_display.texture.atlas = tower.data.atlas
	tower_display.texture.region = Rect2(0,0,16,16)
	animate_tower_display_timer.start(ANIMATE_TOWER_DISPLAY_FRAME_DURATION)

	tower_level_display.texture.region = Rect2(tower.level * 8, 0, 8, 16)

	# Hints
	hint_1.text = tower.data.tower_info_menu_hint_1
	hint_2.text = tower.data.tower_info_menu_hint_2
	hint_3.text = tower.data.tower_info_menu_hint_3
	
	update_target_priority(tower)

func get_special_label_text(tower: Tower) -> String:
	special_label.show()
	var _text: String = ""
	var debuff_data: DebuffData = tower.data.debuff_data
	if debuff_data:
		_text = debuff_texts[debuff_data.type]
		match debuff_data.type:
			Debuff.Type.SLOW: 
				_text = _text.replace("{value}", str(snappedf(debuff_data.value, .01)))
				_text = _text.replace("{modified_total_duration}", str(snappedf(debuff_data.modified_total_duration, .01)))
			Debuff.Type.STUN:
				_text = _text.replace("{modified_total_duration}", str(snappedf(debuff_data.modified_total_duration, .01)))
			Debuff.Type.FREEZE:
				_text = _text.replace("{modified_total_duration}", str(snappedf(debuff_data.modified_total_duration, .01)))
			Debuff.Type.BURN:
				_text = _text.replace("{modified_value}", str(snappedf(debuff_data.modified_value, .01)))
				_text = _text.replace("{total_duration}", str(snappedf(debuff_data.total_duration, .01)))
				_text = _text.replace("{repeat_duration}", str(snappedf(debuff_data.repeat_duration, .01)))
			Debuff.Type.WEAKEN:
				_text = _text.replace("{value}", str(snappedf(debuff_data.value, .01)))
				_text = _text.replace("{modified_total_duration}", str(snappedf(debuff_data.modified_total_duration, .01)))
			Debuff.Type.KNOCKBACK:
				_text = _text.replace("{modified_value}", str(snappedf(debuff_data.modified_value, .01)))
				_text = _text.replace("{total_duration}", str(snappedf(debuff_data.total_duration, .01)))

	elif tower.data.buff_data_list.size() > 0:
		var buff_data: BuffData = tower.data.buff_data_list[0]
		if buff_data:
			_text = buff_texts[buff_data.type]
			_text = _text.replace("{modified_value}", str(snappedf((buff_data.leveled_value * 100), .01)))

	else:
		special_label.hide()

	return _text

func get_secondary_label_text(tower: Tower) -> String:
	secondary_label.show()
	var _text: String
	if tower is ShieldTower:
		_text = shield_text
		_text = _text.replace("{shield_health}", str(int(tower.shield_health)))
	elif tower.data.bullet_modifier_data:
		_text = bullet_modifier_coin_text
	else:
		secondary_label.hide()
	return _text

func update_target_priority(tower: Tower) -> void:
	target_priority_index = tower.target_priority as int
	target_priority_label.text = target_priority_label_options[target_priority_index]

func on_tower_target_button_pressed(_direction: int) -> void:
	target_priority_index += _direction
	if target_priority_index > target_priority_index_max:
		target_priority_index = 0
	elif target_priority_index < 0:
		target_priority_index = target_priority_index_max
	target_priority_label.text = target_priority_label_options[target_priority_index]
	tower_targeting_priority_updated.emit(target_priority_index)

func on_animate_tower_display_timer_timeout() -> void:
	var x = tower_display.texture.region.position.x
	tower_display.texture.region = Rect2(x, 0, 16, 16)
	tower_display.texture.region.position.x += 16
	if tower_display.texture.region.position.x >= 64:
		tower_display.texture.region.position.x = 0
	animate_tower_display_timer.start(ANIMATE_TOWER_DISPLAY_FRAME_DURATION)
