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