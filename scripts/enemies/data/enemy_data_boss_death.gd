class_name EnemyDataBossDeath
extends EnemyData

@export var bullet_atlas: CompressedTexture2D = preload("res://assets/art/atlases/enemy/atl_enemy_dark_death.png")
@export var bullet_damage: float
## Speed that the bullet travels
@export var bullet_speed: float
## Max distance until the bullet boomerangs back
@export var bullet_max_distance: float
## Speed of the dash
@export var melee_attack_dash_power: float
## Duration of the dash
@export var melee_attack_dash_duration: float
## The minimum amount of time the boss can wait until spawning to attack
@export var min_spawn_time: float
## The maximum amount of time the boss can wait until spawning to attack
@export var max_spawn_time: float
## The minimum amount of time the boss can sit idle before or after attacking
@export var min_idle_time: float
## The minimum amount of time the boss can sit idle before or after attacking
@export var max_idle_time: float

@export var min_ranged_spawn_distance: float = 64
@export var max_ranged_spawn_distance: float = 128

## +/- this value on the x-axis. Distance on x axis that boss can spawn from player global position
## A value of 50 would mean the boss can spawn -50 to 50 pixels from the player's x-axis global position 
@export var melee_spawn_distance_range_x: float = 128
## The absolute value of the minimum x-axis distance that the boss can spawn from the player's global position. If the absolute value of the 
## value selected within melee_spawn_distance_range_x is below this minimum, the minimum will be used instead with the same sign as the original 
## value
@export var min_melee_spawn_distance_x: float = 48
## +/- this value on the y-axis. Distance on y axis that boss can spawn from player global position
## A value of 50 would mean the boss can spawn -50 to 50 pixels from the player's y-axis global position 
@export var melee_spawn_distance_range_y: float = 8
## The absolute value of the minimum y-axis distance that the boss can spawn from the player's global position. If the absolute value of the 
## value selected within melee_spawn_distance_range_y is below this minimum, the minimum will be used instead with the same sign as the original 
## value
@export var min_melee_spawn_distance_y: float = 0

@export var melee_attack_chance: float = 1.0
@export var ranged_attack_chance: float = 1.0
@export var summon_attack_chance: float = .25