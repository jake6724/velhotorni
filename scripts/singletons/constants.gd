extends Node

enum Element {FIRE, WIND, WATER, EARTH, LIGHT, DARK, NONE}

const FAST_FORWARD_SPEED: float = 20.0

const CELL_SIZE: int = 16

const TOWER_PRICES: Dictionary[Constants.Element, int] = {
	Constants.Element.FIRE: 25,
	Constants.Element.WIND: 50,
	Constants.Element.WATER: 75,
	Constants.Element.EARTH: 75,
	Constants.Element.LIGHT: 75,
	Constants.Element.DARK: 75,
}

var tower_data: Dictionary[Constants.Element, TowerData] = {
	Constants.Element.FIRE: load("res://data/towers/tower_data_fire.tres"),
	Constants.Element.EARTH: load("res://data/towers/tower_data_earth.tres"),
	Constants.Element.WATER: load("res://data/towers/tower_data_water.tres"),
	Constants.Element.WIND: load("res://data/towers/tower_data_wind.tres"),
	Constants.Element.DARK: load("res://data/towers/tower_data_dark.tres"),
	Constants.Element.LIGHT: load("res://data/towers/tower_data_light.tres"),}