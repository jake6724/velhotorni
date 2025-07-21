extends Node

enum Element {FIRE, WATER, EARTH, NONE}

const FAST_FORWARD_SPEED: float = 2.0

const CELL_SIZE: int = 16

const TOWER_PRICES: Dictionary[Constants.Element, int] = {
	Constants.Element.FIRE: 25,
	Constants.Element.EARTH: 50,
	Constants.Element.WATER: 75,
}