class_name PlayerMana
extends Node

const MANA_LOW_THRESHOLD: float = .2 # multiplied by the max value to get a specific percentage

var element_mana: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 100,
	Constants.Element.WIND: 100,
	Constants.Element.WATER: 100,
	Constants.Element.EARTH: 100,
	Constants.Element.LIGHT: 100,
	Constants.Element.DARK: 100,
	Constants.Element.ARCANE: 200,
}

var element_mana_maxes: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 200,
	Constants.Element.WIND: 200,
	Constants.Element.WATER: 200,
	Constants.Element.EARTH: 200,
	Constants.Element.LIGHT: 200,
	Constants.Element.DARK: 200,
	Constants.Element.ARCANE: 400,
}

var element_drop_amount_base: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 20,
	Constants.Element.WIND: 20,
	Constants.Element.WATER: 20,
	Constants.Element.EARTH: 20,
	Constants.Element.LIGHT: 20,
	Constants.Element.DARK: 20,
	Constants.Element.ARCANE: 40,
}

var element_mana_low: Dictionary[Constants.Element, bool] = {
	Constants.Element.FIRE: false,
	Constants.Element.WIND: false,
	Constants.Element.WATER: false,
	Constants.Element.EARTH: false,
	Constants.Element.LIGHT: false,
	Constants.Element.DARK: false,
	Constants.Element.ARCANE: false,
}

var tower_mana: float = 0:
	set(value):
		tower_mana = value
		tower_mana_updated.emit(tower_mana)

signal tower_mana_updated

func get_element_mana(_element: Constants.Element) -> float:
	return element_mana[_element]

func get_element_mana_max(_element: Constants.Element) -> float:
	return element_mana_maxes[_element]

func decrement_element_mana(_element, _value) -> void:
	element_mana[_element] -= _value
	check_mana_low(_element)

func increment_element_mana(_element, _drop_amount_modifier) -> void:

	element_mana[_element] = min(element_mana[_element] + (element_drop_amount_base[_element] * _drop_amount_modifier), element_mana_maxes[_element] )
	# element_mana[_element] += (element_drop_amount_base[_element] * _drop_amount_modifier)
	check_mana_low(_element)

func check_mana_low(_element) -> void:
	if element_mana[_element] <= (element_mana_maxes[_element] * MANA_LOW_THRESHOLD):
		element_mana_low[_element] = true
	else:
		element_mana_low[_element] = false
