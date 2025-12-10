class_name PlayerHUD
extends Control

@onready var active_spell_icon: TextureRect = %ActiveSpellIcon
@onready var active_spell_mana: TextureProgressBar = %ActiveSpellMana
@onready var active_spell_mana_label: RichTextLabel = %ActiveSpellManaLabel
@onready var tower_mana_label: RichTextLabel = %TowerManaLabel
@onready var health_label: Label = %HealthLabel
@onready var health_bar: TextureProgressBar = %HealthBar

@onready var inactive_spell_1_icon: TextureRect = %InactiveSpell1Icon
@onready var inactive_spell_2_icon: TextureRect = %InactiveSpell2Icon
@onready var inactive_spell_3_icon: TextureRect = %InactiveSpell3Icon
@onready var inactive_spell_icons: Array[TextureRect] = [null, inactive_spell_1_icon, inactive_spell_2_icon, inactive_spell_3_icon] # null is used to make array parallel in size to spell_data_list

@onready var inactive_spell_1_mana: TextureProgressBar = %InactiveSpell1Mana
@onready var inactive_spell_2_mana: TextureProgressBar = %InactiveSpell2Mana
@onready var inactive_spell_3_mana: TextureProgressBar = %InactiveSpell3Mana
@onready var inactive_spell_manas: Array[TextureProgressBar] = [null, inactive_spell_1_mana, inactive_spell_2_mana, inactive_spell_3_mana] # null is used to make array parallel in size to spell_data_list

@onready var no_mana_label: Label = %NoManaLabel

@onready var combat_mode_margin_container: MarginContainer = %CombatModeMarginContainer
@onready var combat_mode_icon: TextureRect = %CombatModeIcon
@onready var build_mode_margin_container: MarginContainer = %BuildModeMarginContainer
@onready var build_mode_icon: TextureRect = %BuildModeIcon

@onready var wave_complete_label: Label = %WaveCompleteLabel

@onready var perk_mini_icons: HBoxContainer = %PerkMiniIcons

const MAX_TOWER_MANA_DIGITS: int = 4
const MAX_ACTIVE_SPELL_MANA_DIGITS: int = 3
const PADDING_COLOR: String = "#adb5bd"
const LOW_MANA_COLOR: String = "#d63100"
var bbc_string: String = "[color=%s]"
var bbc_color_mana_text: String = "[color=%s]"

var blinking_no_mana: bool = false

func _ready():
	active_spell_mana_label.bbcode_enabled = true
	tower_mana_label.bbcode_enabled = true
	no_mana_label.show()

	no_mana_label.add_theme_constant_override("outline_size", 0)

	for icon in inactive_spell_icons.slice(1,-1):
		icon.hide()

func initialize(spell_data_list: Array[SpellData], player_mana: PlayerMana, player_stats: PlayerCharacterStats) -> void:
	update_spells(spell_data_list)
	update_mana(spell_data_list, player_mana)
	update_tower_mana(player_mana)
	on_health_updated(player_stats.health)

func update_spells(spell_data_list: Array[SpellData]) -> void:
	active_spell_icon.texture = spell_data_list[0].active_icon

	for i in range(1, spell_data_list.size()):
		inactive_spell_icons[i].show()
		inactive_spell_icons[i].texture = spell_data_list[i].inactive_icon

func update_mana(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	var active_spell_mana_text: String = str(int(player_mana.spell_mana[spell_data_list[0]]))
	active_spell_mana.value = (player_mana.spell_mana[spell_data_list[0]] / player_mana.spell_mana_maxes[spell_data_list[0]]) * 100
	var zero_pad: String = get_zero_padding(MAX_ACTIVE_SPELL_MANA_DIGITS - len(active_spell_mana_text))
	
	var mana_text_color: String
	if player_mana.spell_mana_low[spell_data_list[0]]:
		no_mana_label.show()
		mana_text_color = LOW_MANA_COLOR
		if player_mana.spell_mana[spell_data_list[0]] == 0:
			no_mana_label.text = "EMPTY"
		else:
			no_mana_label.text = "LOW MANA"
	else:
		mana_text_color = "ffffff"
		no_mana_label.hide()

	active_spell_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + bbc_color_mana_text % mana_text_color + active_spell_mana_text + "[/color]"

	for i in range(1,spell_data_list.size()):
		inactive_spell_manas[i].value = (player_mana.spell_mana[spell_data_list[i]] / player_mana.spell_mana_maxes[spell_data_list[i]]) * 100
			
	# inactive_spell_1_mana.value = (player_mana.spell_mana[spell_data_list[1]] / player_mana.spell_mana_maxes[spell_data_list[1]]) * 100
	# inactive_spell_2_mana.value = (player_mana.spell_mana[spell_data_list[2]] / player_mana.spell_mana_maxes[spell_data_list[2]]) * 100
	# inactive_spell_3_mana.value = (player_mana.spell_mana[spell_data_list[3]] / player_mana.spell_mana_maxes[spell_data_list[3]]) * 100

func update_tower_mana(player_mana) -> void:
	var text = str(int(player_mana.tower_mana))
	var zero_pad: String = get_zero_padding(MAX_TOWER_MANA_DIGITS - len(text))
	tower_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + text

func on_health_updated(_health: float) -> void:
	health_label.text = str(int(_health))
	health_bar.value = _health

func get_zero_padding(count: int):
	var zero: String = "0"
	var res: String = ""
	for i in range(count):
		res += zero
	return res

func blink_no_mana_label() -> void:
	if not blinking_no_mana:
		blinking_no_mana = true
		var blink_tween = get_tree().create_tween()
		blink_tween.set_loops(3)
		blink_tween.tween_property(no_mana_label, "modulate:a", 0.0, .01)
		blink_tween.tween_interval(.1)
		blink_tween.tween_property(no_mana_label, "modulate:a", 1.0, .01)
		blink_tween.tween_interval(.1)
		await blink_tween.finished
		blinking_no_mana = false

func animate_switch_mode(_building: bool) -> void:
	var combat_tween: Tween = get_tree().create_tween()
	var build_tween: Tween = get_tree().create_tween()

	if _building: 																		   # Move build to the front
		build_mode_margin_container.add_theme_constant_override("margin_left", 0)
		build_mode_margin_container.add_theme_constant_override("margin_top", 0)
		var build_target_pos_1: Vector2 = Vector2(12, -5)
		build_tween.tween_property(build_mode_icon, "position", build_target_pos_1, .2)
		build_mode_icon.z_index += 1

		var combat_target_pos_1: Vector2 = Vector2(2, 2)
		combat_tween.tween_property(combat_mode_icon, "position", combat_target_pos_1, .2)

		var build_target_pos_2: Vector2 = Vector2(0, -2)
		build_tween.tween_property(build_mode_icon, "position", build_target_pos_2, .2)

	else:		  																			# Move combat to the front
		var combat_target_pos_1: Vector2 = Vector2(12, -3)
		combat_tween.tween_property(combat_mode_icon, "position", combat_target_pos_1, .2)
		build_mode_icon.z_index -= 1

		var build_target_pos_1: Vector2 = Vector2(2, 0)
		build_tween.tween_property(build_mode_icon, "position", build_target_pos_1, .2)

		var combat_target_pos_2: Vector2 = Vector2(0, 0)
		combat_tween.tween_property(combat_mode_icon, "position", combat_target_pos_2, .2)

func blink_wave_complete() -> void:
	wave_complete_label.show()
	blink_ui_element(wave_complete_label, 5, .4, .4, true)

func blink_ui_element(_ui_element: Control, _blink_amount: int=3, hide_duration: float=0.1, show_duration:float=0.1, hide_on_finished: bool=true) -> void:
	var blink_tween: Tween = get_tree().create_tween()
	blink_tween.set_loops(_blink_amount)
	blink_tween.tween_property(_ui_element, "modulate:a", 0.0, .01)
	blink_tween.tween_interval(hide_duration)
	blink_tween.tween_property(_ui_element, "modulate:a", 1.0, .01)
	blink_tween.tween_interval(show_duration)
	await blink_tween.finished
	if hide_on_finished: _ui_element.hide()
