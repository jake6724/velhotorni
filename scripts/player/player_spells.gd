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
	print("Spells: ", spells)
	print("spells.head: ", spells.head)
	print("Spells.head.value: ", spells.head.value)
	print("test")
	#var curr_value: PerkData = spells.head.value
	while spells.head.value != original_spell_positions[index]:
		switch_spells(1)

	# for i in range(index):
	# 	switch_spells(1)
	# 	get_tree().create_timer(.1)
