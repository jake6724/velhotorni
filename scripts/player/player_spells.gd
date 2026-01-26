class_name PlayerSpells
extends Node

var selected_spells: Array[SpellData] # Raw spell data. May include null spell data
var original_spell_positions: Array[SpellData] = [] 

var spells: SpellDataDoublyLinkedList # Raw spell data converted to a dll. Any null spelldata is removed
var active_spell: SpellData

signal active_spell_switched

var empty_spell = preload("res://data/spells/spell_data_empty.tres")

func _ready():
	configure_spells()

func configure_spells() -> void:
	selected_spells = PlayerLoadout.equipped_spells

	# Copy selected spells, clear it, and only put back spelldata and not null values
	var selected_spells_clone = selected_spells.duplicate()
	selected_spells = []
	for item in selected_spells_clone:
		if item:
			selected_spells.append(item)

	original_spell_positions = selected_spells
	spells = SpellDataDoublyLinkedList.new(selected_spells)

	# print("PlayerSpells.configure_spells() - active_spell: ", spells.head.value)
	if spells.head:
		active_spell = spells.head.value
	else:
		active_spell = empty_spell

func switch_spells(_switch_direction) -> void:
	if spells.array.size() > 1:
		if _switch_direction > 0:
			spells.switch_right()
		else:
			spells.switch_left()
		
		active_spell = spells.head.value
		active_spell_switched.emit(active_spell)

func switch_to_index(index: int) -> void:
	if original_spell_positions.size() > index:
		var count: int = 0 # TODO: bad work-around sentinel value
		while spells.head.value != original_spell_positions[index] or count > 5:
			switch_spells(1)
			count += 1

func get_all_spell_data_of_element(target_element: Constants.Element) -> Array[SpellData]:
	var res: Array[SpellData] = []
	for spell_data: SpellData in spells.array:
		if spell_data.element == target_element:
			res.append(spell_data)
	return res

func get_active_elements() -> Array[Constants.Element]:
	var res: Array[Constants.Element] = []
	for spell_data: SpellData in spells.array:
		res.append(spell_data.element)
	return res