class_name PlayerMana
extends Node

const SPELL_MANA_LOW_THRESHOLD: float = .2 # multiplied by the max value to get a percentage

var spell_mana: Dictionary[SpellData, float] = {}
var spell_mana_base_drop_amount: Dictionary[SpellData, float] = {}
var spell_mana_maxes: Dictionary[SpellData, float] = {}
var spell_mana_low: Dictionary[SpellData, bool] = {}

var tower_mana: float = 0:
	set(value):
		tower_mana = value
		tower_mana_updated.emit(tower_mana)

signal tower_mana_updated

func increment_spell_mana(spell_data, _drop_amount_modifier) -> int:
	var prev_spell_mana_amount: int = spell_mana[spell_data]
	var new_spell_mana_amount: int = min(spell_mana[spell_data] + (spell_data.base_spell_mana_per_drop * _drop_amount_modifier), spell_mana_maxes[spell_data])
	spell_mana[spell_data] = new_spell_mana_amount
	check_spell_mana_low(spell_data)
	return (new_spell_mana_amount - prev_spell_mana_amount)

func decrement_spell_mana(spell_data) -> void:
	spell_mana[spell_data] -= 1
	check_spell_mana_low(spell_data)

func check_spell_mana_low(spell_data) -> void:
	if spell_mana[spell_data] <= (spell_mana_maxes[spell_data] * SPELL_MANA_LOW_THRESHOLD):
		spell_mana_low[spell_data] = true
	else:
		spell_mana_low[spell_data] = false

## Configure `spell_data` with PlayerCharacter's active weapons, and initialize values. Called manually by `PlayerCharacter`. 
func populate_spell_mana(selected_spells: Array[SpellData]) -> void:
	for spell_data: SpellData in selected_spells:
		spell_mana[spell_data] = spell_data.initial_mana_amount
		print("Initial mana: ", spell_data.initial_mana_amount)
		spell_mana_base_drop_amount[spell_data] = spell_data.base_spell_mana_per_drop
		spell_mana_maxes[spell_data] = spell_data.max_mana_amount
		print("Max mana: ", spell_data.max_mana_amount)
		spell_mana_low[spell_data] = false
