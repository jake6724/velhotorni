extends Node

enum Element {
	FIRE, WIND, WATER, EARTH, LIGHT, DARK, NONE,
	LAVA, PLASMA, STORM, LIGHTNING, ICE, FLOOD, MUD, CRYSTAL, SPIRIT, SUN, CURSE, VOID}

const FAST_FORWARD_SPEED: float = 20.0

const CELL_SIZE: int = 16

const TOWER_PRICES: Dictionary[Constants.Element, int] = {
	Element.FIRE: 50,
	Element.WIND: 55,
	Element.WATER: 60,
	Element.EARTH: 65,
	Element.LIGHT: 70,
	Element.DARK: 75,
}

var tower_data: Dictionary[Constants.Element, TowerData] = {
	Element.FIRE: load("res://data/towers/tower_data_fire_lava.tres"),
	Element.WIND: load("res://data/towers/tower_data_wind_lightning.tres"),
	Element.WATER: load("res://data/towers/tower_data_water_flood.tres"),
	Element.EARTH: load("res://data/towers/tower_data_earth_crystal.tres"),
	Element.LIGHT: load("res://data/towers/tower_data_light_sun.tres"),
	Element.DARK: load("res://data/towers/tower_data_dark_void.tres"),
	Element.LAVA: load("res://data/towers/tower_data_fire_lava.tres"),
	Element.PLASMA: load("res://data/towers/tower_data_fire_plasma.tres"),
	Element.STORM: load("res://data/towers/tower_data_wind_storm.tres"),
	Element.LIGHTNING: load("res://data/towers/tower_data_wind_lightning.tres"),
	Element.ICE: load("res://data/towers/tower_data_water_ice.tres"),
	Element.FLOOD: load("res://data/towers/tower_data_water_flood.tres"),
	Element.MUD: load("res://data/towers/tower_data_earth_mud.tres"),
	Element.CRYSTAL: load("res://data/towers/tower_data_earth_crystal.tres"),
	Element.SPIRIT: load("res://data/towers/tower_data_light_spirit.tres"),
	Element.SUN: load("res://data/towers/tower_data_light_sun.tres"),
	Element.CURSE: load("res://data/towers/tower_data_dark_curse.tres"),
	Element.VOID: load("res://data/towers/tower_data_dark_void.tres"),
}

func get_next_element(_element: Element) -> Element:
	match _element:
		Element.FIRE: return Element.WIND
		Element.WIND: return Element.WATER
		Element.WATER: return Element.EARTH
		Element.EARTH: return Element.LIGHT
		Element.LIGHT: return Element.DARK
		Element.DARK: return Element.FIRE

		Element.LAVA: return Element.STORM
		Element.PLASMA: return Element.LIGHTNING
		Element.STORM: return Element.ICE
		Element.LIGHTNING: return Element.FLOOD
		Element.ICE: return Element.MUD
		Element.FLOOD: return Element.CRYSTAL
		Element.MUD: return Element.SPIRIT
		Element.CRYSTAL: return Element.SUN
		Element.SPIRIT: return Element.LAVA
		Element.SUN: return Element.PLASMA
		Element.CURSE: return Element.LAVA
		Element.VOID: return Element.PLASMA

		_: return Element.NONE

func get_prev_element(_element: Element) -> Element:
	match _element:
		Element.FIRE: return Element.DARK
		Element.WIND: return Element.FIRE
		Element.WATER: return Element.WIND
		Element.EARTH: return Element.WATER
		Element.LIGHT: return Element.EARTH
		Element.DARK: return Element.LIGHT

		Element.LAVA: return Element.CURSE
		Element.PLASMA: return Element.VOID
		Element.STORM: return Element.LAVA
		Element.LIGHTNING: return Element.PLASMA
		Element.ICE: return Element.STORM
		Element.FLOOD: return Element.LIGHTNING
		Element.MUD: return Element.ICE
		Element.CRYSTAL: return Element.FLOOD
		Element.SPIRIT: return Element.MUD
		Element.SUN: return Element.CRYSTAL
		Element.CURSE: return Element.SPIRIT
		Element.VOID: return Element.SUN
		
		_: return Element.NONE

func get_evolve_element_1(_element: Element) -> Element:
	match _element:
		Element.FIRE: return Element.LAVA
		Element.WIND: return Element.STORM
		Element.WATER: return Element.ICE
		Element.EARTH: return Element.MUD
		Element.LIGHT: return Element.SPIRIT
		Element.DARK: return Element.CURSE
		_: return Element.NONE

func get_evolve_element_2(_element: Element) -> Element:
	match _element:
		Element.FIRE: return Element.PLASMA
		Element.WIND: return Element.LIGHTNING
		Element.WATER: return Element.FLOOD
		Element.EARTH: return Element.CRYSTAL
		Element.LIGHT: return Element.SUN
		Element.DARK: return Element.VOID
		_: return Element.NONE