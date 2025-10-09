class_name PlayerHUD
extends Control

@onready var active_spell_icon: TextureRect = %ActiveSpellIcon
@onready var active_spell_mana_label: RichTextLabel = %ActiveSpellManaLabel
@onready var tower_mana_label: RichTextLabel = %TowerManaLabel
@onready var health_label: Label = %HealthLabel
@onready var health_bar: TextureProgressBar = %HealthBar

@onready var inactive_spell_1_icon: TextureRect = %InactiveSpell1Icon
@onready var inactive_spell_1_mana: TextureProgressBar = %InactiveSpell1Mana
@onready var inactive_spell_2_icon: TextureRect = %InactiveSpell2Icon
@onready var inactive_spell_2_mana: TextureProgressBar = %InactiveSpell2Mana
@onready var inactive_spell_3_icon: TextureRect = %InactiveSpell3Icon
@onready var inactive_spell_3_mana: TextureProgressBar = %InactiveSpell3Mana

const MAX_TOWER_MANA_DIGITS: int = 4
const MAX_ACTIVE_SPELL_MANA_DIGITS: int = 3
const PADDING_COLOR: String = "#adb5bd"
var bbc_string: String = "[color=%s]"

func _ready():
	active_spell_mana_label.bbcode_enabled = true
	tower_mana_label.bbcode_enabled = true

func initialize(spell_data_list: Array[SpellData], player_mana: PlayerMana, player_stats: PlayerCharacterStats) -> void:
	update_spells(spell_data_list, player_mana)
	update_tower_mana(player_mana)
	on_health_updated(player_stats.health)

func update_spells(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	active_spell_icon.texture.region = spell_data_list[0].active_icon_region
	var active_spell_mana_text: String = str(int(player_mana.get_element_mana(spell_data_list[0].element)))
	var zero_pad: String = get_zero_padding(MAX_ACTIVE_SPELL_MANA_DIGITS - len(active_spell_mana_text))
	active_spell_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + active_spell_mana_text

	inactive_spell_1_icon.texture.region = spell_data_list[1].inactive_icon_region
	inactive_spell_1_mana.value = (player_mana.get_element_mana(spell_data_list[1].element) / player_mana.get_element_mana_max(spell_data_list[1].element)) * 100

	inactive_spell_2_icon.texture.region = spell_data_list[2].inactive_icon_region
	inactive_spell_2_mana.value = (player_mana.get_element_mana(spell_data_list[2].element) / player_mana.get_element_mana_max(spell_data_list[2].element)) * 100

	inactive_spell_3_icon.texture.region = spell_data_list[3].inactive_icon_region
	inactive_spell_3_mana.value = (player_mana.get_element_mana(spell_data_list[3].element) / player_mana.get_element_mana_max(spell_data_list[3].element)) * 100

func update_mana(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	var active_spell_mana_text: String = str(int(player_mana.get_element_mana(spell_data_list[0].element)))
	var zero_pad: String = get_zero_padding(MAX_ACTIVE_SPELL_MANA_DIGITS - len(active_spell_mana_text))
	active_spell_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + active_spell_mana_text

	inactive_spell_1_mana.value = (player_mana.get_element_mana(spell_data_list[1].element) / player_mana.get_element_mana_max(spell_data_list[1].element)) * 100
	inactive_spell_2_mana.value = (player_mana.get_element_mana(spell_data_list[2].element) / player_mana.get_element_mana_max(spell_data_list[2].element)) * 100
	inactive_spell_3_mana.value = (player_mana.get_element_mana(spell_data_list[3].element) / player_mana.get_element_mana_max(spell_data_list[3].element)) * 100

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
