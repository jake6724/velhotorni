class_name PlayerHUD
extends Control

@onready var weapons: HBoxContainer = %Weapons

@onready var active_spell_icon: TextureRect = %ActiveSpellIcon
@onready var active_spell_mana: TextureProgressBar = %ActiveSpellMana
@onready var active_spell_mana_label: RichTextLabel = %ActiveSpellManaLabel
@onready var tower_mana_label: RichTextLabel = %TowerManaLabel
# 
@onready var inactive_spell_1_icon: TextureRect = %InactiveSpell1Icon
@onready var inactive_spell_2_icon: TextureRect = %InactiveSpell2Icon
@onready var inactive_spell_3_icon: TextureRect = %InactiveSpell3Icon
@onready var inactive_spell_icons: Array[TextureRect] = [null, inactive_spell_1_icon, inactive_spell_2_icon, inactive_spell_3_icon] # null is used to make array parallel in size to spell_data_list

@onready var inactive_spell_1_mana: TextureProgressBar = %InactiveSpell1Mana
@onready var inactive_spell_2_mana: TextureProgressBar = %InactiveSpell2Mana
@onready var inactive_spell_3_mana: TextureProgressBar = %InactiveSpell3Mana
@onready var inactive_spell_manas: Array[TextureProgressBar] = [null, inactive_spell_1_mana, inactive_spell_2_mana, inactive_spell_3_mana] # null is used to make array parallel in size to spell_data_list

@onready var player_hearts: HBoxContainer = %PlayerHearts
@onready var player_portrait: PlayerPortrait = %PlayerPortrait

@onready var no_mana_label: Label = %NoManaLabel

@onready var wave_complete_label: Label = %WaveCompleteLabel

@onready var perk_mini_icons: HBoxContainer = %PerkMiniIcons

const MAX_TOWER_MANA_DIGITS: int = 4
const MAX_ACTIVE_SPELL_MANA_DIGITS: int = 3
const PADDING_COLOR: String = "#adb5bd"
const LOW_MANA_COLOR: String = "#d63100"
var bbc_string: String = "[color=%s]"
var bbc_color_mana_text: String = "[color=%s]"

var blinking_no_mana: bool = false

signal active_spell_mana_value_calculated

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

func on_spell_loadout_updated(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	update_spells(spell_data_list)
	update_mana(spell_data_list, player_mana)

func update_spells(spell_data_list: Array[SpellData]) -> void:

	if spell_data_list.size() > 0:
		weapons.show()
		active_spell_icon.texture = spell_data_list[0].active_icon

		# Hide all inactive spell icons. They will be shown below if required
		for icon in inactive_spell_icons.slice(1,inactive_spell_icons.size()):
		
			icon.hide()

		# Update texture and show any inactive icons which have corresponding spell data
		for i in range(1, spell_data_list.size()):
	
			if spell_data_list[i]:
				inactive_spell_icons[i].show()
				inactive_spell_icons[i].texture = spell_data_list[i].inactive_icon

	else:
		for icon in inactive_spell_icons.slice(1,inactive_spell_icons.size()):
			icon.hide()
		weapons.hide()

func update_mana(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	if spell_data_list.size() > 0:
		var active_spell_mana_text: String = str(int(player_mana.spell_mana[spell_data_list[0]]))
		active_spell_mana.value = (player_mana.spell_mana[spell_data_list[0]] / player_mana.spell_mana_maxes[spell_data_list[0]]) * 100
		var zero_pad: String = get_zero_padding(MAX_ACTIVE_SPELL_MANA_DIGITS - len(active_spell_mana_text))
		active_spell_mana_value_calculated.emit(active_spell_mana.value)

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

func update_tower_mana(player_mana) -> void:
	var text = str(int(player_mana.tower_mana))
	var zero_pad: String = get_zero_padding(MAX_TOWER_MANA_DIGITS - len(text))
	tower_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + text

func on_health_updated(_health: float) -> void:
	for heart: PlayerHUDHeart in player_hearts.get_children():
		
		if _health >= 2:
			heart.set_texture_full()
			_health -= 2

		elif _health == 1:
			heart.set_texture_half()
			_health -= 1

		else:
			heart.set_texture_empty()

	for heart: PlayerHUDHeart in player_hearts.get_children():
		heart.flash()

func set_player_portrait(_health, _player_max_health) -> void:
	player_portrait.on_hit()
	if _health > 1:
		player_portrait.set_texture_full()
		player_portrait.active_portrait = player_portrait.portrait_full
	elif _health == 1:
		player_portrait.set_texture_hit()
		player_portrait.active_portrait = player_portrait.portrait_hit
	else:
		player_portrait.set_texture_dead()

func set_player_portrait_firing() -> void:
	player_portrait.set_texture_firing()

func reset_player_portrait() -> void:
	player_portrait.reset_portrait()

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
