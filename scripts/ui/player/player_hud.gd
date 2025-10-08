class_name PlayerHUD
extends Control

@onready var active_spell_icon: TextureRect = %ActiveSpellIcon
@onready var active_spell_mana_label: Label = %ActiveSpellManaLabel
@onready var tower_mana_label: Label = %TowerManaLabel
@onready var health_label: Label = %HealthLabel
@onready var health_bar: TextureProgressBar = %HealthBar

@onready var inactive_spell_1_icon: TextureRect = %InactiveSpell1Icon
@onready var inactive_spell_1_mana: TextureProgressBar = %InactiveSpell1Mana
@onready var inactive_spell_2_icon: TextureRect = %InactiveSpell2Icon
@onready var inactive_spell_2_mana: TextureProgressBar = %InactiveSpell2Mana
@onready var inactive_spell_3_icon: TextureRect = %InactiveSpell3Icon
@onready var inactive_spell_3_mana: TextureProgressBar = %InactiveSpell3Mana

func initialize(spell_data_list: Array[SpellData], player_mana: PlayerMana, player_stats: PlayerCharacterStats) -> void:
	update_spells(spell_data_list, player_mana)
	on_health_updated(player_stats.health)
	tower_mana_label.text = str(int(player_mana.tower_mana)).pad_zeros(4)

func update_spells(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	active_spell_icon.texture.region = spell_data_list[0].active_icon_region
	active_spell_mana_label.text = str(int(player_mana.get_element_mana(spell_data_list[0].element))).pad_zeros(3)

	inactive_spell_1_icon.texture.region = spell_data_list[1].inactive_icon_region
	inactive_spell_1_mana.value = (player_mana.get_element_mana(spell_data_list[1].element) / player_mana.get_element_mana_max(spell_data_list[1].element)) * 100

	inactive_spell_2_icon.texture.region = spell_data_list[2].inactive_icon_region
	inactive_spell_2_mana.value = (player_mana.get_element_mana(spell_data_list[2].element) / player_mana.get_element_mana_max(spell_data_list[2].element)) * 100

	inactive_spell_3_icon.texture.region = spell_data_list[3].inactive_icon_region
	inactive_spell_3_mana.value = (player_mana.get_element_mana(spell_data_list[3].element) / player_mana.get_element_mana_max(spell_data_list[3].element)) * 100

func update_mana(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	active_spell_mana_label.text = str(int(player_mana.get_element_mana(spell_data_list[0].element))).pad_zeros(3)
	inactive_spell_1_mana.value = (player_mana.get_element_mana(spell_data_list[1].element) / player_mana.get_element_mana_max(spell_data_list[1].element)) * 100
	inactive_spell_2_mana.value = (player_mana.get_element_mana(spell_data_list[2].element) / player_mana.get_element_mana_max(spell_data_list[2].element)) * 100
	inactive_spell_3_mana.value = (player_mana.get_element_mana(spell_data_list[3].element) / player_mana.get_element_mana_max(spell_data_list[3].element)) * 100

func on_health_updated(_health: float) -> void:
	health_label.text = str(int(_health))
	health_bar.value = _health
