class_name PlayerSpells
extends Node

@export var selected_spells: Array[SpellData] = [null, null, null, null]
var original_spell_positions: Array[SpellData] = []

var spells: SpellDataDoublyLinkedList
var active_spell: SpellData

signal active_spell_switched

func _ready():
	original_spell_positions = selected_spells
	spells = SpellDataDoublyLinkedList.new(selected_spells)
	active_spell = spells.head.value

func switch_spells(_switch_direction) -> void:
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
