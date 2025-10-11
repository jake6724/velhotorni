class_name PlayerSpells
extends Node

@export var selected_spells: Array[SpellData] = [null, null, null, null]

var spells: DoublyLinkedList
var active_spell: SpellData

signal active_spell_switched

func _ready():
	spells = DoublyLinkedList.new(selected_spells)
	active_spell = spells.head.value

func switch_spells(_switch_direction) -> void:
	if _switch_direction > 0:
		spells.switch_right()
	else:
		spells.switch_left()
	
	active_spell = spells.head.value
	active_spell_switched.emit(active_spell)