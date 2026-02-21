class_name PlayerCharacterStats # TODO: Change this to PlayerStats
extends Node 

signal health_updated
signal reflect_chance_updated

var max_health: float
var base_move_speed: float
var move_speed: float
var knockback_multiplier: float
var reflect_chance: float:
	set(value):
		reflect_chance = value
		reflect_chance_updated.emit(reflect_chance)
var hitstun_recovery_multiplier: float 
var hurtbox_iframe_duration: float
var hurtbox_iframe_duration_base: float

var special_charges_max: int
var special_charges: int
var special_charge_cooldown_duration: float
var special_charge_cooldown_duration_base: float

var aoe_damage: float = 0.0
var aoe_debuffs: Array[DebuffData] = []
var aoe_element: Constants.Element = Constants.Element.ARCANE

var dash_power: float
var dash_duration: float
var pre_dash_coyote_time: float
var post_dash_coyote_time: float

func load_player_data(data: PlayerData) -> void:
	max_health = data.max_health
	base_move_speed = data.base_move_speed
	move_speed = base_move_speed
	knockback_multiplier = data.knockback_multiplier
	reflect_chance = data.reflect_chance
	hitstun_recovery_multiplier = data.hitstun_recovery_multiplier
	hurtbox_iframe_duration = data.hurtbox_iframe_duration
	hurtbox_iframe_duration_base = hurtbox_iframe_duration
	special_charges_max = data.special_charges_max
	special_charges = data.special_charges
	special_charge_cooldown_duration = data.special_charge_cooldown_duration
	special_charge_cooldown_duration_base = special_charge_cooldown_duration
	aoe_damage = data.aoe_damage
	aoe_debuffs = data.aoe_debuffs
	aoe_element = data.aoe_element
	dash_power = data.dash_power
	pre_dash_coyote_time = data.pre_dash_coyote_time
	post_dash_coyote_time = data.post_dash_coyote_time
	dash_duration = data.dash_duration

var health: float = 8.0:
	set(value):
		health = min(value, max_health)
		if health < 1:
			health = 0
		health_updated.emit(health)
