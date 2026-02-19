extends Node

enum Element {
	FIRE, WIND, WATER, EARTH, LIGHT, DARK, NONE,
	LAVA, PLASMA, STORM, LIGHTNING, ICE, FLOOD, MUD, CRYSTAL, SPIRIT, SUN, CURSE, VOID,
	ARCANE}

enum ZIndexLayer {PLAYER, }

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

var DIRECTIONS_4 = [
	Vector2(0, -1),  			  # Up
	Vector2(1, 0),    			  # Right
	Vector2(0, 1),    			  # Down
	Vector2(-1, 0),   			  # Left
]

const CELL_SIZE: int = 16

const MAGNET_SPEED: float = 400

const TOWER_MAX_LEVEL: int = 3

# const ui_color_base: String = "#adb5bd"
const ui_color_select: String = "#98a8f8"
var ui_color_unselected: Color = Color.from_string("#425984", Color.LIGHT_GREEN)
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
	"enemy_corpse": -3500,
	"tower_shield": -3000,
	"terrain_obstacle": -2000, # Not actually used, but this is the value painted on the tileset. used so sword always goes behind these
	"base": -1001,
	"coin": -1000,
	"pulse_bullet": -999,
	"tower": -998,
	"enemy_spawner": 1,
	"player_character": 2,
	"tall_grass": 100,
	"flying_enemy": 1000,
	"weather_scroll": 2000,
	"tower_menu": 1000,
	"tower_upgrade_menu": 1001,
	"reticle": 2001,
	"enemy_healthbar": 2000, 
	"popup": 4050,
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

func get_closest_cardinal_4_direction_normalized(input_vector) -> Vector2:
	var best_direction = DIRECTIONS_4[0]
	var best_dot_product = -INF

	for dir in DIRECTIONS_4:
		var dot = input_vector.dot(dir)
		if dot > best_dot_product:
			best_dot_product = dot
			best_direction = dir
	return best_direction

var weighted_random_rng: RandomNumberGenerator = RandomNumberGenerator.new()

## `spawn_chance_array` must be a doubly-nested array. 
## Each sub-array must contain a value to return, and the chance of getting it.
func get_weighted_random(spawn_chance_array) -> Variant:
	var total = 0
	for i in range(len(spawn_chance_array)):
		total += spawn_chance_array[i][1]

	var r = weighted_random_rng.randf() * total

	for i in range(0, len(spawn_chance_array)):
		var selection = spawn_chance_array[i]
		if r < selection[1]:
			return selection[0]
		r -= selection[1]

	push_error("get_weighted_random reached final return, which should not be possible")
	return # Only here to allow for typed return signature. Should never return here

func get_base_element(element: Element) -> Element:
	match element:
		Element.FIRE:  return Element.FIRE
		Element.WIND:  return Element.WIND
		Element.WATER: return Element.WATER
		Element.EARTH: return Element.EARTH
		Element.LIGHT: return Element.LIGHT
		Element.DARK:  return Element.DARK
		Element.LAVA: return Element.FIRE
		Element.PLASMA: return Element.FIRE
		Element.STORM: return Element.WIND
		Element.LIGHTNING: return Element.WIND
		Element.ICE: return Element.WATER
		Element.FLOOD: return Element.WATER
		Element.MUD: return Element.EARTH
		Element.CRYSTAL: return Element.EARTH
		Element.SPIRIT: return Element.LIGHT
		Element.SUN: return Element.LIGHT
		Element.CURSE: return Element.DARK
		Element.VOID: return Element.DARK
		Element.ARCANE: return Element.ARCANE
		Element.NONE: return Element.NONE
		_: 
			push_error("Constants.get_base_element() could not match element arg: ", element)
			return Element.NONE

var element_text: Dictionary[Element, String] ={
	Element.FIRE: "Fire",
	Element.WIND: "Wind",
	Element.WATER: "Water",
	Element.EARTH: "Earth",
	Element.LIGHT: "Light",
	Element.DARK: "Dark",
	Element.LAVA: "Lava",
	Element.PLASMA: "Plasma",
	Element.STORM: "Storm",
	Element.LIGHTNING: "Lightning",
	Element.ICE: "Ice",
	Element.FLOOD: "Flood",
	Element.MUD: "Mud",
	Element.CRYSTAL: "Crystal",
	Element.SPIRIT: "Spirit",
	Element.SUN: "Sun",
	Element.CURSE: "Curse",
	Element.VOID: "Void",
	Element.ARCANE: "Arcane",
	Element.NONE: "None",
}

var debuff_type_text: Dictionary[Debuff.Type, String] = {
	Debuff.Type.BURN: "Burn",
	Debuff.Type.SLOW: "Slow",
	Debuff.Type.FREEZE: "Freeze",
	Debuff.Type.STUN: "Stun", 
	Debuff.Type.WEAKEN: "Weaken",
	Debuff.Type.KNOCKBACK: "Knockback", 
	Debuff.Type.NONE: "None"

}

func get_element_text(element: Element) -> String:
	return element_text.get(element, "Element not found!")

func get_debuff_type_text(debuff_type: Debuff.Type) -> String:
	return debuff_type_text.get(debuff_type, "Debuff type not found!")
