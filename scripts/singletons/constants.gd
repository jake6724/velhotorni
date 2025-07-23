extends Node

enum Element {FIRE, NATURE, WATER, DARK, LIGHT, STORM, NONE}

const FAST_FORWARD_SPEED: float = 2.0

const CELL_SIZE: int = 16

const TOWER_PRICES: Dictionary[Constants.Element, int] = {
	Constants.Element.FIRE: 25,
	Constants.Element.NATURE: 50,
	Constants.Element.WATER: 75,
}