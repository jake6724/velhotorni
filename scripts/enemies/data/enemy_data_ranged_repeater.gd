extends EnemyData
class_name EnemyDataRangedRepeater

@export_category("Ranged Enemy Attack Data")
## Cooldown that starts once all bursts have been fired
@export var attack_cooldown: float = 1.0
## Cooldown inbetween bursts (intended for this to be smaller than attack cooldown in most cases). A burst do not have
## to be just 1 bullet, it fires as many as defined below in "Bullet Pattern Data". Think of Bullet Pattern Data as
## defining a burst.
@export var burst_cooldown: float = 0.0
## How many bursts are fired before attack_cooldown runs
@export var num_bursts: int = 1
## How long after spawning until this enemy will start repeating
@export var initial_delay: float = 0.0

@export_category("Bullet Pattern Data")
## How many bullets are in a burst
@export var num_bullets_per_burst: int
## This is the start angle for each burst. Since there is no specific target for repeaters (like the player), they
## can start firing in any direction. ** Each burst this value is incremented by `burst_angle_increment`, and then reset
## back to the original value when all bursts are complete.
@export var start_angle: float
## Increment between bullets in the same burst pattern
@export var angle_increment: float
## Increment between bursts within the same attack
@export var burst_angle_increment: float = 0.0

@export_category("Ranged Enemy Bullet Data")
## How fast the bullet travels. Higher values could cause issues with missign target.
@export var bullet_speed: float
## Max distance the bullet can travel before hit animation is triggered and bullet queue_free()
@export var bullet_max_distance: float
@export var bullet_atlas: CompressedTexture2D = preload("res://assets/art/atlases/bullet/atl_bullet_enemy.png")