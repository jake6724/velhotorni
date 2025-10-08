class_name PlayerHUD
extends Control

@onready var active_spell_icon: TextureRect = %ActiveSpellIcon
@onready var active_spell_mana_label: Label = %ActiveSpellManaLabel
@onready var tower_mana_label: Label = %TowerManaLabel
@onready var health_label: Label = %HealthLabel

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

# var inactive_spell_icons: Array[TextureRect] = []
# var inactive_spell_manas: Array[TextureProgressBar]

# var selected_spells: Array[SpellData] # Set by PlayerCharacter
# var spell_index: int: # Set by PlayerCharacter
# 	set(value):
# 		spell_index = value
# 		if spell_index > 3:
# 			spell_index = 0
# 		if spell_index < 0:
# 			spell_index = 3

# func _ready():
# 	inactive_spell_icons = [inactive_spell_1_icon, inactive_spell_2_icon, inactive_spell_3_icon]
# 	inactive_spell_manas = [inactive_spell_1_mana, inactive_spell_2_mana, inactive_spell_3_mana]

# func initialize(_player_mana: PlayerMana, _player_spell_spawner: PlayerSpellSpawner) -> void:
# 	selected_spells = _player_spell_spawner.selected_spells
# 	spell_index = _player_spell_spawner.spell_index
	
# 	# Configure active spell
# 	active_spell_icon.texture.region = selected_spells[spell_index].active_icon_region
# 	active_spell_mana_label.text = str(int(_player_mana.get_element_mana(selected_spells[spell_index].element)))
# 	active_spell_mana_label.text = str(int(_player_mana.get_element_mana(selected_spells[spell_index].element))).pad_zeros(3)

# 	# Configure inactive spells
# 	for i in range(0,2):
# 		inactive_spell_icons[i].texture.region = selected_spells[i+1].inactive_icon_region

# 	# Configure Tower mana
# 	tower_mana_label.text = str(int(_player_mana.tower_mana)).pad_zeros(4)

# func on_element_mana_updated() -> void:
# 	pass

# func on_tower_mana_updated() -> void:
# 	pass

# func update_spell_bar() -> void:
# 	pass

# func on_spell_index_updated(_spell_index) -> void:
# 	spell_index = _spell_index
# 	# update_hud()

# func update_hud() -> void:
# 	active_spell_icon.texture.region = selected_spells[spell_index].active_icon_region
# 	# Configure inactive spells
# 	for i in range(spell_index, spell_index+2):
# 		if i > 3:
# 			i = 0
# 		inactive_spell_icons[i].texture.region = selected_spells[i+1].inactive_icon_region
