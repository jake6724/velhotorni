class_name PlayerSpells
extends Node

var selected_spells: Array[SpellData]
var original_spell_positions: Array[SpellData] = []

var spells: SpellDataDoublyLinkedList
var active_spell: SpellData

signal active_spell_switched

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

	if spells.array.size() > 0:
		active_spell = spells.head.value

func switch_spells(_switch_direction) -> void:
	if spells.array.size() > 1:
		if _switch_direction > 0:
			spells.switch_right()
		else:
			spells.switch_left()
		
		active_spell = spells.head.value
		active_spell_switched.emit(active_spell)

func switch_to_index(index: int) -> void:
	var count: int = 0 # TODO: bad work-around sentinel value
	while spells.head.value != original_spell_positions[index] or count > 5:
		switch_spells(1)
		count += 1
	
