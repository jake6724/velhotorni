extends EnemyData
class_name EnemyDataRanged

@export_category("Ranged Enemy Attack Data")
## Cooldown that starts once all bursts have been fired
@export var attack_cooldown: float = 1.0
## The radius of the attack detection cirlce around the enemy
@export var attack_range: float = 72.0
## Cooldown inbetween bursts (intended for this to be smaller than attack cooldown in most cases). A burst do not have
## to be just 1 bullet, it fires as many as defined below in "Bullet Pattern Data". Think of Bullet Pattern Data as
## defining a burst.
@export var burst_cooldown: float = 0.0
## How many bursts are fired before attack_cooldown runs
@export var num_bursts: int = 1

@export_category("Bullet Pattern Data")
## How many bullets are in a burst
@export var num_bullets_per_burst: int
## Angle of separation between each bullet. Follows a specific pattern: 
## Ex. angle_increment = 10: 
## The first bullet (for EnemyRanged) is always fired at the player. The next bullet will be fired +angle_increment degrees from this original shot.
## The next bullet will be fired at the same angle, but inverted (angle = -angle). This will make the pattern always start at the 
## towards the player, and then build out symmetrically from that point.
@export var angle_increment: float
@export var spawn_center_bullet: bool = true

@export_category("Ranged Enemy Bullet Data")
## This value is how much the bullet does to a TOWER. The player will always take 1 damage
@export var bullet_damage: int = 1
## How fast the bullet travels. Higher values could cause issues with missign target.
@export var bullet_speed: float
## Max distance the bullet can travel before hit animation is triggered and bullet queue_free()
@export var bullet_max_distance: float
@export var bullet_atlas: CompressedTexture2D = preload("res://assets/art/atlases/bullet/atl_bullet_enemy.png")