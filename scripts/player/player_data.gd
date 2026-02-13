class_name PlayerData
extends Resource

## Player max health. Health will always start at this value
@export var max_health: float = 8.0

## Starting move speed for the player, used as the base in all move speed calculations
@export var base_move_speed: float = 100.0

## Modifies how far the player moves when knockedback on hit
@export var knockback_multiplier: float = 70.0

## Chance to reflect incoming bullets
@export var reflect_chance: float = 0.0

## Influences how quickly the player stops sliding when hitstunned and recovers back to normal mode
@export var hitstun_recovery_multiplier: float = 300.0

## How long the player is invulnerable after being hit. Measured in seconds
@export var hurtbox_iframe_duration: float = 1.5

@export var special_charges_max: int = 3

@export var special_charges: int = 3

@export var special_charge_cooldown_duration: float = 2

@export var dash_power: float

@export var dash_duration: float

@export var perk_data_pool: PerkDataPool

@export var aoe_damage: float = 0.0
@export var aoe_debuffs: Array[DebuffData] = []
@export var aoe_element: Constants.Element = Constants.Element.ARCANE