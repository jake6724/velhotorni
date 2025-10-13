class_name PlayerMana
extends Node

@export var mana_per_drop: float = 10.0
@export var element_mana: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 0,
	Constants.Element.WIND: 0,
	Constants.Element.WATER: 0,
	Constants.Element.EARTH: 0,
	Constants.Element.LIGHT: 0,
	Constants.Element.DARK: 0,
	Constants.Element.ARCANE: 0,
}

@export var element_mana_maxes: Dictionary[Constants.Element, float] = {
	Constants.Element.FIRE: 0,
	Constants.Element.WIND: 0,
	Constants.Element.WATER: 0,
	Constants.Element.EARTH: 0,
	Constants.Element.LIGHT: 0,
	Constants.Element.DARK: 0,
	Constants.Element.ARCANE: 0,
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

func increment_element_mana(_element) -> void:
	element_mana[_element] += mana_per_drop
