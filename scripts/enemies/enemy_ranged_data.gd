class_name EnemyRangedData
extends EnemyData 

@export_category("Ranged Enemy Attack Data")
## Delay between bursts in seconds
@export var attack_cooldown: float
## Delay between burst shots in seconds. This value should always be shorter than attack_cooldown
@export var burst_cooldown: float
## How many burst shots will be fired before attack cooldown starts
@export var burst_max: int

@export_category("Ranged Enemy Bullet Data")
@export var bullet_damage: float 
@export var bullet_speed: float 
@export var bullet_max_distance: float 
@export var bullet_follow_on_hit: bool 
@export var bullet_atlas: CompressedTexture2D 