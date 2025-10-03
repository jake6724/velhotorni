extends Node

enum Element {
	FIRE, WIND, WATER, EARTH, LIGHT, DARK, NONE,
	LAVA, PLASMA, STORM, LIGHTNING, ICE, FLOOD, MUD, CRYSTAL, SPIRIT, SUN, CURSE, VOID,
	ARCANE}

var DIRECTIONS = [
	Vector2(0, -1),  			  # Up
	Vector2(1, -1).normalized(),  # Up Right
	Vector2(1, 0),    			  # Right
	Vector2(1, 1).normalized(),   # Down Right
	Vector2(0, 1),    			  # Down
	Vector2(-1, 1).normalized(),  # Down Left
	Vector2(-1, 0),   			  # Left
	Vector2(-1, -1).normalized()  # Up Left
]

const CELL_SIZE: int = 16

# const ui_color_base: String = "#adb5bd"
const ui_color_select: String = "#98a8f8"
const color_green: String = "#10a500"
const color_red: String = "#d63100"

const TOWER_PRICES: Dictionary[Constants.Element, int] = {
	Element.FIRE: 50,
	Element.WIND: 55,
	Element.WATER: 60,
	Element.EARTH: 65,
	Element.LIGHT: 70,
	Element.DARK: 75,
}

var tower_data: Dictionary[Constants.Element, TowerData] = {
	Element.FIRE: load("res://data/towers/tower_data_fire.tres"),
	Element.WIND: load("res://data/towers/tower_data_wind.tres"),
	Element.WATER: load("res://data/towers/tower_data_water.tres"),
	Element.EARTH: load("res://data/towers/tower_data_earth.tres"),
	Element.LIGHT: load("res://data/towers/tower_data_light.tres"),
	Element.DARK: load("res://data/towers/tower_data_dark.tres"),
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
		Element.SPIRIT: return Element.CURSE
		Element.SUN: return Element.VOID
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

var z_index_map: Dictionary[String, int] = {
	"bg": -4096,
	"melee_spell": -4094,
	"terrain_obstacle": -2000, # Not actually used, but this is the value painted on the tileset. used so sword always goes behind these
	"weather_scroll": -1999,
	"base": -1001,
	"coin": -1000,
	"pulse_bullet": -999,
	"tower": -998,
	"enemy_spawner": 1,
	"player_character": 2,
	"tower_menu": 1000,
	"tower_upgrade_menu": 1001,
	"top": 4096
}

func get_closest_cardinal_direction_normalized(input_vector) -> Vector2:
	var best_direction = DIRECTIONS[0]
	var best_dot_product = -INF

	for dir in DIRECTIONS:
		var dot = input_vector.dot(dir)
		if dot > best_dot_product:
			best_dot_product = dot
			best_direction = dir
	return best_direction