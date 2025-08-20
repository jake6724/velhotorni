class_name TowerCombatUpdater
extends Node

const DAMAGE_MODIFIER: float = 0.5
const RANGE_MODIFIER: float = 0.2
const SPEED_MODIFIER: float = 0.3334

const BURN_DAMAGE_MODIFIER: float = 0.75
const KNOCKBACK_DISTANCE_MODIFIER: float = 0.5
const SLOW_DURATION_MODIFIER: float = 0.3334
const FREEZE_DURATION_MODIFIER: float = 0.3334
const STUN_DURATION_MODIFIER: float = 0.3334
const WEAKEN_DURATION_MODIFIER: float = 1

const RANGE_BUFF_LEVEL_MODIFIER: float = .5
const DAMAGE_BUFF_LEVEL_MODIFIER: float = .3334
const SPEED_BUFF_LEVEL_MODIFIER: float = .3334

var _damage_buff
var _speed_buff
var _range_buff

func update_current_combat_data(data: TowerData, damage_level: int, speed_level: int, range_level: int) -> void:
	var _leveled_damage = data.damage + (damage_level * (data.damage * DAMAGE_MODIFIER))  
	var _leveled_speed = data.speed / (1.0 + (speed_level * SPEED_MODIFIER))
	var _leveled_range = data.attack_range * (1.0 + (range_level * RANGE_MODIFIER))
	# var curr_damage = _leveled_damage + _damage_buff
	# var curr_speed = _leveled_speed + _speed_buff
	# var curr_range = _leveled_range + _range_buff
	# update_colliders()
	# update_preview_combat_data()